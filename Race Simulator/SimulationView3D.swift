import SwiftUI
import SceneKit // 3D Kütüphanesi

struct SimulationView3D: View {
    // MARK: - PROPERTIES
    let raceCity: String
    let havaData: HavaData
    let kosu: Race
    
    @Environment(\.dismiss) var dismiss
    
    // UI Durumları
    @State private var isSimulating: Bool = false
    @State private var finishLineReached: Bool = false
    @State private var winnerHorse: Horse? = nil
    
    // 3D Sahne ve Düğümler (Nodes)
    @State private var scene = SCNScene()
    @State private var horseNodes: [String: SCNNode] = [:]
    @State private var horseProgress: [String: CGFloat] = [:] // 0.0'dan 1.0'a ilerleme
    
    // Zamanlayıcı
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    // Pisti boyutları
    let startX: Float = -10.0
    let finishX: Float = 10.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // MARK: - 3D SAHNE GÖRÜNÜMÜ
            SceneView(
                scene: scene,
                pointOfView: nil, // Kamerayı otomatik ayarlar
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .ignoresSafeArea()
            
            // MARK: - ARAYÜZ (UI) OVERYLAY
            VStack(spacing: 0) {
                simulationHeader
                Spacer()
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

// MARK: - 3D SCENE SETUP
extension SimulationView3D {
    private func setup3DScene() {
        let newScene = SCNScene()
        
        // 1. KAMERA AYARLARI (Yarışı çaprazdan ve yukarıdan izleyen kamera)
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 12, z: 15)
        cameraNode.eulerAngles = SCNVector3(x: -.pi / 5, y: 0, z: 0) // Kamerayı hafif aşağı eğ
        newScene.rootNode.addChildNode(cameraNode)
        
        // 2. IŞIK AYARLARI
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0)
        newScene.rootNode.addChildNode(ambientLight)
        
        let dirLight = SCNNode()
        dirLight.light = SCNLight()
        dirLight.light?.type = .directional
        dirLight.light?.castsShadow = true // Gölgeleri aç
        dirLight.position = SCNVector3(x: 0, y: 20, z: 10)
        dirLight.eulerAngles = SCNVector3(x: -.pi / 3, y: 0, z: 0)
        newScene.rootNode.addChildNode(dirLight)
        
        // 3. PİST ZEMİNİ (Koyu yeşil/gri bir zemin)
        guard let atlar = kosu.atlar else { return }
        let trackWidth: CGFloat = CGFloat(atlar.count) * 1.8 + 2.0
        
        let trackGeo = SCNBox(width: 26, height: 0.2, length: trackWidth, chamferRadius: 0)
        trackGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.25, blue: 0.2, alpha: 1.0)
        let trackNode = SCNNode(geometry: trackGeo)
        trackNode.position = SCNVector3(0, -0.5, 0)
        newScene.rootNode.addChildNode(trackNode)
        
        // 4. BİTİŞ ÇİZGİSİ (Kırmızı bir bant)
        let finishGeo = SCNBox(width: 0.4, height: 0.25, length: trackWidth, chamferRadius: 0)
        finishGeo.firstMaterial?.diffuse.contents = UIColor.red
        let finishNode = SCNNode(geometry: finishGeo)
        finishNode.position = SCNVector3(finishX, -0.5, 0)
        newScene.rootNode.addChildNode(finishNode)
        
        // 5. ATLAR (KÜRELER) VE NUMARALARI
        let spacing: Float = 1.6
        let startZ = -Float(atlar.count - 1) * spacing / 2.0
        
        for (index, at) in atlar.enumerated() {
            // Küre Geometrisi
            let sphereGeo = SCNSphere(radius: 0.4)
            sphereGeo.firstMaterial?.diffuse.contents = at.uiColor // Rengi ata göre ata
            sphereGeo.firstMaterial?.specular.contents = UIColor.white // Parlaklık
            
            let sphereNode = SCNNode(geometry: sphereGeo)
            let zPos = startZ + Float(index) * spacing
            sphereNode.position = SCNVector3(startX, 0, zPos)
            sphereNode.castsShadow = true
            
            // Kürenin Üzerine At Numarasını Ekle (3D Text)
            let textGeo = SCNText(string: at.NO ?? "0", extrusionDepth: 0.1)
            textGeo.font = UIFont.boldSystemFont(ofSize: 0.6)
            textGeo.firstMaterial?.diffuse.contents = UIColor.white
            
            let textNode = SCNNode(geometry: textGeo)
            // Metni tam ortalamak için pivot ayarı:
            let (min, max) = textNode.boundingBox
            textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x)/2, 0, 0)
            textNode.position = SCNVector3(0, 0.7, 0) // Kürenin hemen üstü
            textNode.eulerAngles = SCNVector3(x: -.pi / 8, y: 0, z: 0) // Kameraya doğru hafif eğik
            
