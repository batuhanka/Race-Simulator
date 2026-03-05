import SwiftUI
import Observation

@MainActor
@Observable
class OddsViewModel {

    let selectedDate: Date

    var selectedTab: Int = 0
    var runsData: [String: [String]] = [:]
    var cities: [String] = []
    var selectedCity: String? = nil
    var selectedRun: Int = 1
    var isLoading = false
    var raceTime: String = ""
    var raceStatus: String = ""
    var tableRows: [DynamicTableRow] = []
    var currentBahisTurleri: [String] = []
    var agfTableRows: [DynamicTableRow] = []
    let agfBahisTurleri: [String] = ["#", "At", "Jokey", "AGF"]
    var raceInfo: String = ""

    private var fetchTask: Task<Void, Never>?
    private var refreshTimer: Timer?
    private let parser = JsonParser()

    init(selectedDate: Date, initialTab: Int = 0) {
        self.selectedDate = selectedDate
        self.selectedTab = initialTab
    }

    var turkishDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy EEEE"
        return formatter.string(from: selectedDate)
    }

    // MARK: - Timer Management

    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshMuhtemellerData()
            }
        }
    }

    func manageRefreshTimer() {
        stopRefreshTimer()
        guard selectedTab == 0 else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let time = formatter.date(from: raceTime) else { return }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        guard let hour = timeComponents.hour,
              let minute = timeComponents.minute,
              let raceDateTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: selectedDate)
        else { return }

        let timeDifference = raceDateTime.timeIntervalSince(Date())
        if timeDifference < (30 * 60) && timeDifference > (-10 * 60) {
            startRefreshTimer()
        }
    }

    // MARK: - Data Fetching

    func refreshMuhtemellerData() async {
        guard let city = selectedCity, !isLoading else { return }
        do {
            let details = try await fetchMuhtemeller(for: city, run: selectedRun)
            let bahisler = details.data?.muhtemeller?.bahisler ?? []
            parseDataToRows(bahisler: bahisler)
            raceTime = details.data?.muhtemeller?.saat ?? "--:--"
            raceStatus = details.data?.muhtemeller?.durum ?? ""
        } catch {
            print("Silent refresh failed: \(error.localizedDescription)")
        }
    }

    func loadInitialData() async {
        let f = DateFormatter(); f.dateFormat = "yyyyMMdd"
        let dateStr = f.string(from: selectedDate)

        isLoading = true
        do {
            let localCities = (try? await parser.getRaceCities(raceDate: dateStr)) ?? []
            let decoded = try await parser.getMuhtemellerChecksum(date: selectedDate)

            runsData = decoded.runs ?? [:]
            let allKeys = decoded.runs?.keys.map { $0 } ?? []
            cities = Array(Set(allKeys.compactMap { key -> String? in
                let cityName = key.components(separatedBy: "-").first ?? ""
                return localCities.contains(cityName) ? cityName : nil
            })).sorted()
            if selectedCity == nil || !cities.contains(selectedCity!) { selectedCity = cities.first }
            isLoading = false
            if selectedCity != nil { fetchRaceDetails() }
        } catch {
            isLoading = false
        }
    }

    func fetchRaceDetails() {
        fetchTask?.cancel()
        stopRefreshTimer()
        guard let city = selectedCity else { return }
        let runToFetch = selectedRun

        fetchTask = Task {
            isLoading = true
            do {
                async let muhtemellerTask = fetchMuhtemeller(for: city, run: runToFetch)
                async let infoTask = fetchProgramInfo(for: city, run: runToFetch)
                let (details, programResult) = try await (muhtemellerTask, infoTask)

                try Task.checkCancellation()
                guard runToFetch == self.selectedRun else { return }

                raceTime = details.data?.muhtemeller?.saat ?? "--:--"
                raceStatus = details.data?.muhtemeller?.durum ?? ""
                raceInfo = programResult.info

                let bahisler = details.data?.muhtemeller?.bahisler ?? []
                var ekuriMap: [String: String] = [:]
                if let ganyanBahis = bahisler.first(where: { $0.tur?.uppercased().contains("GANYAN") == true }),
                   let muhtemeller = ganyanBahis.muhtemeller {
                    for m in muhtemeller {
                        if let horseNo = m.s1, let ekuri = m.e, !ekuri.isEmpty, ekuri != "0" {
                            ekuriMap[horseNo] = "e\(ekuri)"
                        }
                    }
                }

                parseDataToRows(bahisler: bahisler)
                parseAGFData(from: programResult.fullResponse, ekuriMap: ekuriMap, for: runToFetch)
                isLoading = false
                manageRefreshTimer()
            } catch is CancellationError {
                // Task iptal edildi
            } catch {
                if !Task.isCancelled {
                    raceInfo = "Veri yüklenemedi"
                    tableRows = []
                    agfTableRows = []
                    isLoading = false
                }
            }
        }
    }

    private func fetchMuhtemeller(for city: String, run: Int) async throws -> RaceDetailResponse {
        let raceKey = "\(city)-\(run)"
        guard let hash = runsData[raceKey]?.first else { throw URLError(.badURL) }
        return try await parser.getMuhtemeller(date: selectedDate, raceKey: raceKey, hash: hash)
    }

    private func fetchProgramInfo(for city: String, run: Int) async throws -> (info: String, fullResponse: ProgramResponse) {
        let decoded = try await parser.getProgramResponse(date: selectedDate, cityName: city)
        var infoStr = ""
        if let kosu = decoded.kosular?.first(where: { $0.RACENO == String(run) }) {
            infoStr = [kosu.CINSDETAY_TR, kosu.GRUP_TR, kosu.MESAFE, kosu.PISTADI_TR]
                .compactMap { $0 }.joined(separator: ", ")
        }
        return (infoStr, decoded)
    }

    // MARK: - Parsing

    func parseAGFData(from program: ProgramResponse, ekuriMap: [String: String], for run: Int) {
        guard let race = program.kosular?.first(where: { $0.RACENO == String(run) }),
              let atlar = race.atlar else {
            agfTableRows = []
            return
        }

        let sortedAtlar = atlar.sorted { a, b in
            let rankA = a.AGFSIRA2 ?? a.AGFSIRA1
            let rankB = b.AGFSIRA2 ?? b.AGFSIRA1
            if let rankA, let rankB {
                if rankA != rankB { return rankA < rankB }
            } else if rankA != nil { return true }
            else if rankB != nil { return false }
            return (Int(a.NO ?? "0") ?? 0) < (Int(b.NO ?? "0") ?? 0)
        }

        agfTableRows = sortedAtlar.compactMap { horse -> DynamicTableRow? in
            let agfSira = horse.AGFSIRA2 ?? horse.AGFSIRA1
            guard let finalAgfSira = agfSira else { return nil }

            let cells = [
                TableCell(label: horse.NO ?? "", odds: ""),
                TableCell(label: horse.AD ?? "", odds: ""),
                TableCell(label: horse.JOKEYADI ?? "", odds: ""),
                TableCell(
                    label: horse.AGF1.map { "%" + $0 } ?? "",
                    odds: horse.AGF2.map { "%" + $0 } ?? ""
                )
            ]

            return DynamicTableRow(
                isFavori: finalAgfSira == 1,
                isKosmaz: horse.KOSMAZ ?? false,
                ekuriGrubu: ekuriMap[horse.NO ?? ""] ?? "",
                cells: cells
            )
        }
    }

    func parseDataToRows(bahisler: [Bahis]) {
        let cleanBahisler = bahisler.filter { $0.tur != nil }
        currentBahisTurleri = cleanBahisler.compactMap { $0.tur }
        let maxRows = cleanBahisler.map { $0.muhtemeller?.count ?? 0 }.max() ?? 0
        var newRows: [DynamicTableRow] = []
        for i in 0..<maxRows {
            var cells: [TableCell] = []
            var isFavori = false, isKosmaz = false, ekuri = ""
            for bahis in cleanBahisler {
                if let muhtemeller = bahis.muhtemeller, i < muhtemeller.count {
                    let m = muhtemeller[i]
                    if let e = m.e, !e.isEmpty && e != "0" { ekuri = "e\(e)" }
                    if bahis.tur?.uppercased().contains("GANYAN") == true {
                        isFavori = m.a ?? false
                        isKosmaz = m.k ?? false
                    }
                    let label = m.s2 != nil ? "\(m.s1 ?? "")-\(m.s2!)" : (m.s1 ?? "")
                    cells.append(TableCell(label: label, odds: m.ganyan ?? ""))
                } else {
                    cells.append(TableCell(label: "", odds: ""))
                }
            }
            newRows.append(DynamicTableRow(isFavori: isFavori, isKosmaz: isKosmaz, ekuriGrubu: ekuri, cells: cells))
        }
        tableRows = newRows
    }
}
