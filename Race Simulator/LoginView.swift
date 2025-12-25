import SwiftUI

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
    
    private func getCityIcon() -> String {
        switch raceName.uppercased() {
        case "ISTANBUL": return "34.circle.fill"
        case "ANKARA": return "06.circle.fill"
        case "IZMIR": return "35.circle.fill"
        case "ADANA": return "01.circle.fill"
        case "BURSA": return "16.circle.fill"
        case "DIYARBAKIR": return "21.circle.fill"
        case "ANTALYA": return "07.circle.fill"
        case "ELAZIG": return "23.circle.fill"
        default: return "star.circle.fill"
        }
    }
    
    func convertToRaces(from kosular: [[String: Any]]) -> [Race] {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: kosular, options: [])
            let decoded = try JSONDecoder().decode([Race].self, from: jsonData)
            return decoded
        } catch {
            print("Conversion error in RaceButton: \(error)")
            return []
        }
    }
    
    var body: some View {
        Button(action: {
            selectedRace = raceName
            showRaceDetails = true
            Task{
                let program = try await parser.getProgramData(raceDate: dateFormatter.string(from: selectedDate), cityName: raceName)
                
                if let havaDictionary = program["hava"] as? [String: Any],
                   let data = HavaData(from: havaDictionary) {
                    self.havaData = data
                }
                
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    self.kosular = convertToRaces(from: kosularArray)
                }
                
                if let agfArray = program["agf"] as? [[String: Any]] {
                    self.agf = agfArray
                }
            }
        }) {
            
            HStack(spacing: 15) {
                Image(systemName: getCityIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                
                Text(raceName)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .frame(maxWidth: 300)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.teal, Color.cyan]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.4), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(CardPressEffectStyle())
    }
}

struct CardPressEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ContentView: View {
    
    init() {
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
    }
    
    @State private var jsonText: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var textValue: String = ""
    @State private var errorMessage: String?
    @State private var cities: [String] = []
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
    
    var minDate: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    }
    
    var maxDate : Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            if newDate >= minDate && newDate <= maxDate {
                selectedDate = newDate
                Task {
                    races = try await parser.getRaceCities(raceDate: dateFormatter.string(from: newDate))
                }
            }
        }
    }
    
    var body: some View {
        
        ZStack { 
            
            Color.black
                .ignoresSafeArea(.all)
            
            NavigationStack {
                ZStack {
                    
                    Image("back")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all)
                    
                    VStack {
                        
                        Spacer().frame(height: 170)
                        
                        HStack {
                            
                            Button(action: { changeDate(by: -1) }) {
                                Image(systemName: "chevron.left.circle.fill").font(.title)
                                    .foregroundColor(selectedDate > minDate ? .white : .gray)
                            }
                            .disabled(selectedDate <= minDate)
                            
                            Spacer()
                            
                            Text(displayDateFormatter.string(from: selectedDate))
                                .font(.headline).fontWeight(.bold).foregroundColor(.white)
                                .padding(.vertical, 10).lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: { changeDate(by: 1) }) {
                                Image(systemName: "chevron.right.circle.fill").font(.title)
                                    .foregroundColor(selectedDate < maxDate ? .white : .gray)
                            }
                            .disabled(selectedDate >= maxDate)
                            
                        }
                        .padding(.horizontal, 25)
                        .frame(height: 70)
                        .frame(maxWidth: 300)
                        .background(
                            
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        )
                        .shadow(color: .indigo.opacity(0.5), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 20)
                        
                        if races.isEmpty {
                            Text("Seçili tarihte yarış programı bulunamadı.")
                                .foregroundColor(.white.opacity(0.7)).padding(.top, 20)
                        } else {
                            HStack {
                                Spacer()
                                VStack(spacing: 15) {
                                    ForEach(races, id: \.self) { race in
                                        RaceCardButton(raceName: race, selectedRace: $selectedRace, selectedDate: $selectedDate, showRaceDetails: $showRaceDetails, havaData: $havaData, kosular: $kosular, agf: $agf, parser: parser, dateFormatter: dateFormatter)
                                    }
                                }
                                .padding(.vertical)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                            .navigationDestination(isPresented: $showRaceDetails) {
                                RaceDetailView(raceName: selectedRace ?? "Yarış Detayı", havaData: havaData ?? HavaData.default, kosular: kosular, agf: agf)
                            }
                    }
                }
                .onAppear() {
                    Task{
                        races = try await parser.getRaceCities(raceDate: dateFormatter.string(from: selectedDate))
                    }
                }
                .navigationTitle("")
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
    
    func convertToRaces(from kosular: [[String: Any]]) -> [Race] {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: kosular, options: [])
            let decoded = try JSONDecoder().decode([Race].self, from: jsonData)
            return decoded
        } catch {
            print("Conversion error: \(error)")
            return []
        }
    }
}

#Preview {
    ContentView()
}
