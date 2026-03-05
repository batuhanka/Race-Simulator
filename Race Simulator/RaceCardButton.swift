import SwiftUI

// MARK: - Turkish City Name Helper

extension String {
    private static let turkishCityMap: [String: String] = [
        "sanliurfa":  "ŞANLIURFA",
        "elazig":     "ELAZIĞ",
        "izmir":      "İZMİR",
        "istanbul":   "İSTANBUL",
        "diyarbakir": "DİYARBAKIR",
        "kocaeli":    "KOCAELİ",
        "adana":      "ADANA",
        "bursa":      "BURSA",
        "ankara":     "ANKARA",
        "antalya":    "ANTALYA",
    ]

    var turkishCityUppercased: String {
        let key = self.lowercased()
            .replacingOccurrences(of: "ş", with: "s")
            .replacingOccurrences(of: "ğ", with: "g")
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "ç", with: "c")
            .replacingOccurrences(of: "İ", with: "i")
            .replacingOccurrences(of: "î", with: "i")
        return String.turkishCityMap[key]
            ?? self.uppercased(with: Locale(identifier: "tr_TR"))
    }
}

// MARK: - Button Press Effect
struct CardPressEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Race Card Button
struct RaceCardButton: View {
    
    let raceName: String
    var action: (() -> Void)? = nil
    @Binding var selectedRace: String?
    @Binding var selectedDate: Date
    @Binding var showRaceDetails: Bool
    @Binding var havaData: HavaData?
    @Binding var kosular: [Race]
    @Binding var agf: [[String: Any]]
    @Binding var selectedBottomTab: Int
    
    let parser: JsonParser
    let dateFormatter: DateFormatter
    
    @State private var isFetching: Bool = false
    
    // MARK: - Otomatik Görsel İsimlendirme
    private func getBackgroundImageName() -> String {
        var name = raceName.lowercased(with: Locale(identifier: "tr_TR"))
        
        let replacements = [
            "ç": "c", "ğ": "g", "ı": "i", "ö": "o", "ş": "s", "ü": "u", "i̇": "i"
        ]
        
        for (target, replacement) in replacements {
            name = name.replacingOccurrences(of: target, with: replacement)
        }
        
        return name + "hipodrom"
    }
    
    var body: some View {
        Button(action: {
            selectedBottomTab = 1
            if let customAction = action {
                customAction()
            } else {
                fetchRaceDetails()
            }
        }) {
            ZStack {
                Image(getBackgroundImageName())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.85),
                        Color.black.opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(raceName.turkishCityUppercased)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .tracking(1)
                        
                    }
                    
                    Spacer()
                    
                }
                .foregroundColor(.white)
                .padding(.horizontal, 25)
            }
            .frame(height: 110)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2)) 
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .cyan.opacity(0.25), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(CardPressEffectStyle())
        .disabled(isFetching)
    }
    
    private func fetchRaceDetails() {
        isFetching = true
        Task {
            defer { isFetching = false }
            do {
                let program = try await parser.getProgramData(
                    raceDate: dateFormatter.string(from: selectedDate),
                    cityName: raceName
                )
                if let havaDict = program["hava"] as? [String: Any] { havaData = HavaData(from: havaDict) }
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let data = try JSONSerialization.data(withJSONObject: kosularArray)
                    kosular = try JSONDecoder().decode([Race].self, from: data)
                }
                if let agfArray = program["agf"] as? [[String: Any]] { agf = agfArray }
                await MainActor.run {
                    selectedRace = raceName
                    showRaceDetails = true
                }
            } catch {
                print("Detay getirme hatası: \(error)")
            }
        }
    }
}

