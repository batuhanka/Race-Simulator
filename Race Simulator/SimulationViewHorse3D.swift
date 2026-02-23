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
    
    // Canlı sıralamayı tutacak dizi
    @State private var currentRanking: [Horse] = []
    
    // 3D Refs
    @State private var scene = SCNScene()
    @State private var horseNodes: [String: SCNNode] = [:]
    @State private var horseProgress: [String: Float] = [:]
    @State private var cameraNode = SCNNode()
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Pist sınırları
    let startX: Float = -22.0
    let finishX: Float = 22.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                simulationHeader
                
                // MARK: - 3D SAHNE
                SceneView(
                    scene: scene,
                    pointOfView: cameraNode,
                    options: [.allowsCameraControl],
                    preferredFramesPerSecond: 60
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .padding(.top, -50)
                
                controlPanel
            }
            
            // CANLI SIRALAMA EKRANI (Sol Alt Köşe)
            VStack {
                Spacer()
                HStack {
                    leaderboardHUD
                    Spacer()
                }
            }
            .padding(.bottom, 80) // Kontrol panelinin üstünde durması için
            
            if let winner = winnerHorse {
                winnerOverlay(horse: winner)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            forceLandscape()
            setup3DScene()
            if let atlar = kosu.atlar {
                currentRanking = atlar // Başlangıçta listeyi doldur
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
                        .font(.system(size: 14, weight: .black)).foregroundColor(.cyan)
                    Text(kosu.BILGI_TR ?? "3D Simülasyon")
                        .font(.system(size: 10, weight: .medium)).foregroundColor(.white.opacity(0.6))
                }
            }
            Spacer()
            HStack(spacing: 20) {
                HStack(spacing: 6) { Image(systemName: "thermometer.medium"); Text("\(havaData.sicaklik)°C") }
                Text(havaData.havaTr.uppercased())
            }
            .font(.system(size: 12, weight: .bold)).foregroundColor(.cyan)
            Spacer()
            Button { safeDismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .padding(8).background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 12)
        .background(LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom))
        .zIndex(10)
    }
    
    private var controlPanel: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.bottom)
            Button(action: { finishLineReached ? resetSimulation() : isSimulating.toggle() }) {
                HStack(spacing: 12) {
                    Image(systemName: finishLineReached ? "arrow.counterclockwise" : (isSimulating ? "pause.fill" : "play.fill"))
                    Text(finishLineReached ? "TEKRARLA" : (isSimulating ? "DURAKLAT" : "START VER"))
                }
                .font(.system(size: 14, weight: .black)).foregroundColor(.black)
                .frame(width: 250, height: 44).background(finishLineReached ? Color.white : Color.cyan)
                .clipShape(Capsule())
            }
        }
        .frame(height: 70)
        .onReceive(timer) { _ in updateRaceLogic() }
    }
    
    // YENİ: Canlı Sıralama Arayüzü (İlk 5 Atı Gösterir)
    private var leaderboardHUD: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CANLI SIRALAMA")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 2)
            
            ForEach(Array(currentRanking.prefix(5).enumerated()), id: \.element.id) { index, horse in
                HStack(spacing: 8) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.cyan)
                        .frame(width: 12, alignment: .leading)
                    
                    // Forma Rengi ve Numarası
                    Circle()
                        .fill(horse.horseColor)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text(horse.NO ?? "0")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(isLightColor(horse.horseColor) ? .black : .white)
                        )
                    
                    Text(horse.AD ?? "At")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.5))
                .cornerRadius(6)
            }
        }
        .padding(.leading, 16)
    }
    
    private func winnerOverlay(horse: Horse) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("PHOTO FINISH").font(.system(size: 14, weight: .black)).foregroundColor(.cyan).tracking(4)
                
                // Kazanan ekranı için basit bir forma gösterimi (Büyük çıkartma yerine)
                Circle()
                    .fill(horse.horseColor)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(horse.NO ?? "0")
                            .font(.system(size: 60, weight: .black))
                            .foregroundColor(isLightColor(horse.horseColor) ? .black : .white)
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                
                VStack(spacing: 8) {
                    Text(horse.AD ?? "-").font(.system(size: 32, weight: .black)).foregroundColor(.white)
                    Text("JOKEY: \(horse.JOKEYADI ?? "-")").font(.system(size: 18, weight: .bold)).foregroundColor(.cyan)
                }
                
                Button("SIRALAMAYI GÖR") { safeDismiss() }
                    .font(.system(size: 14, weight: .black)).padding(.horizontal, 50).padding(.vertical, 14)
                    .background(Color.white).foregroundColor(.black).cornerRadius(30)
            }
        }
    }
    
    // Yazı rengi kontrastı için yardımcı fonksiyon
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
    
    private func setup3DScene() {
        let newScene = SCNScene()
        
        // Gökyüzü (Koyu gri/mavi tonları - Gece veya akşam üstü hissi için)
        newScene.background.contents = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        
        guard let atlar = kosu.atlar else { return }
        let horseCount = atlar.count
        
        let spacing: Float = horseCount > 10 ? 1.5 : 2.0
        let totalZ = Float(horseCount - 1) * spacing
        let startZ = -totalZ / 2.0
        let trackLength = Float(totalZ + 10)
        
        // Kamera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 50
        cameraNode.position = SCNVector3(x: startX + 5, y: 11, z: 16)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi/6, y: -Float.pi/10, z: 0)
        newScene.rootNode.addChildNode(cameraNode)
        
        // Işıklar
        let ambient = SCNNode(); ambient.light = SCNLight(); ambient.light?.type = .ambient; ambient.light?.intensity = 150
        newScene.rootNode.addChildNode(ambient)
        
        let pointLight = SCNNode(); pointLight.light = SCNLight(); pointLight.light?.type = .omni; pointLight.light?.intensity = 800
        pointLight.position = SCNVector3(x: 0, y: 20, z: 10)
        newScene.rootNode.addChildNode(pointLight)
        
        // YENİ: Çim Zemin (Grass) - Gökyüzünde koşmayı engeller
        let grassGeo = SCNPlane(width: 300, height: 300)
        grassGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 1.0)
        let grassNode = SCNNode(geometry: grassGeo)
        grassNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
        grassNode.position = SCNVector3(0, -0.15, 0) // Pistin hemen altı
        newScene.rootNode.addChildNode(grassNode)
        
        // Pist
        let trackGeo = SCNPlane(width: 200, height: CGFloat(trackLength + 2.0))
        trackGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.25, green: 0.18, blue: 0.12, alpha: 1.0) // Kum rengini biraz açtık
        let trackNode = SCNNode(geometry: trackGeo); trackNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0); trackNode.position = SCNVector3(0, -0.1, 0)
        newScene.rootNode.addChildNode(trackNode)
        
        // YENİ: Beyaz Bariyerler (Fences)
        let barrierLength = CGFloat(200) // Pistin X eksenindeki tam boyu
        let barrierGeo = SCNBox(width: barrierLength, height: 0.6, length: 0.2, chamferRadius: 0.05)
        barrierGeo.firstMaterial?.diffuse.contents = UIColor.white
        
        let frontBarrier = SCNNode(geometry: barrierGeo)
        frontBarrier.position = SCNVector3(0, 0.2, startZ + totalZ + 1.5) // Kameraya yakın olan taraf
        newScene.rootNode.addChildNode(frontBarrier)
        
        let backBarrier = SCNNode(geometry: barrierGeo)
        backBarrier.position = SCNVector3(0, 0.2, startZ - 1.5) // Uzak olan taraf
        newScene.rootNode.addChildNode(backBarrier)
        
        // Bitiş Çizgisi
        let finishGeo = SCNBox(width: 1.0, height: 0.05, length: Double(trackLength), chamferRadius: 0)
        let finishMaterial = SCNMaterial()
        finishMaterial.diffuse.contents = createCheckerboardTexture()
        finishMaterial.diffuse.wrapS = .repeat; finishMaterial.diffuse.wrapT = .repeat
        finishMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(2, Float(trackLength) / 1.5, 1)
        finishGeo.materials = [finishMaterial]
        let finishNode = SCNNode(geometry: finishGeo); finishNode.position = SCNVector3(finishX, 0, 0)
        newScene.rootNode.addChildNode(finishNode)
        
        // Atları Sahneye Ekleme
        for (index, at) in atlar.enumerated() {
            let container = SCNNode()
            let zPos = startZ + Float(index) * spacing
            container.position = SCNVector3(startX, 0, zPos)
            
            let horseModelNode = getHorseModel(number: at.NO ?? "0")
            
            container.addChildNode(horseModelNode)
            newScene.rootNode.addChildNode(container)
            
            horseNodes[at.id] = container
            horseProgress[at.id] = 0.0
        }
        self.scene = newScene
    }
    
    // Çıkartma iptal edildi, sadece model don rengine boyanıyor
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
                UIColor(red: 0.35, green: 0.20, blue: 0.10, alpha: 1.0), // Koyu Doru
                UIColor(red: 0.60, green: 0.30, blue: 0.15, alpha: 1.0), // Al
                UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0), // Kır
                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0), // Yağız
                UIColor(red: 0.50, green: 0.25, blue: 0.15, alpha: 1.0)  // Doru
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
        
        for at in atlar {
            guard let node = horseNodes[at.id] else { continue }
            
            var speed = Float.random(in: 0.03...0.06)
            if let agf = Float(at.AGF1?.replacingOccurrences(of: ",", with: ".") ?? "0") {
                speed += (agf / 100.0) * 0.02
            }
            
            node.position.x += speed
            if node.position.x > leaderX { leaderX = node.position.x }
            
            if node.position.x >= finishX {
                isSimulating = false
                finishLineReached = true
                withAnimation { winnerHorse = at }
            }
        }
        
        // YENİ: Anlık sıralamayı güncelleme
        let sortedHorses = atlar.sorted { horse1, horse2 in
            let pos1 = horseNodes[horse1.id]?.position.x ?? 0
            let pos2 = horseNodes[horse2.id]?.position.x ?? 0
            return pos1 > pos2
        }
        currentRanking = sortedHorses
        
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
    let mockRace = Race(KOD: "1", RACENO: "6", SAAT: "20:00", BILGI_TR: "SANLIURFA - 6. KOSU", MESAFE: "1200", atlar: mockAtlar)
    return SimulationViewHorse3D(raceCity: "SANLIURFA", havaData: HavaData.default, kosu: mockRace).preferredColorScheme(.dark)
}
