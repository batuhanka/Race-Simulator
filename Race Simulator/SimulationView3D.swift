import SwiftUI
import SceneKit

struct SimulationView3D: View {
    // MARK: - PROPERTIES
    let raceCity: String
    let havaData: HavaData
    let kosu: Race
    
    @Environment(\.dismiss) var dismiss
    @State private var isSimulating: Bool = false
    @State private var finishLineReached: Bool = false
    @State private var winnerHorse: Horse? = nil
    
    @State private var scene = SCNScene()
    @State private var horseNodes: [String: SCNNode] = [:]
    @State private var horseProgress: [String: CGFloat] = [:]
    
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    // Pist Uzunluğu - Landscape için biraz daha genişlettik
    let startX: Float = -15.0
    let finishX: Float = 15.0
    
    var body: some View {
        ZStack {
            Color(hex: "1A1A1A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                simulationHeader
                
                // MARK: - ORTA ALAN (3D SAHNE)
                SceneView(
                    scene: scene,
                    pointOfView: nil,
                    options: []
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "1A1A1A"))
                .padding(.top, -30) // Üst boşluğu kapatır
                
                controlPanel
            }
            
            if let winner = winnerHorse {
                winnerOverlay(horse: winner)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            forceLandscape()
            setup3DScene()
        }
        .onDisappear {
            restorePortrait()
        }
    }
}

// MARK: - EKRAN YÖNÜ KONTROLÜ
extension SimulationView3D {
    private func forceLandscape() {
        AppDelegate.orientationLock = .landscape
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    private func restorePortrait() {
        AppDelegate.orientationLock = .portrait
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}

// MARK: - COMPONENTS
extension SimulationView3D {
    private var simulationHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(raceCity.uppercased(with: Locale(identifier: "tr_TR"))) - \(kosu.RACENO ?? "0"). KOŞU")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.cyan)
                Text(kosu.BILGI_TR ?? "")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
            HStack(spacing: 15) {
                Label("\(havaData.sicaklik)°C", systemImage: "thermometer.medium")
                Text(havaData.havaTr)
            }
            .font(.caption2.bold())
            .foregroundColor(.cyan)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3).foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.8))
    }
    
    private var controlPanel: some View {
        HStack {
            Button(action: { finishLineReached ? resetSimulation() : isSimulating.toggle() }) {
                Label(finishLineReached ? "TEKRARLA" : (isSimulating ? "DURAKLAT" : "START VER"),
                      systemImage: finishLineReached ? "arrow.counterclockwise" : (isSimulating ? "pause.fill" : "play.fill"))
                    .font(.system(size: 14, weight: .black))
                    .frame(width: 250, height: 40)
                    .background(finishLineReached ? Color.white : (isSimulating ? Color.orange : Color.cyan))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .onReceive(timer) { _ in updatePositions() }
    }
    
    private func winnerOverlay(horse: Horse) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("🏆 KAZANAN 🏆").font(.largeTitle.bold()).foregroundColor(.yellow)
                Circle()
                    .fill(horse.horseColor)
                    .frame(width: 100, height: 100)
                    .overlay(Text(horse.NO ?? "0").font(.largeTitle.weight(.black)).foregroundColor(.black))
                    .padding().background(Circle().fill(Color.white.opacity(0.1)))
                
                VStack(spacing: 5) {
                    Text(horse.AD ?? "-").font(.title.bold()).foregroundColor(.white)
                    Text("Jokey: \(horse.JOKEYADI ?? "-")").font(.title3).foregroundColor(.cyan)
                }
                Button("DEVAM ET") { dismiss() }
                    .font(.headline).padding(.horizontal, 50).padding(.vertical, 15)
                    .background(Color.cyan).foregroundColor(.black).cornerRadius(10)
            }
        }
    }
}

