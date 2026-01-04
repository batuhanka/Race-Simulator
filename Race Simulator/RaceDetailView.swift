import SwiftUI

struct RaceDetailView: View {
    // MARK: - PROPERTIES
    @State var raceName: String
    @State var havaData: HavaData
    @State var kosular: [Race]
    @State var agf: [[String: Any]]
    
    let allRaces: [String]
    let selectedDate: Date
    
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
    
    // MARK: - PİST RENKLERİ
    private func getPistColors(for index: Int) -> [Color] {
        guard kosular.indices.contains(index) else {
            return [Color.black, Color.black]
        }
        
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
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            headerBilgiAlani
            
            kosuSekmeSecici
            
            if isRefreshing {
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
            } else {
                if kosular.indices.contains(selectedIndex) {
                    List {
                        let seciliKosu = kosular[selectedIndex]
                        
                        if let atlar = seciliKosu.atlar, !atlar.isEmpty {
                            ForEach(atlar) { at in
                                ListItemView(at: at)
                            }
                            
                            Color.clear
                                .frame(height: 40)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        } else {
                            ContentUnavailableView(
                                "At Bilgisi Yok",
                                systemImage: "horse.fill"
                            )
                        }
                    }
                    .id("List_\(raceName)_\(selectedIndex)") // Şehir veya Koşu değişince List'i sıfırla
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .background(
            RadialGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.9), Color.clear]),
                center: .top,
                startRadius: 0,
                endRadius: 1200
            )
            .ignoresSafeArea()
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
        }
    }
    
    // MARK: - DROPDOWN MENU
    private var dropdownTitleMenu: some View {
        Menu {
            ForEach(allRaces, id: \.self) { city in
                Button {
                    withAnimation {
                        self.raceName = city
                    }
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
                    .font(.subheadline)
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.black.opacity(0.2)))
        }
    }
    
    // MARK: - ÜST BİLGİ PANELİ
    private var headerBilgiAlani: some View {
        Group {
            if kosular.indices.contains(selectedIndex) {
                let kosu = kosular[selectedIndex]
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(kosu.RACENO ?? "0"). Koşu")
                            .font(.title3.bold())
                        
                        Spacer()
                        
                        Label(
                            kosu.SAAT ?? "00:00",
                            systemImage: "clock.fill"
                        )
                        .font(.subheadline.bold())
                    }
                    
                    Text(kosu.BILGI_TR ?? "")
                        .font(.subheadline)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
        }
    }
    
    // MARK: - KOŞU SEKMELERİ
    private var kosuSekmeSecici: some View {
        // ScrollView kaldırıldı, yerine ekrana yayılan HStack geldi
        HStack(spacing: 6) {
            ForEach(kosular.indices, id: \.self) { index in
                let kosuNo = kosular[index].RACENO ?? "\(index + 1)"
                let buttonColors = getPistColors(for: index)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = index
                    }
                } label: {
                    Text(kosuNo)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            Group {
                                if selectedIndex == index {
                                    
                                    LinearGradient(
                                        colors: buttonColors,
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                } else {
                                    
                                    LinearGradient(
                                        colors: buttonColors.map { $0.opacity(0.2) },
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            }
                        )
                        .foregroundColor(selectedIndex == index ? .black : .white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedIndex == index ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 10) // Kenar boşlukları
        .padding(.vertical, 10)
        .id("KosuSecici_\(raceName)_\(kosular.count)")
    }
    
    // MARK: - DATA FETCHING
    private func fetchNewCityData(cityName: String) {
        isRefreshing = true
        selectedIndex = 0
        
        Task {
            do {
                let dateStr = apiDateFormatter.string(from: selectedDate)
                let program = try await parser.getProgramData(raceDate: dateStr, cityName: cityName)
                
                var newHava: HavaData?
                if let havaDict = program["hava"] as? [String: Any] {
                    newHava = HavaData(from: havaDict)
                }
                
                var newKosular: [Race] = []
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let data = try JSONSerialization.data(withJSONObject: kosularArray)
                    newKosular = try JSONDecoder().decode([Race].self, from: data)
                }
                
                let newAgf = program["agf"] as? [[String: Any]] ?? []
                
                await MainActor.run {
                    if let safeHava = newHava {
                        self.havaData = safeHava
                    }
                    
                    self.kosular = newKosular
                    self.agf = newAgf
                    
                    withAnimation {
                        isRefreshing = false
                    }
                }
            } catch {
                print("Veri çekme hatası: \(error)")
                await MainActor.run {
                    isRefreshing = false
                }
            }
        }
        
    }
}


