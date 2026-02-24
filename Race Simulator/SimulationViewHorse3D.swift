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
    
    @State private var hasRaceStarted: Bool = false
    
    @State private var currentRanking: [Horse] = []
    @State private var lastLeaderboardUpdate: TimeInterval = 0
    @State private var horseBaseSpeeds: [String: Float] = [:]
    
    // 3D Refs
    @State private var scene = SCNScene()
    @State private var horseNodes: [String: SCNNode] = [:]
    @State private var cameraNode = SCNNode()
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
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
                
                ZStack(alignment: .bottomTrailing) {
                    HStack {
                        leaderboardHUD
                        Spacer()
                    }
                    
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
                    Text("\(raceCity.uppercased(with: Locale(identifier: "tr_TR")))")
                        .font(.system(size: 14, weight: .black)).foregroundColor(Color.cyan)
                    Text(kosu.BILGI_TR ?? "3D Simülasyon")
                        .font(.system(size: 10, weight: .medium)).foregroundColor(Color.white.opacity(0.6))
                }
            }
            
            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 4).fill(Color.cyan).frame(width: 4, height: 24)
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
                if !hasRaceStarted {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasRaceStarted = true
                    }
                }
                
                isSimulating.toggle()
                for node in horseNodes.values {
                    node.isPaused = !isSimulating
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: finishLineReached ? "arrow.counterclockwise" : (isSimulating ? "pause.fill" : "play.fill"))
                Text(finishLineReached ? "TEKRARLA" : (isSimulating ? "DURAKLAT" : "START VER"))
            }
            .font(.system(size: 14, weight: .black)).foregroundColor(Color.black)
            .frame(width: 180, height: 44)
            .background(finishLineReached ? Color.white : Color.cyan)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 4)
        }
    }
    
    // YENİ: Taşkınlık korumalı (ScrollView) ve Daha Zarif Dinamik Boşluklu HUD
        private var leaderboardHUD: some View {
            let topHorses = hasRaceStarted ? Array(currentRanking.prefix(5)) : currentRanking
            let displayedCount = topHorses.count
            
            // Boşlukları daha da daralttık
            let vSpacing: CGFloat = displayedCount > 12 ? 1 : (displayedCount > 5 ? 2 : 4)
            
            return ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: vSpacing) {
                    //Text(hasRaceStarted ? "CANLI SIRALAMA" : "START LİSTESİ")
                    //    .font(.system(size: 9, weight: .black)) // Başlık 10'dan 9'a düşürüldü
                    //    .foregroundColor(Color.white.opacity(0.7))
                    //    .padding(.bottom, 2)
                    
                    ForEach(Array(topHorses.enumerated()), id: \.element.id) { index, horse in
                        leaderboardRow(index: index, horse: horse, displayedCount: displayedCount)
                    }
                    
                }
                .padding(.leading, 16)
            }
            .frame(maxHeight: 260)
        }
        
        // YENİ: Küçültülmüş EA FC Tarzı Formalı Satır
        private func leaderboardRow(index: Int, horse: Horse, displayedCount: Int) -> some View {
            let isUltraCompact = displayedCount > 12
            let isCompact = displayedCount > 5 && displayedCount <= 12
            
            // YAZI VE KUTU BOYUTLARI ÇOK DAHA KİBAR HALE GETİRİLDİ
            let rowHeight: CGFloat = isUltraCompact ? 22 : (isCompact ? 30 : 40)
            let rankSize: CGFloat = isUltraCompact ? 8 : (isCompact ? 9 : 11)
            let noSize: CGFloat = isUltraCompact ? 14 : (isCompact ? 18 : 22)
            let nameSize: CGFloat = isUltraCompact ? 9 : (isCompact ? 10 : 12)
            let jockeySize: CGFloat = isUltraCompact ? 0 : (isCompact ? 8 : 9)
            let cardWidth: CGFloat = 180 // Genişlik 200'den 180'e çekilerek piste yer açıldı
            
            return ZStack(alignment: .leading) {
                // 1. ARKA PLAN: Forma Görseli (Tüm satırı kaplar)
                if let formaLink = horse.FORMA, let url = URL(string: formaLink) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Color(horse.horseColor).opacity(0.5)
                        }
                    }
                    .frame(width: cardWidth, height: rowHeight)
                    .clipped()
                } else {
                    Color(horse.horseColor).opacity(0.5).frame(width: cardWidth, height: rowHeight)
                }
                
                // 2. GÖLGE KATMANI: Siyah Gradient (Okunabilirliği artırır)
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.95), Color.black.opacity(0.7), Color.clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: cardWidth, height: rowHeight)
                
                // 3. İÇERİK
                HStack(spacing: 6) { // Elemanlar arası boşluk 8'den 6'ya düşürüldü
                    // Sıra Numarası (Cyan)
                    Text("\(index + 1)")
                        .font(.system(size: rankSize, weight: .bold))
                        .foregroundColor(Color.cyan)
                        .frame(width: 14, alignment: .leading)
                    
                    // Yarış Numarası (Büyük İtalik EA Style)
                    Text(horse.NO ?? "0")
                        .font(.system(size: noSize, weight: .heavy))
                        .italic()
                        .foregroundColor(.white)
                        .frame(width: isUltraCompact ? 20 : 26, alignment: .center)
                        .minimumScaleFactor(0.5) // Sığmazsa küçül
                        .lineLimit(1)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                    
                    // İsimler
                    VStack(alignment: .leading, spacing: 0) { // VStack boşluğu sıfırlandı
                        Text(horse.AD ?? "-")
                            .font(.system(size: nameSize, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        if !isUltraCompact { // Çok kalabalık modda yer açmak için jokey ismini gizliyoruz
                            Text(horse.JOKEYADI ?? "-")
                                .font(.system(size: jockeySize, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 6)
            }
            .frame(width: cardWidth, height: rowHeight)
            .cornerRadius(isUltraCompact ? 4 : 8)
            .overlay(
                RoundedRectangle(cornerRadius: isUltraCompact ? 4 : 8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            // Sıralama değiştiğinde yukarı aşağı kayma animasyonu
            .animation(.easeInOut(duration: 0.3), value: currentRanking.map { $0.id })
        }
    
    private func winnerOverlay(horse: Horse) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("PHOTO FINISH").font(.system(size: 14, weight: .black)).foregroundColor(Color.cyan).tracking(4)
                
                HStack(spacing: 20) {
                    Text(horse.NO ?? "0")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    jerseyImageView(url: horse.FORMA, size: 80)
                }
                
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
    
    // Winner ekranı için eski yuvarlak ikon fonksiyonunu burada tuttuk
    @ViewBuilder
    private func jerseyImageView(url: String?, size: CGFloat) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.gray)
            case .empty:
                ProgressView().frame(width: size, height: size)
            @unknown default:
                EmptyView()
            }
        }
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
    
    private func createDistanceMarkerTexture(text: String) -> UIImage {
        let size = CGSize(width: 200, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 10).fill()
            
            UIColor.white.setStroke()
            let border = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: 4, dy: 4), cornerRadius: 8)
            border.lineWidth = 4
            border.stroke()
            
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
        
        let realDistance = Float(kosu.MESAFE ?? "1200") ?? 1200.0
        let distanceSpan = finishX - startX
        
        let markerDistances = stride(from: 200, to: Int(realDistance), by: 200)
        
        for dist in markerDistances {
            let ratio = Float(dist) / realDistance
            let markerX = finishX - (ratio * distanceSpan)
            
            let boardGeo = SCNPlane(width: 1.8, height: 0.9)
            boardGeo.firstMaterial?.diffuse.contents = createDistanceMarkerTexture(text: "\(dist)")
            let boardNode = SCNNode(geometry: boardGeo)
            boardNode.position = SCNVector3(markerX, 1.0, startZ - 1.4)
            
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
            
            let horseModelNode = getHorseModel(at: at)
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
    
    private func getHorseModel(at: Horse) -> SCNNode {
        let finalNode = SCNNode()
        
        if let horseScene = SCNScene(named: "thehorse.usdz") {
            let wrapperNode = SCNNode()
            for child in horseScene.rootNode.childNodes {
                wrapperNode.addChildNode(child.clone())
            }
            
            wrapperNode.scale = SCNVector3(0.01, 0.01, 0.01)
            wrapperNode.eulerAngles = SCNVector3(0, Float.pi / 2, 0)
            
            var realisticCoatColor = UIColor(at.coatTheme.bg)
            
            if at.coatTheme.bg == .clear {
                realisticCoatColor = UIColor(red: 0.50, green: 0.25, blue: 0.15, alpha: 1.0)
            }
            
            wrapperNode.enumerateChildNodes { (child, _) in
                if let geometry = child.geometry {
                    for material in geometry.materials {
                        let matName = material.name?.lowercased() ?? ""
                        if !matName.contains("jockey") && !matName.contains("saddle") && !matName.contains("cloth") {
                            material.multiply.contents = realisticCoatColor
                        }
                    }
                }
            }
            
            finalNode.addChildNode(wrapperNode)
        }
        
        return finalNode
    }
    
    /*
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
    */
    
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
        
        withAnimation {
            hasRaceStarted = false
        }
        
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
    let mockAtlar = (1...20).map { i in
        Horse(
            KOD: "\(i)",
            NO: "\(i)",
            AD: "AT \(i)",
            START: "\(i)",
            JOKEYADI: "JOKEY \(i)",
            FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg"
        )
    }
    let mockRace = Race(KOD: "1", RACENO: "6", SAAT: "20:00", BILGI_TR: "SANLIURFA - 6. KOSU", MESAFE: "1900", atlar: mockAtlar)
    
    // YENİ: Başındaki "return" kelimesi silindi!
    SimulationViewHorse3D(raceCity: "SANLIURFA", havaData: HavaData.default, kosu: mockRace)
        .preferredColorScheme(.dark)
}
