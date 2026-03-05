import SwiftUI
import Observation

@MainActor
@Observable
class TicketViewModel {

    var isLoading = true
    var raceDays: [BetRaceDay] = []
    var selectedRaceDay: BetRaceDay?
    var selectedBetType: BetType?
    var selectedRace: BetRace?
    var errorMessage: String?
    var selectedHorses: [String: Set<String>] = [:]
    var multiplier: Int = 1

    private let initialSelections: [String: Set<String>]?
    private let initialDay: BetRaceDay?
    private let initialBet: BetType?
    private let initialDays: [BetRaceDay]?
    private let parser = JsonParser()
    private var hasLoadedInitially = false
    private var isFirstRaceDayChange = true

    init(initialSelections: [String: Set<String>]? = nil,
         initialDay: BetRaceDay? = nil,
         initialBet: BetType? = nil,
         initialDays: [BetRaceDay]? = nil) {
        self.initialSelections = initialSelections
        self.initialDay = initialDay
        self.initialBet = initialBet
        self.initialDays = initialDays
    }

    // MARK: - Computed

    var ganyanBetTypes: [BetType] {
        guard let raceDay = selectedRaceDay else { return [] }
        let allowedTypes = ["6'lı Ganyan", "5'li Ganyan", "4'lü Ganyan", "3'lü Ganyan"]
        return raceDay.bahisler.filter { type in
            allowedTypes.contains { type.BAHIS.localizedCaseInsensitiveContains($0) }
        }
    }

    // MARK: - onChange Handlers

    func onRaceDayChanged(to newValue: BetRaceDay?) {
        guard hasLoadedInitially else { return }
        let isFirst = isFirstRaceDayChange
        isFirstRaceDayChange = false
        if let bahisler = newValue?.bahisler {
            selectedBetType = findPriorityBetType(in: bahisler)
        }
        // On the first onChange after load, preserve AI-generated selections
        if isFirst && initialSelections != nil { return }
        resetSelections()
    }

    func onBetTypeChanged(to newValue: BetType?) {
        if initialSelections == nil { resetSelections() }
        if let firstRace = filteredRaces(for: selectedRaceDay, betType: newValue).first {
            selectedRace = firstRace
        }
    }

    // MARK: - Data Fetching

    func loadBettingData() async {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return }

        // TicketSetupView'dan gelen liste varsa yeniden fetch yapma
        if let days = initialDays {
            raceDays = days
            isLoading = false
            if let day = initialDay {
                selectedRaceDay = day
                selectedBetType = initialBet
                if let selections = initialSelections { selectedHorses = selections }
            } else {
                selectedRaceDay = days.first
            }
            hasLoadedInitially = true
            return
        }

