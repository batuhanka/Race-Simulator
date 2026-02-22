import SwiftUI
import UIKit

struct SimulationView: View {
    // MARK: - PROPERTIES
    let raceCity: String
    let havaData: HavaData
    let kosu: Race
    
    @Environment(\.dismiss) var dismiss
    @State private var isSimulating: Bool = false
    @State private var finishLineReached: Bool = false
    @State private var winnerHorse: Horse? = nil
    
    @State private var horsePositions: [String: CGFloat] = [:]
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(hex: "1A1A1A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                simulationHeader
                
                ZStack(alignment: .trailing) {
                    raceTrackArea
                    bitisCizgisi
                }
                
                controlPanel
            }
            
            if let winner = winnerHorse {
                winnerOverlay(horse: winner)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupHorses()
        }
    }
    
}

// MARK: - COMPONENTS
extension SimulationView {
    
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
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.8))
    }
    
    private var raceTrackArea: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if let atlar = kosu.atlar, !atlar.isEmpty {
                    ForEach(Array(atlar.enumerated()), id: \.element.id) { index, at in
                        VStack(spacing: 0) {
                            GeometryReader { geo in
                                let trackWidth = geo.size.width - 60
                                let position = horsePositions[at.id] ?? 0
                                
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1)
                                    
                                    HStack(spacing: 8) {
                                        Text(at.NO ?? "0")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundColor(.white)
                                            .frame(width: 18, height: 18)
                                            .background(at.horseColor)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                                        
                                        Image(systemName: "figure.equestrian.sports")
                                            .font(.system(size: 22))
                                            .foregroundColor(at.horseColor)
                                            .offset(y: isSimulating ? (index % 2 == 0 ? -2 : 2) : 0)
                                            .shadow(color: at.horseColor.opacity(isSimulating ? 0.6 : 0), radius: 4)
                                        
                                        // AGF VEYA HANDİKAP GÖSTERİMİ
                                        if isSimulating {
                                            HStack(spacing: 2) {
                                                Text(at.AD ?? "").font(.system(size: 7, weight: .bold)).foregroundColor(.white)
                                                if let agf = at.AGF1 {
                                                    Text("(%\(agf))").font(.system(size: 6, weight: .black)).foregroundColor(.yellow)
                                                }
                                            }
                                            .padding(.horizontal, 4).padding(.vertical, 2)
                                            .background(Color.black.opacity(0.6)).cornerRadius(3).offset(y: -5)
                                        }
                                    }
                                    .offset(x: position * trackWidth)
                                }
                            }
                            .frame(height: 45)
                            Divider().background(Color.white.opacity(0.05))
                        }
                    }
                } else {
                    // ATLAR YÜKLENEMEDİYSE VEYA BOŞSA EKRANDA UYARI GÖSTER
                    Text("Bu koşu için at bilgisi bulunamadı.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
            }
            .padding(.vertical, 10)
        }
    }

    private var bitisCizgisi: some View {
        Rectangle()
            .fill(LinearGradient(colors: [.red, .white, .red], startPoint: .top, endPoint: .bottom))
            .frame(width: 5)
            .padding(.trailing, 15)
            .opacity(0.8)
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

// MARK: - LOGIC
extension SimulationView {
    private func setupHorses() {
        guard let atlar = kosu.atlar else { return }
        for at in atlar { horsePositions[at.id] = 0.0 }
    }
    
    private func updatePositions() {
        guard isSimulating && !finishLineReached else { return }
        guard let atlar = kosu.atlar else { return }
        
        for at in atlar {
            // AGF Tabanlı Gerçekçi Hız
            var baseSpeed = CGFloat.random(in: 0.003...0.009)
            
            if let agfStr = at.AGF1?.replacingOccurrences(of: ",", with: "."), let agfVal = Double(agfStr) {
                baseSpeed += CGFloat(agfVal / 100.0) * 0.015
            } else if let hStr = at.HANDIKAP, let hVal = Double(hStr) {
                baseSpeed += CGFloat(min(hVal, 100.0) / 100.0) * 0.010
            }
            
            let finalSpeed = baseSpeed + CGFloat.random(in: -0.002...0.006)
            let currentPos = horsePositions[at.id] ?? 0
            let newPos = currentPos + max(0.001, finalSpeed)
            
            horsePositions[at.id] = newPos
            
            if newPos >= 1.0 {
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
        setupHorses()
    }
}

// MARK: - EXTENSIONS
extension Horse {
    var horseColor: Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .gray, .cyan, .mint]
        let num = Int(self.NO ?? "0") ?? 0
        return colors[num % colors.count]
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}

#Preview {
    SimulationView(raceCity: "Ankara", havaData: HavaData.default, kosu: Race(KOD: "999", RACENO: "1", atlar: [Horse.example]))
}