            sphereNode.addChildNode(textNode)
            newScene.rootNode.addChildNode(sphereNode)
            
            // Referansları sakla
            horseNodes[at.id] = sphereNode
            horseProgress[at.id] = 0.0
        }
        
        self.scene = newScene
    }
}

// MARK: - SIMULATION LOGIC
extension SimulationView3D {
    
    private func updatePositions() {
        guard isSimulating && !finishLineReached else { return }
        guard let atlar = kosu.atlar else { return }
        
        for at in atlar {
            guard let node = horseNodes[at.id] else { continue }
            
            // AGF / Handikap Mantığı (Senin önceki başarılı algoritman)
            var baseSpeed = CGFloat.random(in: 0.002...0.007)
            
            if let agfStr = at.AGF1?.replacingOccurrences(of: ",", with: "."), let agfVal = Double(agfStr) {
                baseSpeed += CGFloat(agfVal / 100.0) * 0.012
            } else if let hStr = at.HANDIKAP, let hVal = Double(hStr) {
                baseSpeed += CGFloat(min(hVal, 100.0) / 100.0) * 0.008
            }
            
            let finalSpeed = baseSpeed + CGFloat.random(in: -0.001...0.005)
            
            // İlerlemeyi Güncelle
            let currentProg = horseProgress[at.id] ?? 0
            let newProg = currentProg + max(0.001, finalSpeed)
            horseProgress[at.id] = newProg
            
            // İlerlemeyi 3D X Koordinatına Çevir (-10'dan +10'a)
            // Interpolasyon: startX + (finishX - startX) * ilerleme
            let newX = startX + (finishX - startX) * Float(min(newProg, 1.0))
            
            // Küreyi Z ekseninde döndür (Koşuyormuş, yuvarlanıyormuş hissi vermek için)
            let rotationAngle = -newX * 2.0
            node.eulerAngles = SCNVector3(x: 0, y: 0, z: rotationAngle)
            
            // Düğümü ileri taşı
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.05
            node.position.x = newX
            SCNTransaction.commit()
            
            // Bitiş çizgisi kontrolü (progress 1.0 oldu mu?)
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
        setup3DScene() // Sahneyi ve atları başlangıç çizgisine sıfırlar
    }
}

// MARK: - UI COMPONENTS
extension SimulationView3D {
    private var simulationHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(raceCity.uppercased(with: Locale(identifier: "tr_TR"))) - \(kosu.RACENO ?? "0"). KOŞU")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.cyan)
                Text("3D KÜRE SİMÜLASYONU")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
    }
    
    private var controlPanel: some View {
        HStack {
            Button(action: { finishLineReached ? resetSimulation() : isSimulating.toggle() }) {
                Label(finishLineReached ? "TEKRARLA" : (isSimulating ? "DURAKLAT" : "START VER"),
                      systemImage: finishLineReached ? "arrow.counterclockwise" : (isSimulating ? "pause.fill" : "play.fill"))
                    .font(.system(size: 16, weight: .black))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(finishLineReached ? Color.white : (isSimulating ? Color.orange : Color.cyan))
                    .foregroundColor(.black)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .onReceive(timer) { _ in updatePositions() }
    }
    
    private func winnerOverlay(horse: Horse) -> some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("🏆 KAZANAN 🏆").font(.largeTitle.bold()).foregroundColor(.yellow)
                
                Circle()
                    .fill(horse.horseColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(horse.NO ?? "0")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.white)
                    )
                    .shadow(color: horse.horseColor, radius: 20)
                
                VStack(spacing: 8) {
                    Text(horse.AD ?? "-").font(.title.bold()).foregroundColor(.white)
                    Text("Jokey: \(horse.JOKEYADI ?? "-")").font(.title3).foregroundColor(.cyan)
                }
                
                Button("DEVAM ET") { winnerHorse = nil }
                    .font(.headline).padding(.horizontal, 40).padding(.vertical, 15)
                    .background(Color.cyan).foregroundColor(.black).cornerRadius(12)
                    .padding(.top, 20)
            }
        }
    }
}

// MARK: - EXTENSIONS
extension Horse {
    // UIColor versiyonu (SceneKit materyalleri için)
    var uiColor: UIColor {
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple, .systemPink, .gray, .cyan, .systemMint]
        let num = Int(self.NO ?? "0") ?? 0
        return colors[num % colors.count]
    }
}