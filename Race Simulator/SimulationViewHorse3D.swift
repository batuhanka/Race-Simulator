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
    
    // 3D Sahne ve Düğümler
    @State private var scene = SCNScene()
    @State private var horseNodes: [String: SCNNode] = [:]
    @State private var horseProgress: [String: CGFloat] = [:]
    
    // Zamanlayıcı (Hız ayarı buradan yapılır)
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    // Pist Uzunluğu
    let startX: Float = -12.0
    let finishX: Float = 12.0
    
    var body: some View {
        ZStack {
            Color(hex: "1A1A1A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                simulationHeader
                
                // MARK: - ORTA ALAN (3D SAHNE)
                SceneView(
                    scene: scene,
                    pointOfView: nil,
                    options: [.allowsCameraControl]
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "1A1A1A"))
                
                controlPanel
            }
            
            if let winner = winnerHorse {
                winnerOverlay(horse: winner)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setup3DScene()
        }
    }
}

// MARK: - COMPONENTS (Arayüz)
extension SimulationViewHorse3D {
    
    private var simulationHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(raceCity.uppercased(with: Locale(identifier: "tr_TR"))) - \(kosu.RACENO ?? "0"). KOŞU")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.cyan)
                Text(kosu.BILGI_TR ?? "SF Symbol 3D Yarışı")
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
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.3))
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
                    .frame(width: 200, height: 40)
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
                Text("🏆 KAZANAN 🏆").font(.title.bold()).foregroundColor(.yellow)
                
                Image(systemName: "figure.equestrian.sports")
                    .font(.system(size: 60)).foregroundColor(horse.horseColor)
                    .padding().background(Circle().fill(Color.white.opacity(0.1)))
                
                VStack(spacing: 5) {
                    Text(horse.AD ?? "-").font(.title2.bold()).foregroundColor(.white)
                    Text("Jokey: \(horse.JOKEYADI ?? "-")").font(.headline).foregroundColor(.cyan)
                    if let s = horse.START { Text("Kulvar: \(s)").foregroundColor(.gray) }
                }
                
                Button("DEVAM ET") { winnerHorse = nil }
                    .font(.headline).padding(.horizontal, 40).padding(.vertical, 12)
                    .background(Color.cyan).foregroundColor(.black).cornerRadius(10)
            }
        }
    }
}

// MARK: - 3D SCENE SETUP & LOGIC
extension SimulationViewHorse3D {
    
    // MARK: - SF SYMBOL TEXTURE GENERATOR
    private func createHorseFigureImage(color: UIColor, number: String) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            // Arka planı temizle (Şeffaflık için)
            ctx.cgContext.clearRect(CGRect(origin: .zero, size: size))
            
