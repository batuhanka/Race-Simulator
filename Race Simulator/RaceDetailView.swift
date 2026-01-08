import SwiftUI

struct RaceDetailView: View {
    // MARK: - PROPERTIES
    @State var raceName: String
    @State var havaData: HavaData
    @State var kosular: [Race]
    @State var agf: [[String: Any]]
    @State private var currentRaceResult: RaceResult? = nil
    
    let allRaces: [String]
    let selectedDate: Date
    
    @State private var fetchTask: Task<Void, Never>? = nil
    @State private var isFetchingResults: Bool = false
    
    // MARK: Binding
    @Binding var selectedBottomTab: Int
    
    @State private var selectedIndex: Int = 0
    @State private var isRefreshing: Bool = false
    
    let parser = JsonParser()
    let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            headerBilgiAlani
            
            kosuSekmeSecici
            
            if isRefreshing {
                loadingView
            } else {
                if kosular.indices.contains(selectedIndex) {
                    let seciliKosu = kosular[selectedIndex]
                    
                    // Logic Switch: Results vs Program
                    if let results = currentRaceResult,
                       let finishers = results.SONUCLAR,
                       !finishers.isEmpty,
                       results.KOD == seciliKosu.KOD { // Kritik kontrol: Gelen veri gerçekten bu koşuya mı ait?
                        
                        // --- RESULTS VIEW ---
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(finishers.sorted(by: { $0.rankInt < $1.rankInt })) { finisher in
                                    ResultRowView(finisher: finisher)
                                }
                                Color.clear.frame(height: 65)
                            }
                            .padding(.horizontal)
                        }
                        .id("Results_\(seciliKosu.KOD)")
                    } else if isFetchingResults {
                        loadingView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) { // Kartlar arasındaki dikey boşluk
                                if let atlar = seciliKosu.atlar, !atlar.isEmpty {
                                    ForEach(atlar) { at in
                                        ListItemView(at: at)
                                            .padding(.horizontal) // Kartları ekran kenarından iter
                                    }
                                    
                                    Color.clear.frame(height: 70)
                                } else {
                                    ContentUnavailableView("At Bilgisi Yok", systemImage: "horse.fill")
                                }
                            }
                        }
                        .id("ProgramList_\(selectedIndex)")
                        .transition(.opacity)
                    }
                }
            }
        }
        .background(
            ZStack {
                // 1. Temel arka plan rengi (Koyu bir zemin üzerine renk bindireceğiz)
                Color.black.ignoresSafeArea()
                
                // 2. Dinamik Pist Rengi
                let pistRenkleri = getPistColors(for: selectedIndex)
                LinearGradient(
                    gradient: Gradient(colors: [
                        pistRenkleri.last?.opacity(0.6) ?? .black, // Pistin ana rengi (üstten)
                        Color.black.opacity(0.8)                 // Siyaha doğru geçiş
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: selectedIndex) // Renk geçişini yumuşatır
                
                // 3. Hafif bir doku (Opsiyonel: Daha derinlikli durması için)
                RadialGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1000
                ).ignoresSafeArea()
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                dropdownTitleMenu
            }
        }
        .onChange(of: raceName) { oldValue, newValue in
            fetchNewCityData(cityName: newValue)
        }
        .onAppear() {
            selectedBottomTab = 1
            if kosular.indices.contains(selectedIndex) {
                checkResults(for: kosular[selectedIndex])
            }
            let seciliKosu = kosular[selectedIndex]
            logRaceDetails(race: seciliKosu, date: selectedDate, city: raceName)
            
        }
    }
}

