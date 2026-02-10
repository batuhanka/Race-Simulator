import SwiftUI

// MARK: - Models
struct ChecksumResponse: Codable {
    let runs: [String: [String]]?
    let success: Bool
}

struct RaceDetailResponse: Codable {
    let success: Bool
    let data: RaceData?
    let checksum: String?
}

struct RaceData: Codable {
    let muhtemeller: Muhtemeller?
}

struct DynamicTableRow: Identifiable {
    let id = UUID()
    let isFavori: Bool
    let isKosmaz: Bool
    let ekuriGrubu: String
    var cells: [TableCell]
}

struct TableCell {
    let label: String
    let odds: String
}

struct Muhtemeller: Codable {
    let key: String?
    let no: String?
    let saat: String?
    let durum: String?
    let bahisler: [Bahis]?
    
    enum CodingKeys: String, CodingKey {
        case key = "KEY", no = "NO", saat = "SAAT", durum = "DURUM", bahisler
    }
}

struct Bahis: Codable {
    let tur: String?
    let muhtemeller: [BahisOran]?
    enum CodingKeys: String, CodingKey { case tur = "B", muhtemeller }
}

struct BahisOran: Codable {
    let s1: String?, s2: String?, ganyan: String?, k: Bool?, a: Bool?
    let e: String?
    
    enum CodingKeys: String, CodingKey {
        case s1 = "S1", s2 = "S2", ganyan = "G", k = "K", a = "A", e = "E"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        s1 = try container.decodeIfPresent(String.self, forKey: .s1)
        s2 = try container.decodeIfPresent(String.self, forKey: .s2)
        ganyan = try container.decodeIfPresent(String.self, forKey: .ganyan)
        k = try container.decodeIfPresent(Bool.self, forKey: .k)
        a = try container.decodeIfPresent(Bool.self, forKey: .a)
        
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: .e) {
            e = stringValue
        } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: .e) {
            e = String(intValue)
        } else {
            e = nil
        }
    }
}

struct ProgramResponse: Codable {
    let kosular: [Kosul]?
}

struct Kosul: Codable {
    let no: String?
    let bilgiTr: String?
    let cinsDetay: String?
    let grup: String?
    let mesafe: String?
    let pist: String?

    enum CodingKeys: String, CodingKey {
        case no = "NO"
        case bilgiTr = "BILGI_TR"
        case cinsDetay = "CINSDETAY_TR"
        case grup = "GRUP_TR"
        case mesafe = "MESAFE"
        case pist = "PISTADI_TR"
    }
}

// MARK: - Main View
struct OddsView: View {
    let selectedDate: Date
    @State private var selectedTab: Int = 0
    @State private var runsData: [String: [String]] = [:]
    @State private var cities: [String] = []
    @State private var selectedCity: String? = nil
    @State private var selectedRun: Int = 1
    @State private var isLoading = false
    @State private var raceTime: String = ""
    @State private var raceStatus: String = ""
    
    // Muhtemeller Data
    @State private var tableRows: [DynamicTableRow] = []
    @State private var currentBahisTurleri: [String] = []
    
    // AGF Data
    @State private var agfTableRows: [DynamicTableRow] = []
    @State private var agfBahisTurleri: [String] = ["#", "At", "Jokey", "AGF"]
    
    @State private var raceInfo: String = ""

    private var turkishDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy EEEE"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            citySelectionBar
            
            if isLoading && cities.isEmpty {
                loadingView
            } else if cities.isEmpty {
                emptyStateView(message: "Seçilen tarih için henüz muhtemeller yayınlanmamıştır.")
            } else {
                runSelectionBar
                tabSelectionBar
                Spacer()
                statusInfoBar
                dynamicTableHeader
                dynamicMainList
            }
        }
        .background(Color(white: 0.12))
        .task {
            await loadInitialData()
        }
    }
}

