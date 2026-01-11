import SwiftUI

struct MainView: View {
    
    // MARK: - STATE
    @State private var selectedDate: Date = Date()
    @State private var races: [String] = []
    @State private var selectedRace: String? = nil
    @State private var showRaceDetails: Bool = false
    @State private var havaData: HavaData?
    @State private var kosular: [Race] = []
    @State private var agf: [[String: Any]] = []
    @State private var isGlobalFetching: Bool = false
    
    // MARK: Binding
    @Binding var selectedBottomTab: Int
    
    
    // MARK: - Helpers
    let parser = JsonParser()
    
    // MARK: - Date Formatters
    private let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "dd MMMM EEEE"
        return f
    }()
    
    private let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
    
    private func fetchDetailsAndNavigate(for city: String) {
        isGlobalFetching = true
        
        Task {
            do {
                let dateString = apiDateFormatter.string(from: selectedDate)
                let program = try await parser.getProgramData(
                    raceDate: dateString,
                    cityName: city
                )
                
                await MainActor.run {
                    // Verileri doldur
                    if let havaDict = program["hava"] as? [String: Any] { havaData = HavaData(from: havaDict) }
                    if let kosularArray = program["kosular"] as? [[String: Any]] {
                        do {
                            let data = try JSONSerialization.data(withJSONObject: kosularArray)
                            kosular = try JSONDecoder().decode([Race].self, from: data)
                        } catch { print("Decode hatası: \(error)") }
                    }
                    if let agfArray = program["agf"] as? [[String: Any]] { agf = agfArray }
                    
                    self.selectedRace = city
                    self.showRaceDetails = true
                    self.isGlobalFetching = false
                }
            } catch {
                print("Veri çekme hatası: \(error)")
                isGlobalFetching = false
            }
        }
    }
    
    
    // MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                topNavigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        dynamicRaceProgramSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                
            }
            .background(Color.black.opacity(0.9))
            .onChange(of: selectedBottomTab) { oldValue, newValue in
                if newValue == 0 {
                    if showRaceDetails {
                        withAnimation(.easeInOut) {
                            showRaceDetails = false
                        }
                    }
                } else if newValue == 1 {
                    if let firstCity = races.first {
                        fetchDetailsAndNavigate(for: firstCity)
                    }
                }
            }
            .navigationDestination(isPresented: $showRaceDetails) {
                if let race = selectedRace {
                    RaceDetailView(
                        raceName: race,
                        havaData: havaData ?? HavaData.default,
                        kosular: kosular,
                        agf: agf,
                        allRaces: races,
                        selectedDate: selectedDate,
                        selectedBottomTab: $selectedBottomTab
                    )
                }
            }
            .onAppear {
                fetchRaces()
                selectedBottomTab = 0
            }
        }
    }
    
    // MARK: - TOP BAR
    private var topNavigationBar: some View {
        HStack {
            Image("tayzekatransparent")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            HStack(spacing: 2) {
                Text("TAY")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white.opacity(0.4))
                Text("ZEKA")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.cyan.opacity(0.9))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title3)
                    .foregroundColor(.cyan)
            }
        }
        .padding(.horizontal)
        .frame(height: 60)
        .background(Color.black)
    }
    
    // MARK: - DYNAMIC PROGRAM
    private var dynamicRaceProgramSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Tarih Seçici
            HStack {
                Button { changeDate(by: -1) } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundColor(.cyan)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(displayDateFormatter.string(from: selectedDate))
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button { changeDate(by: 1) } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.cyan)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .contentShape(Rectangle())
            .zIndex(1)
            
            // Yarış Kartları
            if races.isEmpty {
                VStack(spacing: 15) {
                    Text("Yarış Programı bulunamadı.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                VStack(spacing: 14) {
                    ForEach(races, id: \.self) { city in
                        RaceCardButton(
                            raceName: city,
                            selectedRace: $selectedRace,
                            selectedDate: $selectedDate,
                            showRaceDetails: $showRaceDetails,
                            havaData: $havaData,
                            kosular: $kosular,
                            agf: $agf,
                            parser: parser,
                            dateFormatter: apiDateFormatter
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - LOGIC
    private func changeDate(by days: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) else { return }
        
        withAnimation(.spring()) {
            selectedDate = newDate
            races = []
            fetchRaces()
        }
    }
    
    private func fetchRaces() {
        Task {
            do {
                let dateString = apiDateFormatter.string(from: selectedDate)
                let fetched = try await parser.getRaceCities(raceDate: dateString)
                await MainActor.run {
                    races = fetched
                }
            } catch {
                print("Veri çekme hatası: \(error)")
                await MainActor.run {
                    races = []
                }
            }
        }
    }
}

#Preview("MainView") {
    MainView(selectedBottomTab: .constant(0))
        .preferredColorScheme(.none)
}

