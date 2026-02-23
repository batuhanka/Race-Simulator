import SwiftUI
import SceneKit

struct SimulationViewHorse3D: View {
    // MARK: - PROPERTIES
    let raceCity: String
    let havaData: HavaData
    let kosu: Race
    
    @Environment(\.dismiss) var dismiss
    @State private var isSimulating: Bool = false
    @State private var finishLineReached: Bool = false
    @State private var winnerHorse: Horse? = nil
    
    @State private var currentRanking: [Horse] = []
    @State private var lastLeaderboardUpdate: TimeInterval = 0
    @State private var horseBaseSpeeds: [String: Float] = [:]
    
    // 3D Refs
    @State private var scene = SCNScene()
    @State private var horseNodes: [String: SCNNode] = [:]
    @State private var cameraNode = SCNNode()
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Pist sınırları
    let startX: Float = -22.0
    let finishX: Float = 22.0
    
    var body: some View {
        ZStack {
            // 1. EN ALT KATMAN: Tam Ekran 3D Sahne
            SceneView(
                scene: scene,
                pointOfView: cameraNode,
                options: [.allowsCameraControl],
                preferredFramesPerSecond: 60
            )
            .ignoresSafeArea()
            
            // 2. ÜST KATMAN: Arayüz (UI) Elemanları
            VStack(spacing: 0) {
                simulationHeader
                
                Spacer()
                
                // YENİ: ZStack hizalaması "Sağ Alt" (.bottomTrailing) yapıldı
                ZStack(alignment: .bottomTrailing) {
                    HStack {
                        leaderboardHUD
                        Spacer()
                    }
                    
                    // START Butonu artık sağ alt köşede
                    controlPanel
                        .padding(.trailing, 24)
                }
                .padding(.bottom, 20)
            }
            
            // 3. FİNİŞ KATMANI
            if let winner = winnerHorse {
                winnerOverlay(horse: winner)
            }
        }
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            updateRaceLogic()
        }
        .onAppear {
            forceLandscape()
            setup3DScene()
            if let atlar = kosu.atlar {
                currentRanking = atlar
            }
        }
        .onDisappear {
            restorePortrait()
        }
    }
}

// MARK: - UI COMPONENTS
extension SimulationViewHorse3D {
    private var simulationHeader: some View {
        HStack {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4).fill(Color.cyan).frame(width: 4, height: 24)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(raceCity.uppercased(with: Locale(identifier: "tr_TR"))) LIVE")
                        .font(.system(size: 14, weight: .black)).foregroundColor(Color.cyan)
                    Text(kosu.BILGI_TR ?? "3D Simülasyon")
                        .font(.system(size: 10, weight: .medium)).foregroundColor(Color.white.opacity(0.6))
                }
                
            }
            Spacer()
            HStack(spacing: 20) {
                HStack(spacing: 6) { Image(systemName: "thermometer.medium"); Text("\(havaData.sicaklik)°C") }
                Text(havaData.havaTr.uppercased())
            }
            .font(.system(size: 12, weight: .bold)).foregroundColor(Color.cyan)
            Spacer()
            Button { safeDismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundColor(Color.white)
                    .padding(8).background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 12)
        .background(LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom))
        .zIndex(10)
    }
    
    private var controlPanel: some View {
        Button(action: {
            if finishLineReached {
                resetSimulation()
            } else {
                isSimulating.toggle()
                for node in horseNodes.values {
                    node.isPaused = !isSimulating
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: finishLineReached ? "arrow.counterclockwise" : (isSimulating ? "pause.fill" : "play.fill"))
                Text(finishLineReached ? "TEKRAR" : (isSimulating ? "DURAKLAT" : "START VER"))
            }
            .font(.system(size: 14, weight: .black)).foregroundColor(Color.black)
            .frame(width: 180, height: 44) // Genişlik biraz daraltıldı köşeye uyması için
            .background(finishLineReached ? Color.white : Color.cyan)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 4)
        }
    }
    
    private var leaderboardHUD: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CANLI SIRALAMA")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Color.white.opacity(0.7))
                .padding(.bottom, 2)
            
            let topHorses = Array(currentRanking.prefix(5))
            
            ForEach(Array(topHorses.enumerated()), id: \.element.id) { index, horse in
                leaderboardRow(index: index, horse: horse)
            }
        }
        .padding(.leading, 16)
    }
    
    private func leaderboardRow(index: Int, horse: Horse) -> some View {
        HStack(spacing: 8) {
            Text("\(index + 1)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.cyan)
                .frame(width: 12, alignment: .leading)
            
            Circle()
                .fill(horse.horseColor)
                .frame(width: 16, height: 16)
                .overlay(
                    Text(horse.NO ?? "0")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(isLightColor(horse.horseColor) ? Color.black : Color.white)
                )
            
            Text(horse.AD ?? "At")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.5))
        .cornerRadius(6)
        .animation(.easeInOut(duration: 0.3), value: currentRanking.map { $0.id })
    }
    
    private func winnerOverlay(horse: Horse) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("PHOTO FINISH").font(.system(size: 14, weight: .black)).foregroundColor(Color.cyan).tracking(4)
                
                Circle()
                    .fill(horse.horseColor)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(horse.NO ?? "0")
                            .font(.system(size: 60, weight: .black))
                            .foregroundColor(isLightColor(horse.horseColor) ? Color.black : Color.white)
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                
                VStack(spacing: 8) {
                    Text(horse.AD ?? "-").font(.system(size: 32, weight: .black)).foregroundColor(Color.white)
                    Text("JOKEY: \(horse.JOKEYADI ?? "-")").font(.system(size: 18, weight: .bold)).foregroundColor(Color.cyan)
                }
                
                Button("SIRALAMAYI GÖR") { safeDismiss() }
                    .font(.system(size: 14, weight: .black)).padding(.horizontal, 50).padding(.vertical, 14)
                    .background(Color.white).foregroundColor(Color.black).cornerRadius(30)
            }
        }
    }
    
    private func isLightColor(_ color: Color) -> Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.6
    }
}

