//
//  SimulationSetupView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.02.2026.
//


import SwiftUI

struct SimulationSetupView: View {
    // MARK: - INCOMING PROPERTIES
    let selectedDate: Date
    let availableCities: [String]
    let initialCity: String?
    
    // MARK: - STATE
    @State private var selectedCity: String = ""
    @State private var havaData: HavaData = HavaData.default
    @State private var kosular: [Race] = []
    @State private var selectedKosuIndex: Int = 0
    
    @State private var isFetching: Bool = false
    @State private var showActualSimulation: Bool = false
    @State private var isStartButtonPulsing = false
    @State private var visibleHorseCount: Int = 0
    @State private var revealTask: Task<Void, Never>? = nil
    
    let parser = JsonParser()
    private let apiFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                headerSection
                
                if isFetching {
                    ProgressView().tint(.cyan).scaleEffect(1.5)
                        .padding(.vertical, 20)
                    Text("Program Yükleniyor...").foregroundColor(.gray).font(.caption)
                } else if kosular.isEmpty {
                    Text("Bu şehre ait yarış programı bulunamadı.")
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
                } else {
                    cityPickerSection
                    racePickerSection
                    horsesPreviewSection
                    startSimulationButton
                        .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let city = initialCity ?? availableCities.first {
                selectedCity = city
                fetchProgram(for: city)
            }
        }
        
        .fullScreenCover(isPresented: $showActualSimulation) {
            if kosular.indices.contains(selectedKosuIndex) {
                SimulationViewHorse3D(
                    raceCity: selectedCity,
                    havaData: havaData,
                    kosu: kosular[selectedKosuIndex]
                )
                /*
                 SimulationView3D(
                 raceCity: selectedCity,
                 havaData: havaData,
                 kosu: kosular[selectedKosuIndex]
                 )
                 */
                /*
                 SimulationView(
                 raceCity: selectedCity,
                 havaData: havaData,
                 kosu: kosular[selectedKosuIndex]
                 )
                 */
            }
        }
        
    }
}

// MARK: - COMPONENTS
extension SimulationSetupView {
    
    private var headerSection: some View {
        VStack(spacing: 5) {
            Image("tayzekatransparent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120)
            //Text("TAY ZEKA SİMÜLASYONU")
            //    .font(.subheadline.bold())
            //    .foregroundColor(Color.cyan.opacity(0.8))
        }
        //.padding(.bottom, 5)
    }
    
    private var cityPickerSection: some View {
        VStack(spacing: 10) {
            // Ekranın anlık genişliğini okumak için GeometryReader kullanıyoruz
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(availableCities, id: \.self) { city in
                            Button {
                                if selectedCity != city {
                                    selectedCity = city
                                    fetchProgram(for: city)
                                }
                            } label: {
                                Text(city)
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(selectedCity == city ? Color.cyan : Color.white.opacity(0.1))
                                    .foregroundColor(selectedCity == city ? .black : .white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    // Öğeler azsa tam ortaya hizalar, çoksa kaydırmaya izin verir
                    .frame(minWidth: geometry.size.width)
                }
            }
            .frame(height: 40) // Butonların yüksekliğini GeometryReader'a bildiriyoruz
        }
    }
    
    private var racePickerSection: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(kosular.indices, id: \.self) { index in
                            let kosuNo = kosular[index].RACENO ?? "\(index + 1)"
                            Button {
                                withAnimation { selectedKosuIndex = index }
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(kosuNo). Koşu")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("\(kosular[index].MESAFE ?? "")m \(kosular[index].PISTADI_TR ?? "")")
                                        .font(.system(size: 10))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedKosuIndex == index ? Color.orange : Color.white.opacity(0.1))
                                .foregroundColor(selectedKosuIndex == index ? .black : .white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    // Öğeler azsa tam ortaya hizalar, çoksa kaydırmaya izin verir
                    .frame(minWidth: geometry.size.width)
                }
            }
            .frame(height: 45) // Çift satırlı butonlar için yükseklik
        }
    }
    
    private var horsesPreviewSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("KATILACAK SAFKANLAR").font(.caption.bold()).foregroundColor(.gray)
                Spacer()
                if kosular.indices.contains(selectedKosuIndex) {
                    Text("\(kosular[selectedKosuIndex].atlar?.count ?? 0) At")
                        .font(.caption2.bold())
                        .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // En başa dönmek için görünmez bir işaretçi (Marker)
                        Color.clear.frame(height: 1).id("TopMarker")
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            if kosular.indices.contains(selectedKosuIndex), let atlar = kosular[selectedKosuIndex].atlar {
                                ForEach(Array(atlar.enumerated()), id: \.element.id) { index, at in
                                    // Koşular karışmasın diye her ata "koşu_index" şeklinde eşsiz kimlik veriyoruz
                                    let uniqueID = "horse_\(selectedKosuIndex)_\(index)"
                                    
                                    AnimatedHorseCard(at: at, isVisible: index < visibleHorseCount)
                                        .id(uniqueID)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 5) // Top marker ile araya çok hafif boşluk
                    }
                }
                .onChange(of: visibleHorseCount) { _, newCount in
                    if newCount > 0 {
                        withAnimation {
                            // Sadece sıradaki ata doğru kaydır
                            let targetID = "horse_\(selectedKosuIndex)_\(newCount - 1)"
                            proxy.scrollTo(targetID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: selectedKosuIndex) { _, _ in
                    withAnimation {
                        // Başka koşu seçilince en tepeye kaydır
                        proxy.scrollTo("TopMarker", anchor: .top)
                    }
                    startRevealTask()
                }
            }
        }
        .frame(maxHeight: 600)
    }
    