// MARK: - 3D LOGIC
extension SimulationView3D {
    private func createBilliardTexture(number: String, color: UIColor) -> UIImage {
        let size = CGSize(width: 1024, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill(); ctx.fill(CGRect(origin: .zero, size: size))
            let ovalRect = CGRect(x: size.width / 2 - 100, y: size.height / 2 - 80, width: 200, height: 160)
            UIColor.white.setFill(); ctx.cgContext.fillEllipse(in: ovalRect)
            let paragraphStyle = NSMutableParagraphStyle(); paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 110, weight: .black),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            let textStr = NSAttributedString(string: number, attributes: attributes)
            let textSize = textStr.size()
            textStr.draw(in: CGRect(x: ovalRect.midX - textSize.width / 2, y: ovalRect.midY - textSize.height / 2, width: textSize.width, height: textSize.height))
        }
    }
    
    private func setup3DScene() {
        let newScene = SCNScene()
        newScene.background.contents = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)
        
        guard let atlar = kosu.atlar else { return }
        let horseCount = atlar.count
        let spacing: Float = horseCount > 10 ? 1.6 : 2.2
        let totalZ = Float(horseCount - 1) * spacing
        let startZ = -totalZ / 2.0
        
        // --- KAMERA AYARI (Perspektif ve Zoom) ---
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = 55 // Biraz daha odaklanmış bir açı
        cameraNode.camera = camera
        
        // Kamerayı biraz çaprazdan ve yukarıdan bakacak şekilde konumlandırıyoruz
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 18)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi / 4, y: 0, z: 0)
        newScene.rootNode.addChildNode(cameraNode)
        
        // Işıklar
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight(); ambientLight.light?.type = .ambient; ambientLight.light?.color = UIColor(white: 0.6, alpha: 1.0)
        newScene.rootNode.addChildNode(ambientLight)
        
        let dirLight = SCNNode()
        dirLight.light = SCNLight(); dirLight.light?.type = .directional; dirLight.light?.castsShadow = true
        dirLight.position = SCNVector3(0, 20, 10); dirLight.eulerAngles = SCNVector3(-Float.pi/3, 0, 0)
        newScene.rootNode.addChildNode(dirLight)
        
        // --- PİST (Siyah-Kahve Tonu) ---
        let trackLength = CGFloat(totalZ + 8)
        let trackGeo = SCNBox(width: 100, height: 0.1, length: trackLength, chamferRadius: 0)
        trackGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1.0)
        let trackNode = SCNNode(geometry: trackGeo); trackNode.position = SCNVector3(0, -0.5, 0)
        newScene.rootNode.addChildNode(trackNode)
        
        // Çizgiler
        let startLineGeo = SCNBox(width: 0.6, height: 0.15, length: trackLength, chamferRadius: 0)
        startLineGeo.firstMaterial?.diffuse.contents = UIColor.white
        let startLineNode = SCNNode(geometry: startLineGeo); startLineNode.position = SCNVector3(startX, -0.45, 0)
        newScene.rootNode.addChildNode(startLineNode)
        
        let finishLineGeo = SCNBox(width: 0.6, height: 0.15, length: trackLength, chamferRadius: 0)
        finishLineGeo.firstMaterial?.diffuse.contents = UIColor.red
        let finishNode = SCNNode(geometry: finishLineGeo); finishNode.position = SCNVector3(finishX, -0.45, 0)
        newScene.rootNode.addChildNode(finishNode)
        
        // Bilardo Topları
        for (index, at) in atlar.enumerated() {
            let sphereGeo = SCNSphere(radius: 0.6)
            let ballTexture = createBilliardTexture(number: at.NO ?? "0", color: UIColor(at.horseColor))
            sphereGeo.firstMaterial?.diffuse.contents = ballTexture
            sphereGeo.firstMaterial?.specular.contents = UIColor.white
            sphereGeo.firstMaterial?.shininess = 0.8
            
            let sphereNode = SCNNode(geometry: sphereGeo)
            let zPos = startZ + Float(index) * spacing
            sphereNode.position = SCNVector3(startX, 0.1, zPos)
            sphereNode.castsShadow = true
            newScene.rootNode.addChildNode(sphereNode)
            
            horseNodes[at.id] = sphereNode
            horseProgress[at.id] = 0.0
        }
        self.scene = newScene
    }
    
    private func updatePositions() {
        guard isSimulating && !finishLineReached else { return }
        guard let atlar = kosu.atlar else { return }
        
        for at in atlar {
            guard let node = horseNodes[at.id] else { continue }
            var baseSpeed = CGFloat.random(in: 0.002...0.007)
            if let agfStr = at.AGF1?.replacingOccurrences(of: ",", with: "."), let agfVal = Double(agfStr) {
                baseSpeed += CGFloat(agfVal / 100.0) * 0.012
            }
            let currentProg = (horseProgress[at.id] ?? 0) + baseSpeed + CGFloat.random(in: -0.001...0.004)
            horseProgress[at.id] = currentProg
            
            let newX = startX + (finishX - startX) * Float(min(currentProg, 1.0))
            
            // Yuvarlanma efekti (X eksenindeki ilerlemeye göre kendi ekseninde dönme)
            let rotationAngle = -newX * 1.5
            node.eulerAngles = SCNVector3(x: 0, y: 0, z: rotationAngle)
            
            SCNTransaction.begin(); SCNTransaction.animationDuration = 0.02
            node.position.x = newX
            SCNTransaction.commit()
            
            if currentProg >= 1.0 {
                isSimulating = false
                finishLineReached = true
                withAnimation(.spring()) { winnerHorse = at }
                break
            }
        }
    }
    
    private func resetSimulation() {
        winnerHorse = nil
        finishLineReached = false
        isSimulating = false
        setup3DScene()
    }
}

// MARK: - PREVIEW
#Preview {
    // 1. Sahte (Mock) Atlar Oluşturalım
    let h1 = Horse(KOD: "1", NO: "1", AD: "ŞAMPİYON", START: "1", JOKEYADI: "H. KARATAŞ", AGF1: "25,50")
    let h2 = Horse(KOD: "2", NO: "2", AD: "RÜZGAR", START: "2", JOKEYADI: "S. KAYA", AGF1: "15,20")
    let h3 = Horse(KOD: "3", NO: "3", AD: "YILDIRIM", START: "3", JOKEYADI: "A. ÇELİK", AGF1: "10,00")
    let h4 = Horse(KOD: "4", NO: "4", AD: "FIRTINA", START: "4", JOKEYADI: "V. ABİŞ", AGF1: "8,50")
    let h5 = Horse(KOD: "5", NO: "5", AD: "KARA YEL", START: "5", JOKEYADI: "G. KOCAKAYA", AGF1: "5,10")
    
    // 2. Sahte (Mock) Koşu Oluşturalım
    let mockRace = Race(
        KOD: "999",
        RACENO: "4",
        SAAT: "15:30",
        BILGI_TR: "3 Yaşlı İngilizler - Şartlı 5",
        MESAFE: "1400",
        atlar: [h1, h2, h3, h4, h5]
    )
    
    // 3. View'ı Çağıralım
    SimulationView3D(
        raceCity: "İSTANBUL",
        havaData: HavaData.default,
        kosu: mockRace
    )
    .preferredColorScheme(.dark)
}
