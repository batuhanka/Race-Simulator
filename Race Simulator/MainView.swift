import SwiftUI

// MARK: - MAIN VIEW
struct MainView: View {
    
    @State private var selectedDate: Date = Date()
    @State private var races: [String] = []
    @State private var selectedRace: String? = nil
    @State private var showRaceDetails: Bool = false
    @State private var havaData: HavaData?
    @State private var kosular: [Race] = []
    @State private var agf: [[String: Any]] = []
    
    let parser = JsonParser()
    
    // MARK: - Date Formatters
    private var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd MMMM EEEE"
        return formatter
    }
    
    private var apiDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Üst Bar
                topNavigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Burada dynamic olanı çağırmalısın ki tarih seçici gözüksün
                        dynamicRaceProgramSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                // Bottom Bar
                CustomBottomBar()
            }
            .background(Color(uiColor: .black).opacity(0.9))
            .navigationDestination(isPresented: $showRaceDetails) {
                RaceDetailView(
                    raceName: selectedRace ?? "Yarış Detayı",
                    havaData: havaData ?? HavaData.default,
                    kosular: kosular,
                    agf: agf
                )
            }
            .onAppear { fetchRaces() }
        }
        
    }
}

// MARK: - Subviews Extension
extension MainView {
    
    // Üst Navigasyon
    private var topNavigationBar: some View {
        HStack {
            Image("tayzekatransparent")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
            
            Spacer()
            
            HStack(spacing: 2) {
                Text("TAY").font(.system(size: 22, weight: .black, design: .rounded)).foregroundColor(.gray)
                Text("ZEKA").font(.system(size: 22, weight: .black, design: .rounded)).foregroundColor(Theme.matrixCyan)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Üye Girişi")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.cyan)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .frame(height: 70)
        .background(Color.black)
    }

    // TARİH SEÇİCİ VE DİNAMİK LİSTE (BURASI ÖNEMLİ)
    private var dynamicRaceProgramSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Başlık ve DatePicker Yan Yana
            HStack {
                
                
                Spacer()
                
                // Tarih Değiştirme Paneli
                HStack(spacing: 10) {
                    Button(action: { changeDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    
                    Text(displayDateFormatter.string(from: selectedDate))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.matrixCyan)
                    
                    Button(action: { changeDate(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                Spacer()
                
            }
            .padding(.top, 10)
            
            // API'DEN GELEN ŞEHİR LİSTESİ
            if races.isEmpty {
                VStack {
                    Spacer()
                    Text("Bu tarihte yarış bulunamadı.")
                        .foregroundColor(.secondary)
                        .italic()
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                VStack(spacing: 12) {
                    ForEach(races, id: \.self) { raceCity in
                        // Sizin paylaştığınız RaceCardButton bileşeni
                        RaceCardButton(
                            raceName: raceCity,
                            selectedRace: $selectedRace,
                            selectedDate: $selectedDate,
                            showRaceDetails: $showRaceDetails,
                            havaData: $havaData,
                            kosular: $kosular,
                            agf: $agf,
                            parser: parser,
                            dateFormatter: apiDateFormatter
                        )
                        .frame(maxWidth: .infinity) // Kartın tam genişlik kaplaması için
                    }
                }
            }
        }
    }
}

// MARK: - Helper Functions
extension MainView {
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            withAnimation {
                selectedDate = newDate
                fetchRaces()
            }
        }
    }

    private func fetchRaces() {
        Task {
            do {
                let dateString = apiDateFormatter.string(from: selectedDate)
                let fetchedRaces = try await parser.getRaceCities(raceDate: dateString)
                await MainActor.run {
                    self.races = fetchedRaces
                }
            } catch {
                print("Hata: \(error)")
                await MainActor.run { self.races = [] }
            }
        }
    }
}





    // MARK: - Özel Kart Bileşeni
    struct RaceProgramCard: View {
        let city: String
        let time: String
        let pistType: String
        let gradient: [Color]
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label("İlk Koşu: \(time)", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(pistType)
                            .font(.caption.bold())
                            .foregroundColor(pistType == "Çim" ? .green : .orange)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
            )
            // Kartın etrafında çok hafif bir çerçeve (opsiyonel)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }
    


// MARK: - YARDIMCI BİLEŞENLER

struct FeatureCardLarge: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.title3.bold()).foregroundColor(color)
                Text(subtitle)
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            Spacer()
            Image(systemName: icon).font(.largeTitle).foregroundColor(
                color.opacity(0.5)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
}

struct FeatureCardSmall: View {
    let title: String
    let desc: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title).font(.headline).foregroundColor(color)
                Spacer()
                Image(systemName: icon).foregroundColor(color.opacity(0.3))
            }
            if !desc.isEmpty {
                Text(desc).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color.white)
        .cornerRadius(15)
    }
}

struct GridButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - CUSTOM BOTTOM BAR
struct CustomBottomBar: View {
    var body: some View {
        HStack(alignment: .bottom) {
            BottomTabItem(icon: "house.fill", title: "Anasayfa", active: true)
            BottomTabItem(
                icon: "list.bullet.rectangle",
                title: "Biletlerim",
                active: false
            )

            // MARK: - Orta Çıkıntılı Buton (Logo Entegreli)
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .frame(width: 55, height: 55)
                    
                    
                    Image("tayzekatransparent") // Assets klasöründeki görsel isminiz
                        .resizable()
                        .scaledToFit()
                        //.frame(width: 35, height: 35) // Dairenin içinde dengeli durması için
                        
                }
                .offset(y: 0) // Yukarı çıkıntı miktarını artırdım, daha şık durur
                
                Text("Simulasyon")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)

            BottomTabItem(icon: "flag.fill", title: "Sonuçlar", active: false)
            BottomTabItem(icon: "ticket", title: "Kuponlar", active: false)
        }
        .padding(.top, -36)
        .background(Color.black.ignoresSafeArea())
    }
}

struct BottomTabItem: View {
    let icon: String
    let title: String
    let active: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(title)
                .font(.system(size: 10))
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(active ? .blue : .gray)
    }
}

// MARK: - PREVIEW
#Preview {
    MainView()
}