    private var startSimulationButton: some View {
        Button {
            showActualSimulation = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("BAŞLAT")
                    .font(.headline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .foregroundColor(Color.cyan.opacity(0.8))
            .cornerRadius(15)
            .padding(.horizontal)
            .shadow(color: .cyan.opacity(isStartButtonPulsing ? 0.8 : 0.6), radius: isStartButtonPulsing ? 15 : 5)
            .scaleEffect(isStartButtonPulsing ? 1.05 : 1.0)
        }
        .padding(.bottom, 50)
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: isStartButtonPulsing
        )
        .onAppear {
            isStartButtonPulsing = true
        }
        .onDisappear {
            isStartButtonPulsing = false
        }
    }
    
    // MARK: - DATA FETCHING
    private func fetchProgram(for city: String) {
        isFetching = true
        selectedKosuIndex = 0
        
        Task {
            do {
                let dateStr = apiFormatter.string(from: selectedDate)
                let program = try await parser.getProgramData(raceDate: dateStr, cityName: city)
                
                var newHava = HavaData.default
                if let havaDict = program["hava"] as? [String: Any], let parsedHava = HavaData(from: havaDict) {
                    newHava = parsedHava
                }
                
                var newKosular: [Race] = []
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let data = try JSONSerialization.data(withJSONObject: kosularArray)
                    newKosular = try JSONDecoder().decode([Race].self, from: data)
                }
                
                await MainActor.run {
                    self.havaData = newHava
                    self.kosular = newKosular
                    self.isFetching = false
                    self.startRevealTask()
                }
            } catch {
                await MainActor.run {
                    self.kosular = []
                    self.isFetching = false
                }
            }
        }
    }
    
    private func startRevealTask() {
        revealTask?.cancel() // Eski sayacı kesinlikle durdur
        visibleHorseCount = 0 // Ekrani temizle
        
        guard kosular.indices.contains(selectedKosuIndex),
              let atlar = kosular[selectedKosuIndex].atlar,
              !atlar.isEmpty else { return }
        
        let totalHorses = atlar.count
        
        revealTask = Task {
            // UI'ın eski listeyi temizlediğinden emin olmak için çok minik bir es (0.05 saniye)
            try? await Task.sleep(nanoseconds: 50_000_000)
            if Task.isCancelled { return }
            
            for i in 0..<totalHorses {
                // 1. ÖNCE ATI GÖSTER (İlk at hiç beklemeden anında görünür)
                await MainActor.run {
                    if !Task.isCancelled {
                        visibleHorseCount = i + 1
                    }
                }
                
                // 2. SONRA DİĞER AT İÇİN BEKLE (0.5 saniye)
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                // Eğer bu bekleme sırasında kullanıcı başka koşuya tıkladıysa döngüyü anında kır
                if Task.isCancelled { break }
            }
        }
    }
    
}


struct AnimatedHorseCard: View {
    let at: Horse
    let isVisible: Bool // Görünürlüğü artık parent yönetiyor
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(at.horseColor).frame(width: 30, height: 30)
                Text(at.NO ?? "0").font(.system(size: 12, weight: .black)).foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(at.AD ?? "-")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(at.JOKEYADI ?? "-")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(6)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .opacity(isVisible ? 1 : 0) // isVisible true olunca opaklaşır
        .offset(y: isVisible ? 0 : 30) // isVisible true olunca kendi konumuna kayar
        // Animasyon delay olmadan, isVisible tetiklendiği an çalışır
        .animation(.easeOut(duration: 0.8), value: isVisible)
    }
}

// MARK: - PREVIEW
#Preview {
    // 1. Mock Atlar
    let h1 = Horse(
        KOD: "1001",
        NO: "1",
        AD: "GÜLŞAH SULTAN",
        START: "1", 
        JOKEYADI: "H. KARATAŞ"
    )
    
    let h2 = Horse(
        KOD: "1002",
        NO: "2",
        AD: "RÜZGAR GİBİ",
        START: "2",
        JOKEYADI: "S. KAYA"
    )
    
    let h3 = Horse(
        KOD: "1003",
        NO: "3",
        AD: "ŞAMPİYON TAY",
        START: "3",
        JOKEYADI: "A. KURŞUN"
    )
    
    // 2. Mock Koşular (Farklı koşular oluşturuyoruz ki racePickerSection çalışsın)
    let mockRace1 = Race(
        KOD: "901",
        RACENO: "1",
        SAAT: "14:00",
        BILGI_TR: "3 Yaşlı İngilizler",
        MESAFE: "1400",
        atlar: [h1, h2, h3]
    )
    
    let mockRace2 = Race(
        KOD: "902",
        RACENO: "2",
        SAAT: "14:30",
        BILGI_TR: "4 Yaşlı Araplar",
        MESAFE: "1600",
        atlar: [h1, h2] // 2. koşuda sadece 2 at var
    )
    
    // 3. Mevcut tarihi ayarla
    let today = Date()
    
    // 4. View'ı Döndür
    NavigationStack {
        SimulationSetupView(
            selectedDate: today,
            availableCities: ["BURSA", "SANLIURFA"],
            initialCity: "BURSA"
            
        )
    }
    .preferredColorScheme(.dark)
}