            // 1. SF Symbol'ü çiz
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 380, weight: .bold)
            if let symbolImage = UIImage(systemName: "figure.equestrian.sports", withConfiguration: symbolConfig)?.withTintColor(color) {
                let symbolRect = CGRect(x: 20, y: 50, width: 400, height: 400)
                symbolImage.draw(in: symbolRect)
            }
            
            // 2. Numarayı içine alacak beyaz daireyi çiz
            let circleRect = CGRect(x: 240, y: 120, width: 120, height: 120)
            UIColor.white.setFill()
            ctx.cgContext.fillEllipse(in: circleRect)
            
            // 3. Siyah numarayı dairenin içine yaz
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let font = UIFont.systemFont(ofSize: 80, weight: .black)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            let textStr = NSAttributedString(string: number, attributes: attributes)
            let textSize = textStr.size()
            let textRect = CGRect(x: circleRect.midX - textSize.width / 2,
                                  y: circleRect.midY - textSize.height / 2,
                                  width: textSize.width,
                                  height: textSize.height)
            textStr.draw(in: textRect)
        }
    }
    
    private func setup3DScene() {
        let newScene = SCNScene()
        newScene.background.contents = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)
        
        // 1. KAMERA
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 65
        cameraNode.position = SCNVector3(x: 0, y: 8, z: 16)
        cameraNode.eulerAngles = SCNVector3(x: -.pi / 7, y: 0, z: 0)
        newScene.rootNode.addChildNode(cameraNode)
        
        // 2. IŞIKLAR
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        newScene.rootNode.addChildNode(ambientLight)
        
        let dirLight = SCNNode()
        dirLight.light = SCNLight()
        dirLight.light?.type = .directional
        dirLight.light?.castsShadow = true
        dirLight.light?.shadowRadius = 10.0
        dirLight.position = SCNVector3(x: -10, y: 20, z: 5)
        dirLight.eulerAngles = SCNVector3(x: -.pi / 3, y: -.pi/6, z: 0)
        newScene.rootNode.addChildNode(dirLight)
        
        // 3. ZEMİN
        guard let atlar = kosu.atlar else { return }
        let spacing: Float = 2.2
        let totalZ = Float(atlar.count - 1) * spacing
        let startZ = -totalZ / 2.0
        
        // Kum Pist
        let trackGeo = SCNBox(width: CGFloat(finishX - startX + 10), height: 0.1, length: CGFloat(totalZ + 8), chamferRadius: 0)
        trackGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.6, green: 0.5, blue: 0.35, alpha: 1.0)
        let trackNode = SCNNode(geometry: trackGeo)
        trackNode.position = SCNVector3(0, -0.55, 0)
        trackNode.physicsBody = SCNPhysicsBody.static()
        newScene.rootNode.addChildNode(trackNode)
        
        // Çizgiler
        let lineGeo = SCNBox(width: 0.3, height: 0.12, length: CGFloat(totalZ + 8), chamferRadius: 0)
        let startLine = SCNNode(geometry: lineGeo)
        startLine.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
        startLine.position = SCNVector3(startX, -0.5, 0)
        newScene.rootNode.addChildNode(startLine)
        
        let finishLine = SCNNode(geometry: lineGeo)
        finishLine.geometry?.firstMaterial?.diffuse.contents = UIColor(patternImage: createCheckerPattern())
        finishLine.position = SCNVector3(finishX, -0.5, 0)
        newScene.rootNode.addChildNode(finishLine)
        
        // 4. AT FİGÜRLERİ
        for (index, at) in atlar.enumerated() {
            let planeGeo = SCNPlane(width: 2.2, height: 2.2)
            let figureImage = createHorseFigureImage(color: UIColor(at.horseColor), number: at.NO ?? "0")
            
            planeGeo.firstMaterial?.diffuse.contents = figureImage
            planeGeo.firstMaterial?.transparent.contents = figureImage
            planeGeo.firstMaterial?.isDoubleSided = true
            
            let planeNode = SCNNode(geometry: planeGeo)
            let zPos = startZ + Float(index) * spacing
            planeNode.position = SCNVector3(startX, 1.1, zPos)
            planeNode.castsShadow = true
            
            // Billboard Constraint (Kameraya dönük kalmasını sağlar)
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = .Y
            planeNode.constraints = [billboardConstraint]
            
            newScene.rootNode.addChildNode(planeNode)
            horseNodes[at.id] = planeNode
            horseProgress[at.id] = 0.0
        }
        
        self.scene = newScene
    }
    
    private func createCheckerPattern() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
        return renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
            ctx.fill(CGRect(x: 10, y: 10, width: 10, height: 10))
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 10, y: 0, width: 10, height: 10))
            ctx.fill(CGRect(x: 0, y: 10, width: 10, height: 10))
        }
    }
    
    private func updatePositions() {
        guard isSimulating && !finishLineReached else { return }
        guard let atlar = kosu.atlar else { return }
        
        for at in atlar {
            guard let node = horseNodes[at.id] else { continue }
            
            var baseSpeed = CGFloat.random(in: 0.0008...0.0025)
            
            if let agfStr = at.AGF1?.replacingOccurrences(of: ",", with: "."), let agfVal = Double(agfStr) {
                baseSpeed += CGFloat(agfVal / 100.0) * 0.004
            } else if let hStr = at.HANDIKAP, let hVal = Double(hStr) {
                baseSpeed += CGFloat(min(hVal, 100.0) / 100.0) * 0.003
            }
            
            let finalSpeed = baseSpeed + CGFloat.random(in: -0.0005...0.0015)
            let currentProg = horseProgress[at.id] ?? 0
            let newProg = currentProg + max(0.0005, finalSpeed)
            
            horseProgress[at.id] = newProg
            
            let newX = startX + (finishX - startX) * Float(min(newProg, 1.0))
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.02
            node.position.x = newX
            SCNTransaction.commit()
            
            if newProg >= 1.0 {
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
    let h1 = Horse(KOD: "1", NO: "1", AD: "ŞAMPİYON", START: "1", JOKEYADI: "H. KARATAŞ", AGF1: "25,50")
    let h2 = Horse(KOD: "2", NO: "2", AD: "RÜZGAR", START: "2", JOKEYADI: "S. KAYA", AGF1: "15,20")
    let h3 = Horse(KOD: "3", NO: "3", AD: "YILDIRIM", START: "3", JOKEYADI: "A. ÇELİK", AGF1: "10,00")
    
    let mockRace = Race(
        KOD: "999", RACENO: "4", SAAT: "15:30",
        BILGI_TR: "3 Yaşlı İngilizler - Şartlı 5", MESAFE: "1400",
        atlar: [h1, h2, h3]
    )
    
    SimulationViewHorse3D(
        raceCity: "İSTANBUL",
        havaData: HavaData.default,
        kosu: mockRace
    )
    .preferredColorScheme(.dark)
}