// MARK: - 3D LOGIC
extension SimulationViewHorse3D {
    
    private func createCheckerboardTexture() -> UIImage {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.setFill(); ctx.fill(CGRect(origin: .zero, size: size))
            UIColor.black.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 64, height: 64)); ctx.fill(CGRect(x: 64, y: 64, width: 64, height: 64))
        }
    }
    
    // YENİ: Mesafe Tabela Dokusu (Kırmızı Zemin, Beyaz Yazı)
    private func createDistanceMarkerTexture(text: String) -> UIImage {
        let size = CGSize(width: 200, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            // Kırmızı Zemin
            UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 10).fill()
            
            // Beyaz Dış Çerçeve
            UIColor.white.setStroke()
            let border = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: 4, dy: 4), cornerRadius: 8)
            border.lineWidth = 4
            border.stroke()
            
            // Metin (Örn: "400")
            let textAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 45, weight: .black),
                .foregroundColor: UIColor.white
            ]
            let str = NSAttributedString(string: text, attributes: textAttr)
            let strSize = str.size()
            str.draw(in: CGRect(x: (size.width - strSize.width) / 2,
                                y: (size.height - strSize.height) / 2,
                                width: strSize.width, height: strSize.height))
        }
    }
    
    private func setup3DScene() {
        let newScene = SCNScene()
        newScene.background.contents = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        
        guard let atlar = kosu.atlar else { return }
        let horseCount = atlar.count
        
        let spacing: Float = horseCount > 10 ? 1.5 : 2.0
        let totalZ = Float(horseCount - 1) * spacing
        let startZ = -totalZ / 2.0
        let trackLength = Float(totalZ + 10)
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 50
        cameraNode.position = SCNVector3(x: startX + 5, y: 11, z: 16)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi/6, y: -Float.pi/10, z: 0)
        newScene.rootNode.addChildNode(cameraNode)
        
        let ambient = SCNNode(); ambient.light = SCNLight(); ambient.light?.type = .ambient; ambient.light?.intensity = 150
        newScene.rootNode.addChildNode(ambient)
        
        let pointLight = SCNNode(); pointLight.light = SCNLight(); pointLight.light?.type = .omni; pointLight.light?.intensity = 800
        pointLight.position = SCNVector3(x: 0, y: 20, z: 10)
        newScene.rootNode.addChildNode(pointLight)
        
        let grassGeo = SCNPlane(width: 300, height: 300)
        grassGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 1.0)
        let grassNode = SCNNode(geometry: grassGeo)
        grassNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
        grassNode.position = SCNVector3(0, -0.15, 0)
        newScene.rootNode.addChildNode(grassNode)
        
        let trackGeo = SCNPlane(width: 200, height: CGFloat(trackLength + 2.0))
        trackGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.25, green: 0.18, blue: 0.12, alpha: 1.0)
        let trackNode = SCNNode(geometry: trackGeo); trackNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0); trackNode.position = SCNVector3(0, -0.1, 0)
        newScene.rootNode.addChildNode(trackNode)
        
        let barrierLength = CGFloat(200)
        let barrierGeo = SCNBox(width: barrierLength, height: 0.6, length: 0.2, chamferRadius: 0.05)
        barrierGeo.firstMaterial?.diffuse.contents = UIColor.white
        
        let frontBarrier = SCNNode(geometry: barrierGeo)
        frontBarrier.position = SCNVector3(0, 0.2, startZ + totalZ + 1.5)
        newScene.rootNode.addChildNode(frontBarrier)
        
        let backBarrier = SCNNode(geometry: barrierGeo)
        backBarrier.position = SCNVector3(0, 0.2, startZ - 1.5)
        newScene.rootNode.addChildNode(backBarrier)
        
        let finishGeo = SCNBox(width: 1.0, height: 0.05, length: Double(trackLength), chamferRadius: 0)
        let finishMaterial = SCNMaterial()
        finishMaterial.diffuse.contents = createCheckerboardTexture()
        finishMaterial.diffuse.wrapS = .repeat; finishMaterial.diffuse.wrapT = .repeat
        finishMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(2, Float(trackLength) / 1.5, 1)
        finishGeo.materials = [finishMaterial]
        let finishNode = SCNNode(geometry: finishGeo); finishNode.position = SCNVector3(finishX, 0, 0)
        newScene.rootNode.addChildNode(finishNode)
        
        // YENİ: MESAFE TABELALARI SİSTEMİ
        let realDistance = Float(kosu.MESAFE ?? "1200") ?? 1200.0
        let distanceSpan = finishX - startX // 3D dünyadaki pist uzunluğu (44 birim)
        
        // Bitişe kalan mesafeleri bulur (200, 400, 600... şeklinde gerçek mesafeden küçük olanlar)
        let markerDistances = stride(from: 200, to: Int(realDistance), by: 200)
        
        for dist in markerDistances {
            // Yarışın ne kadarı kalmış? (Örn: 1900m yarışta 400m tabelası için oran = 400 / 1900)
            let ratio = Float(dist) / realDistance
            
            // X ekseninde tabelanın konumunu, bitiş çizgisinden geriye giderek hesaplarız
            let markerX = finishX - (ratio * distanceSpan)
            
            // Tabela Ekranı
            let boardGeo = SCNPlane(width: 1.8, height: 0.9)
            boardGeo.firstMaterial?.diffuse.contents = createDistanceMarkerTexture(text: "\(dist)")
            let boardNode = SCNNode(geometry: boardGeo)
            boardNode.position = SCNVector3(markerX, 1.0, startZ - 1.4) // Arka bariyerin hemen üstü/önü
            
            // Tabelanın direği
            let poleGeo = SCNCylinder(radius: 0.05, height: 1.0)
            poleGeo.firstMaterial?.diffuse.contents = UIColor.white
            let poleNode = SCNNode(geometry: poleGeo)
            poleNode.position = SCNVector3(markerX, 0.3, startZ - 1.4)
            
            newScene.rootNode.addChildNode(poleNode)
            newScene.rootNode.addChildNode(boardNode)
        }
        
        horseBaseSpeeds.removeAll()
        for (index, at) in atlar.enumerated() {
            let container = SCNNode()
            let zPos = startZ + Float(index) * spacing
            container.position = SCNVector3(startX, 0, zPos)
            
            let horseModelNode = getHorseModel(number: at.NO ?? "0")
            container.addChildNode(horseModelNode)
            
            newScene.rootNode.addChildNode(container)
            horseNodes[at.id] = container
            
            let agf = Float(at.AGF1?.replacingOccurrences(of: ",", with: ".") ?? "5.0") ?? 5.0
            let agfBonus = (agf / 100.0) * 0.015
            let dailyForm = Float.random(in: -0.01...0.015)
            
            horseBaseSpeeds[at.id] = 0.035 + agfBonus + dailyForm
        }
        self.scene = newScene
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for node in self.horseNodes.values {
                node.isPaused = true
            }
        }
    }
    
    private func getHorseModel(number: String) -> SCNNode {
        let finalNode = SCNNode()
        
        if let horseScene = SCNScene(named: "thehorse.usdz") {
            let wrapperNode = SCNNode()
            for child in horseScene.rootNode.childNodes {
                wrapperNode.addChildNode(child.clone())
            }
            
            wrapperNode.scale = SCNVector3(0.01, 0.01, 0.01)
            wrapperNode.eulerAngles = SCNVector3(0, Float.pi / 2, 0)
            
            let naturalCoatColors: [UIColor] = [
                UIColor(red: 0.35, green: 0.20, blue: 0.10, alpha: 1.0),
                UIColor(red: 0.60, green: 0.30, blue: 0.15, alpha: 1.0),
                UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0),
                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0),
                UIColor(red: 0.50, green: 0.25, blue: 0.15, alpha: 1.0)
            ]
            let colorIndex = (Int(number) ?? 0) % naturalCoatColors.count
            let selectedCoatColor = naturalCoatColors[colorIndex]
            
            wrapperNode.enumerateChildNodes { (child, _) in
                if let geometry = child.geometry {
                    for material in geometry.materials {
                        let matName = material.name?.lowercased() ?? ""
                        if !matName.contains("jockey") && !matName.contains("saddle") && !matName.contains("cloth") {
                            material.multiply.contents = selectedCoatColor
                        }
                    }
                }
            }
            finalNode.addChildNode(wrapperNode)
        }
        
        return finalNode
    }
    
    private func updateRaceLogic() {
        guard isSimulating && !finishLineReached else { return }
        
        guard let atlar = kosu.atlar else { return }
        
        var leaderX: Float = startX
        let currentTime = CACurrentMediaTime()
        
        for (index, at) in atlar.enumerated() {
            guard let node = horseNodes[at.id] else { continue }
            
            let baseSpeed = horseBaseSpeeds[at.id] ?? 0.04
            let phase = Float(index) * 2.0
            let surge = sin(Float(currentTime) * 0.8 + phase) * 0.015
            
            let finalSpeed = baseSpeed + surge
            node.position.x += finalSpeed
            
            if node.position.x > leaderX { leaderX = node.position.x }
            
            if node.position.x >= finishX {
                isSimulating = false
                finishLineReached = true
                withAnimation { winnerHorse = at }
                
                for n in horseNodes.values {
                    n.isPaused = true
                }
            }
        }
        
        if currentTime - lastLeaderboardUpdate > 0.5 {
            let sortedHorses = atlar.sorted { horse1, horse2 in
                let pos1 = horseNodes[horse1.id]?.position.x ?? 0
                let pos2 = horseNodes[horse2.id]?.position.x ?? 0
                return pos1 > pos2
            }
            
            if currentRanking.map({ $0.id }) != sortedHorses.map({ $0.id }) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentRanking = sortedHorses
                }
            }
            lastLeaderboardUpdate = currentTime
        }
        
        let targetCamX = max(startX + 5, leaderX - 8.0)
        cameraNode.position.x += (targetCamX - cameraNode.position.x) * 0.05
    }
    
    private func resetSimulation() {
        winnerHorse = nil
        finishLineReached = false
        isSimulating = false
        setup3DScene()
        if let atlar = kosu.atlar {
            currentRanking = atlar
        }
    }
}

// MARK: - SCREEN ORIENTATION
extension SimulationViewHorse3D {
    private func forceLandscape() {
        AppDelegate.orientationLock = .landscape
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            if let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
    }
    
    private func restorePortrait() {
        AppDelegate.orientationLock = .portrait
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            if let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    
    private func safeDismiss() {
        restorePortrait()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dismiss() }
    }
}

// MARK: - PREVIEW
#Preview {
    let mockAtlar = (1...6).map { i in Horse(KOD: "\(i)", NO: "\(i)", AD: "AT \(i)", START: "\(i)", JOKEYADI: "JOKEY \(i)", AGF1: "5,00") }
    let mockRace = Race(KOD: "1", RACENO: "6", SAAT: "20:00", BILGI_TR: "SANLIURFA - 6. KOSU", MESAFE: "1900", atlar: mockAtlar) // Örnek olarak 1900m yapıldı
    return SimulationViewHorse3D(raceCity: "SANLIURFA", havaData: HavaData.default, kosu: mockRace).preferredColorScheme(.dark)
}