        do {
            let decoded = try await parser.getBetData()
            let filtered = decoded.data.yarislar.filter { (Int($0.KOD) ?? 99) < 11 }

            raceDays = filtered
            isLoading = false

            if let day = initialDay {
                selectedRaceDay = day
                selectedBetType = initialBet
                if let selections = initialSelections { selectedHorses = selections }
            } else {
                selectedRaceDay = filtered.first
            }
            hasLoadedInitially = true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Selection Logic

    func toggleHorseSelection(raceId: String, horseKod: String) {
        var selections = selectedHorses[raceId] ?? []
        if selections.contains(horseKod) { selections.remove(horseKod) }
        else { selections.insert(horseKod) }
        selectedHorses[raceId] = selections
    }

    func isAllSelected(in race: BetRace) -> Bool {
        let validKods = race.atlar?.filter { $0.KOSMAZ != true }.map { $0.KOD } ?? []
        guard !validKods.isEmpty else { return false }
        let selected = selectedHorses[race.KOD] ?? []
        return validKods.allSatisfy { selected.contains($0) }
    }

    func toggleAllHorses(in race: BetRace) {
        let validKods = race.atlar?.filter { $0.KOSMAZ != true }.map { $0.KOD } ?? []
        selectedHorses[race.KOD] = isAllSelected(in: race) ? [] : Set(validKods)
    }

    func resetSelections() {
        selectedHorses = [:]
        multiplier = 1
    }

    // MARK: - Calculations

    func calculateBetCombinations() -> Int {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType else { return 0 }
        let races = filteredRaces(for: raceDay, betType: betType)
        if races.count > 1 {
            let product = races.reduce(1) { $0 * max(selectedHorses[$1.KOD]?.count ?? 0, 1) }
            let totalSelected = selectedHorses.values.reduce(0) { $0 + $1.count }
            return totalSelected == 0 ? 0 : product
        } else {
            return races.reduce(0) { $0 + (selectedHorses[$1.KOD]?.count ?? 0) }
        }
    }

    func calculateTotalBetAmount() -> Double {
        guard let betType = selectedBetType else { return 0.0 }
        return Double(calculateBetCombinations()) * Double(multiplier) * (Double(betType.POOLUNIT) / 100.0)
    }

    // MARK: - Helpers

    func filteredRaces(for raceDay: BetRaceDay?, betType: BetType?) -> [BetRace] {
        guard let raceDay, let betType, let allRaces = raceDay.kosular else { return [] }
        let startRaceNo = betType.kosular.first ?? 1
        let name = betType.BAHIS.lowercased()
        var legCount = 1
        if name.contains("7'li") { legCount = 7 }
        else if name.contains("6'lı") { legCount = 6 }
        else if name.contains("5'li") { legCount = 5 }
        else if name.contains("4'lü") { legCount = 4 }
        else if name.contains("3'lü") { legCount = 3 }
        let sorted = allRaces.sorted { (Int($0.NO) ?? 0) < (Int($1.NO) ?? 0) }
        if let startIndex = sorted.firstIndex(where: { Int($0.NO) == startRaceNo }) {
            return Array(sorted[startIndex..<min(startIndex + legCount, sorted.count)])
        }
        return []
    }

    func getLegSelections() -> [String] {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType else { return [] }
        return filteredRaces(for: raceDay, betType: betType).map { race in
            let selectedCodes = selectedHorses[race.KOD] ?? []
            if selectedCodes.isEmpty { return "-" }
            let validKods = race.atlar?.filter { $0.KOSMAZ != true }.map { $0.KOD } ?? []
            if !validKods.isEmpty && validKods.allSatisfy({ selectedCodes.contains($0) }) { return "HEPSİ" }
            let horseNos = race.atlar?.filter { selectedCodes.contains($0.KOD) }
                .compactMap { Int($0.NO) }.sorted().map { String($0) } ?? []
            return horseNos.joined(separator: "-")
        }
    }

    func formattedRaceDayTitle(for day: BetRaceDay?) -> String {
        guard let day else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        guard let date = formatter.date(from: day.TARIH) else { return day.YER.turkishCityUppercased }
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "tr_TR")
        dayFormatter.dateFormat = "EEEE"
        return "\(day.YER.turkishCityUppercased) (\(dayFormatter.string(from: date).uppercased()))"
    }

    func betTypeLabel(for type: BetType) -> String {
        let allowed = ["6'lı Ganyan", "5'li Ganyan", "4'lü Ganyan", "3'lü Ganyan"]
        let filteredList = (selectedRaceDay?.bahisler ?? []).filter { t in
            allowed.contains { t.BAHIS.localizedCaseInsensitiveContains($0) }
        }
        let sameNameTypes = filteredList.filter { $0.BAHIS == type.BAHIS }
        if sameNameTypes.count > 1 {
            let sorted = sameNameTypes.sorted { ($0.kosular.first ?? 0) < ($1.kosular.first ?? 0) }
            if let index = sorted.firstIndex(where: { $0.id == type.id }) {
                return "\(index + 1). \(type.BAHIS.uppercased())"
            }
        }
        return type.BAHIS.uppercased()
    }

    private func findPriorityBetType(in types: [BetType]) -> BetType? {
        let priority = ["6'lı Ganyan", "5'li Ganyan", "4'lü Ganyan", "3'lü Ganyan"]
        for name in priority {
            if let found = types.first(where: { $0.BAHIS.localizedCaseInsensitiveContains(name) }) {
                return found
            }
        }
        return nil
    }
}