// MARK: - SUBVIEWS
extension RaceDetailView {
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(.cyan)
                .scaleEffect(1.5)
            Text("Veriler Güncelleniyor...")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var headerBilgiAlani: some View {
        Group {
            if kosular.indices.contains(selectedIndex) {
                let kosu = kosular[selectedIndex]
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(kosu.RACENO ?? "0"). Koşu")
                            .font(.title3.bold())
                        Spacer()
                        Label(kosu.SAAT ?? "00:00", systemImage: "clock.fill")
                            .font(.subheadline.bold())
                    }
                    
                    Text(kosu.BILGI_TR ?? "")
                        .font(.subheadline)
                        .lineLimit(2, reservesSpace: true) // 3 satırlık yeri hep ayırır
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(height: 80, alignment: .top)
            }
        }
    }
    
    private var kosuSekmeSecici: some View {
        HStack(spacing: 6) {
            ForEach(kosular.indices, id: \.self) { index in
                let kosuNo = kosular[index].RACENO ?? "\(index + 1)"
                let buttonColors = getPistColors(for: index)
                Button {
                    selectedIndex = index
                    currentRaceResult = nil
                    checkResults(for: kosular[index])
                } label: {
                    Text(kosuNo)
                        .font(.system(size: 13, weight: .bold)) // Biraz büyüttük
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            selectedIndex == index ?
                            LinearGradient(colors: buttonColors, startPoint: .top, endPoint: .bottom) :
                                LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundColor(selectedIndex == index ? .black : .white.opacity(0.7))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }
    
    private var dropdownTitleMenu: some View {
        
        Menu {
            ForEach(allRaces, id: \.self) { city in
                Button {
                    withAnimation { self.raceName = city }
                } label: {
                    HStack {
                        Text(city)
                        if city == raceName {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(raceName.uppercased(with: Locale(identifier: "tr_TR")))
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Image(systemName: "chevron.down.circle.fill")
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.black.opacity(0.2)))
        }
    }
}

// MARK: - LOGIC & HELPERS
extension RaceDetailView {
    
    private func getPistColors(for index: Int) -> [Color] {
        guard kosular.indices.contains(index) else { return [.black, .black] }
        let pist = (kosular[index].PIST ?? "").lowercased(with: Locale(identifier: "tr_TR"))
        if pist.contains("cim") || pist.contains("çim") {
            return [Color.green.opacity(0.3), Color.green.opacity(0.9)]
        } else if pist.contains("kum") {
            return [Color.brown.opacity(0.3), Color.brown.opacity(0.9)]
        } else if pist.contains("sentetik") {
            return [Color.gray.opacity(0.3), Color.gray.opacity(0.9)]
        } else {
            return [Color.gray.opacity(0.3), Color.black.opacity(0.9)]
        }
    }
    
    private func checkResults(for race: Race) {
        
        fetchTask?.cancel()
            
            isFetchingResults = true
            currentRaceResult = nil
            
            let dateStr = apiDateFormatter.string(from: selectedDate)
            
            fetchTask = Task {
                do {
                    let result = try await parser.getRaceResult(raceDate: dateStr, cityName: raceName, targetKod: race.KOD)
                    
                    try Task.checkCancellation()
                    
                    await MainActor.run {
                        self.currentRaceResult = result
                        self.isFetchingResults = false // Yükleme bitti
                    }
                } catch {
                    await MainActor.run { self.isFetchingResults = false }
                }
            }
    }
    
    private func logRaceDetails(race: Race, date: Date, city: String) {
        // Simple console logging to avoid View return errors
        print("DEBUG: Checking \(city) - KOD: \(race.KOD)")
    }
    
    private func fetchNewCityData(cityName: String) {
        isRefreshing = true
        selectedIndex = 0
        currentRaceResult = nil
        Task {
            do {
                let dateStr = apiDateFormatter.string(from: selectedDate)
                let program = try await parser.getProgramData(raceDate: dateStr, cityName: cityName)
                
                // Parse Logic...
                var newHava: HavaData?
                if let havaDict = program["hava"] as? [String: Any] { newHava = HavaData(from: havaDict) }
                
                var newKosular: [Race] = []
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let data = try JSONSerialization.data(withJSONObject: kosularArray)
                    newKosular = try JSONDecoder().decode([Race].self, from: data)
                }
                
                let newAgf = program["agf"] as? [[String: Any]] ?? []
                
                await MainActor.run {
                    if let safeHava = newHava { self.havaData = safeHava }
                    self.kosular = newKosular
                    self.agf = newAgf
                    withAnimation { isRefreshing = false }
                    // Trigger check for first race of new city
                    if !newKosular.isEmpty { checkResults(for: newKosular[0]) }
                }
            } catch {
                await MainActor.run { isRefreshing = false }
            }
        }
    }
}


