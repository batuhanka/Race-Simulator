import SwiftUI

struct SimulationView: View {
    // MARK: - PROPERTIES
    let raceCity: String
    let havaData: HavaData
    let kosular: [Race]
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedRaceIndex: Int = 0
    @State private var isSimulating: Bool = false
    @State private var simulationProgress: Double = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arkaplan
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 1. Üst Bilgi Kartı
                    headerSection
                    
                    // 2. Koşu Seçici (Yatay Scroll)
                    raceSelectorSection
                    
                    // 3. Simülasyon Alanı
                    simulationDisplayArea
                    
                    Spacer()
                    
                    // 4. Alt Kontrol Butonu
                    simulateButton
                }
                .padding()
            }
            .navigationTitle("Yarış Simülasyonu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

// MARK: - COMPONENTS
extension SimulationView {
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(raceCity.uppercased())
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.cyan)
                
                HStack {
                    Image(systemName: "cloud.sun.fill")
                    Text("\(havaData.sicaklik)°C - \(havaData.durum)")
                    Text("|")
                    Image(systemName: "road.lanes")
                    Text(havaData.pist)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
    
    private var raceSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(kosular.indices, id: \.self) { index in
                    Button {
                        selectedRaceIndex = index
                        simulationProgress = 0 // Yarış değişince sıfırla
                    } label: {
                        VStack {
                            Text("\(index + 1). Koşu")
                                .font(.system(size: 14, weight: .bold))
                            Text(kosular[index].mesafe ?? "0m")
                                .font(.system(size: 10))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(selectedRaceIndex == index ? Color.cyan : Color.white.opacity(0.1))
                        .foregroundColor(selectedRaceIndex == index ? .black : .white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var simulationDisplayArea: some View {
        VStack {
            if isSimulating {
                VStack(spacing: 30) {
                    ProgressView(value: simulationProgress, total: 1.0)
                        .tint(.cyan)
                        .scaleEffect(x: 1, y: 4, anchor: .center)
                    
                    Text("Yapay Zeka Yarışı Analiz Ediyor...")
                        .font(.callout.italic())
                        .foregroundColor(.cyan)
                        .opacity(simulationProgress.truncatingRemainder(dividingBy: 0.2) > 0.1 ? 1 : 0.5)
                }
                .padding(40)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "cpu")
                        .font(.system(size: 60))
                        .foregroundColor(.cyan.opacity(0.5))
                    
                    Text("Simülasyonu Başlatmak İçin Hazır")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Bu koşuda \(kosular[selectedRaceIndex].atlar?.count ?? 0) safkan mücadele edecek.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(RoundedRectangle(cornerRadius: 25).fill(Color.white.opacity(0.03)))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var simulateButton: some View {
        Button {
            startSimulation()
        } label: {
            HStack {
                Image(systemName: isSimulating ? "stop.fill" : "play.fill")
                Text(isSimulating ? "SİMÜLASYON DURDUR" : "SİMÜLASYONU BAŞLAT")
                    .fontWeight(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSimulating ? Color.red : Color.cyan)
            .foregroundColor(.