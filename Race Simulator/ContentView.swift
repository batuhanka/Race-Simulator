import SwiftUI

// MARK: - 1. Buton Efekti Stili
struct CardPressEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - 2. Yarış Kartı Butonu
struct RaceCardButton: View {
    let raceName: String
    @Binding var selectedRace: String?
    @Binding var selectedDate: Date
    @Binding var showRaceDetails: Bool
    @Binding var havaData: HavaData?
    @Binding var kosular: [Race]
    @Binding var agf: [[String: Any]]
    let parser: JsonParser
    let dateFormatter: DateFormatter
    
    @State private var isFetching: Bool = false

    private func getCityIcon() -> String {
        let city = raceName.uppercased(with: Locale(identifier: "tr_TR"))
        switch city {
        case "İSTANBUL", "ISTANBUL": return "34.circle.fill"
        case "ANKARA": return "06.circle.fill"
        case "İZMİR", "IZMIR": return "35.circle.fill"
        case "ADANA": return "01.circle.fill"
        case "BURSA": return "16.circle.fill"
        case "DIYARBAKIR": return "21.circle.fill"
        case "ANTALYA": return "07.circle.fill"
        case "ELAZIG": return "23.circle.fill"
        default: return "star.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: { fetchRaceDetails() }) {
            HStack(spacing: 15) {
                if isFetching {
                    ProgressView().tint(.white)
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: getCityIcon())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                Text(raceName)
                    .font(.title3)
                    .fontWeight(.heavy)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .frame(maxWidth: 300)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.teal, Color.cyan]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(CardPressEffectStyle())
        .disabled(isFetching)
    }

    private func fetchRaceDetails() {
        isFetching = true
        Task {
            do {
                let program = try await parser.getProgramData(
                    raceDate: dateFormatter.string(from: selectedDate),
                    cityName: raceName
                )
                
                if let havaDict = program["hava"] as? [String: Any] {
                    self.havaData = HavaData(from: havaDict)
                }
                
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let jsonData = try JSONSerialization.data(withJSONObject: kosularArray)
                    self.kosular = try JSONDecoder().decode([Race].self, from: jsonData)
                }
                
                if let agfArray = program["agf"] as? [[String: Any]] {
                    self.agf = agfArray
                }
                
                // Veriler başarıyla yüklendiğinde navigasyonu tetikle
                self.selectedRace = raceName
                self.showRaceDetails = true
                
            } catch {
                print("Detay getirme hatası: \(error)")
            }
            isFetching = false
        }
    }
}

// MARK: - 3. Ana Görünüm (ContentView)
struct ContentView: View {
    
    init() {
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
    }
    
    @State private var selectedDate: Date = Date()
    @State private var races: [String] = []
    @State private var selectedRace: String? = nil
    @State private var showRaceDetails: Bool = false
    @State private var havaData: HavaData?
    @State private var kosular: [Race] = []
    @State private var agf: [[String: Any]] = []
    
    let parser = JsonParser()
    
    private var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "E, dd MMMM"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }
    
    var minDate: Date { Calendar.current.date(byAdding: .day, value: -7, to: Date())! }
    var maxDate: Date { Calendar.current.date(byAdding: .day, value: 1, to: Date())! }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate),
           newDate >= minDate && newDate <= maxDate {
            selectedDate = newDate
            fetchRaces()
        }
    }

    private func fetchRaces() {
        Task {
            do {
                races = try await parser.getRaceCities(raceDate: dateFormatter.string(from: selectedDate))
            } catch {
                print("Şehir listesi hatası: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arka Plan
                Image("back")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 150) // Tasarımınıza göre boşluk
                    
                    // Tarih Seçici Bölümü
                    datePickerHeader
                        .padding(.bottom, 20)
                    
                    // Yarış Listesi
                    if races.isEmpty {
                        VStack {
                            Text("Seçili tarihte yarış programı bulunamadı.")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.top, 40)
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 15) {
                                ForEach(races, id: \.self) { race in
                                    RaceCardButton(
                                        raceName: race,
                                        selectedRace: $selectedRace,
                                        selectedDate: $selectedDate,
                                        showRaceDetails: $showRaceDetails,
                                        havaData: $havaData,
                                        kosular: $kosular,
                                        agf: $agf,
                                        parser: parser,
                                        dateFormatter: dateFormatter
                                    )
                                }
                            }
                            .padding(.bottom, 30)
                        }
                    }
                    
                    Spacer()
                }
            }
            // NAVİGASYON HEDEFİ
            .navigationDestination(isPresented: $showRaceDetails) {
                RaceDetailView(
                    raceName: selectedRace ?? "Yarış Detayı",
                    havaData: havaData ?? HavaData.default,
                    kosular: kosular,
                    agf: agf
                )
            }
            .onAppear { fetchRaces() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var datePickerHeader: some View {
        HStack {
            Button(action: { changeDate(by: -1) }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title)
                    .foregroundColor(selectedDate > minDate ? .white : .gray)
            }
            .disabled(selectedDate <= minDate)
            
            Spacer()
            
            Text(displayDateFormatter.string(from: selectedDate))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { changeDate(by: 1) }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title)
                    .foregroundColor(selectedDate < maxDate ? .white : .gray)
            }
            .disabled(selectedDate >= maxDate)
        }
        .padding(.horizontal, 25)
        .frame(width: 300, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.7)]),
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.3), lineWidth: 1))
        )
        .shadow(color: .indigo.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 4. Previews
#Preview("Ana Görünüm") {
    ContentView()
}

#Preview("Yarış Kartı Örneği") {
    ZStack {
        Color.gray.ignoresSafeArea() // Arka planı görmek için
        
        RaceCardButton(
            raceName: "İSTANBUL",
            selectedRace: .constant("İSTANBUL"),
            selectedDate: .constant(Date()),
            showRaceDetails: .constant(false),
            havaData: .constant(nil),
            kosular: .constant([]),
            agf: .constant([]),
            parser: JsonParser(), // Gerçek sınıfa göre init gerekebilir
            dateFormatter: DateFormatter()
        )
    }
}