// MARK: - View Components
extension OddsView {
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var citySelectionBar: some View {
        HStack {
            Menu {
                ForEach(cities, id: \.self) { city in
                    Button(city) {
                        selectedCity = city
                        selectedRun = 1
                        Task { await fetchRaceDetails() }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedCity ?? "Şehir Seçin")
                        .font(.system(size: 18, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
            }
            Spacer()
            Text(turkishDateString)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .frame(height: 55)
        .background(Color(white: 0.12))
    }
    
    private var tabSelectionBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Muhtemeller", index: 0)
            tabButton(title: "AGF", index: 1)
        }
        .background(Color.black)
        .overlay(Divider(), alignment: .bottom)
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(selectedTab == index ? .orange : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(white: 0.12))
                .overlay(
                    Rectangle()
                        .fill(selectedTab == index ? Color.orange : Color.clear)
                        .frame(height: 3),
                    alignment: .bottom
                )
        }
        .buttonStyle(.plain)
    }
    
    private var runSelectionBar: some View {
        let city = selectedCity ?? ""
        let matchingKeys = runsData.keys.filter { $0.hasPrefix(city) }.sorted { a, b in
            let numA = Int(a.components(separatedBy: "-").last ?? "0") ?? 0
            let numB = Int(b.components(separatedBy: "-").last ?? "0") ?? 0
            return numA < numB
        }
        
        return HStack(spacing: 4) {
            ForEach(0..<matchingKeys.count, id: \.self) { index in
                let kosuNo = "\(index + 1)"
                Button {
                    selectedRun = index + 1
                    Task { await fetchRaceDetails() }
                } label: {
                    Text(kosuNo)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selectedRun == (index + 1) ? .black : .white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(selectedRun == (index + 1) ? Color.orange : Color.white.opacity(0.12))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(white: 0.12))
    }
    
    private var statusInfoBar: some View {
        HStack {
            Label(raceTime, systemImage: "clock.fill")
            Spacer()
            Text(raceInfo)
        }
        .lineLimit(1)
        .font(.footnote).bold()
        .padding(.horizontal)
        .frame(height: 35)
        .background(Color(white: 0.9))
        .foregroundColor(.black)
    }
    
    private var dynamicTableHeader: some View {
        let headers = selectedTab == 0 ? currentBahisTurleri : agfBahisTurleri
        let rows = selectedTab == 0 ? tableRows : agfTableRows
        
        return Group {
            if !rows.isEmpty {
                HStack(spacing: 0) {
                    ForEach(0..<headers.count, id: \.self) { index in
                        Text(headers[index])
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                        if index < headers.count - 1 {
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1.5)
                        }
                    }
                }
                .frame(height: 35)
                .background(Color.white)
                .overlay(Divider(), alignment: .bottom)
            }
        }
    }
    
    private var dynamicMainList: some View {
        let rows = selectedTab == 0 ? tableRows : agfTableRows
        
        return ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    if rows.isEmpty && !isLoading {
                        emptyStateView(message: "\(selectedTab == 0 ? "Muhtemeller" : "AGF") verisi henüz yayınlanmamıştır.")
                    } else {
                        tableContent(for: rows)
                    }
                }
            }
            if isLoading && !rows.isEmpty {
                Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)
                ProgressView().tint(.orange)
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView().padding(.top, 100).tint(.orange)
    }
    
