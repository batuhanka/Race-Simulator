//
//  RaceCardView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 29.12.2025.
//

import SwiftUI

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
        Button(action: fetchRaceDetails) {
            HStack(spacing: 15) {

                if isFetching {
                    ProgressView()
                        .tint(.white)
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
                LinearGradient(
                    gradient: Gradient(colors: [Color.teal, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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
            defer { isFetching = false }

            do {
                let program = try await parser.getProgramData(
                    raceDate: dateFormatter.string(from: selectedDate),
                    cityName: raceName
                )

                if let havaDict = program["hava"] as? [String: Any] {
                    havaData = HavaData(from: havaDict)
                }

                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let data = try JSONSerialization.data(withJSONObject: kosularArray)
                    kosular = try JSONDecoder().decode([Race].self, from: data)
                }

                if let agfArray = program["agf"] as? [[String: Any]] {
                    agf = agfArray
                }

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