    private func tableContent(for rows: [DynamicTableRow]) -> some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                rowView(for: row)
            }
            Color.clear.frame(height: 60)
        }
    }
    
    private func rowView(for row: DynamicTableRow) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<row.cells.count, id: \.self) { index in
                cellView(for: row, at: index)
                if index < row.cells.count - 1 {
                    let currentEmpty = row.cells[index].label.isEmpty && row.cells[index].odds.isEmpty
                    if !currentEmpty {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1.5)
                    }
                }
            }
        }
        .frame(height: 48)
    }
    
    private func cellView(for row: DynamicTableRow, at index: Int) -> some View {
        let cell = row.cells[index]
        let isEmpty = cell.label.isEmpty && cell.odds.isEmpty
        let headers = selectedTab == 0 ? currentBahisTurleri : agfBahisTurleri
        
        let isGanyanColumn = index < headers.count && headers[index].uppercased().contains("GANYAN")
        let isAGFColumn = selectedTab == 1 && headers[index].uppercased() == "AGF"
        let shouldShowAsFavori = row.isFavori && (isGanyanColumn || isAGFColumn) && !row.isKosmaz
        
        let isKosmazCell = row.isKosmaz && isGanyanColumn
        
        return VStack(spacing: 0) {
            if !isEmpty {
                HStack(spacing: 2) {
                    Text(cell.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(shouldShowAsFavori ? .green : .primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    if isGanyanColumn && !row.ekuriGrubu.isEmpty {
                        ekuriIcon(for: row.ekuriGrubu)
                    }
                    
                    Spacer(minLength: 2)
                    
                    if isKosmazCell{
                        Text("Koşmaz")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                        
                    }else{
                        Text(cell.odds)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(shouldShowAsFavori ? .green : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .modifier(PulseModifier(active: shouldShowAsFavori))
                    }
                }
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1.5)
            } else {
                Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(isEmpty ? Color.clear : (isKosmazCell ? Color.gray.opacity(0.8) : Color.white))
    }

    private func ekuriIcon(for ekuri: String) -> some View {
        AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/\(ekuri).gif")) { phase in
            if let image = phase.image { image.resizable().scaledToFit() } else { Color.clear }
        }
        .frame(width: 14, height: 14)
    }
}

// MARK: - Data Fetching
extension OddsView {
    func loadInitialData() async {
        let f = DateFormatter(); f.dateFormat = "yyyyMMdd"
        let dateStr = f.string(from: selectedDate)
        let cf = DateFormatter(); cf.dateFormat = "yyyy/MM/dd"
        let urlStr = "https://vhs-medya.tjk.org/muhtemeller/s/\(cf.string(from: selectedDate))/checksum.json"
        
        await MainActor.run { isLoading = true }
        do {
            let parser = JsonParser()
            let localCities = (try? await parser.getRaceCities(raceDate: dateStr)) ?? []
            guard let url = URL(string: urlStr) else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ChecksumResponse.self, from: data)
            
            await MainActor.run {
                self.runsData = decoded.runs ?? [:]
                let allKeys = decoded.runs?.keys.map { $0 } ?? []
                self.cities = Array(Set(allKeys.compactMap { key -> String? in
                    let cityName = key.components(separatedBy: "-").first ?? ""
                    return localCities.contains(cityName) ? cityName : nil
                })).sorted()
                if selectedCity == nil || !cities.contains(selectedCity!) { selectedCity = cities.first }
                isLoading = false
                if selectedCity != nil { Task { await fetchRaceDetails() } }
            }
        } catch { await MainActor.run { isLoading = false } }
    }
    
    func fetchRaceDetails() async {
        guard let city = selectedCity else { return }
        await MainActor.run { isLoading = true }
        do {
            async let muhtemellerTask = fetchMuhtemeller(for: city, run: selectedRun)
            async let infoTask = fetchProgramInfo(for: city, run: selectedRun)
            // async let agfTask = fetchAGFData(for: city, run: selectedRun) // AGF verisi buraya gelecek
            
            let (details, info) = try await (muhtemellerTask, infoTask)
            
            await MainActor.run {
                self.raceTime = details.data?.muhtemeller?.saat ?? "--:--"
                self.raceStatus = details.data?.muhtemeller?.durum ?? ""
                self.raceInfo = info
                parseDataToRows(bahisler: details.data?.muhtemeller?.bahisler ?? [])
                // parseAGFData(agfData) // AGF verisi gelince burası dolacak
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.raceInfo = "Veri yüklenemedi"; self.tableRows = []; self.isLoading = false
            }
        }
    }
    
    private func fetchMuhtemeller(for city: String, run: Int) async throws -> RaceDetailResponse {
        let raceKey = "\(city)-\(run)"
        guard let hash = runsData[raceKey]?.first else { throw URLError(.badURL) }
        let f = DateFormatter(); f.dateFormat = "yyyy/MM/dd"
        let urlStr = "https://vhs-medya-cdn.tjk.org/muhtemeller/s/\(f.string(from: selectedDate))/\(raceKey)-\(hash).json"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(RaceDetailResponse.self, from: data)
    }
    
    private func fetchProgramInfo(for city: String, run: Int) async throws -> String {
        let f = DateFormatter(); f.dateFormat = "yyyyMMdd"
        let urlStr = "https://ebayi.tjk.org/s/d/program/\(f.string(from: selectedDate))/full/\(city).json"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ProgramResponse.self, from: data)
        if let kosul = decoded.kosular?.first(where: { $0.no == String(run) }) {
            return [kosul.cinsDetay, kosul.grup, kosul.mesafe, kosul.pist].compactMap { $0 }.joined(separator: ", ")
        }
        return ""
    }
    
    func parseDataToRows(bahisler: [Bahis]) {
        let cleanBahisler = bahisler.filter { $0.tur != nil }
        self.currentBahisTurleri = cleanBahisler.compactMap { $0.tur }
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
                        isFavori = m.a ?? false; isKosmaz = m.k ?? false
                    }
                    let label = m.s2 != nil ? "\(m.s1 ?? "")-\(m.s2!)" : (m.s1 ?? "")
                    cells.append(TableCell(label: label, odds: m.ganyan ?? ""))
                } else { cells.append(TableCell(label: "", odds: "")) }
            }
            newRows.append(DynamicTableRow(isFavori: isFavori, isKosmaz: isKosmaz, ekuriGrubu: ekuri, cells: cells))
        }
        self.tableRows = newRows
    }
}

// MARK: - Helpers
struct PulseModifier: ViewModifier {
    var active: Bool
    @State private var opacity: Double = 1.0
    func body(content: Content) -> some View {
        content.opacity(opacity).onAppear {
            if active {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { opacity = 0.4 }
            }
        }
    }
}

#Preview {
    OddsView(selectedDate: Date())
        .preferredColorScheme(.light)
}
