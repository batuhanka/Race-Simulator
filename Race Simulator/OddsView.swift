import SwiftUI

// MARK: - API Modelleri
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
    let s1: String?, s2: String?, ganyan: String?, k: Bool?, a: Bool?, e: String?
    enum CodingKeys: String, CodingKey { case s1 = "S1", s2 = "S2", ganyan = "G", k = "K", a = "A", e = "E" }
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

struct PulseText: View {
    let label: String
    let odds: String
    let color: Color
    let fontSizeLabel: CGFloat
    let fontSizeOdds: CGFloat
    
    @State private var opacity: Double = 1.0
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: fontSizeLabel, weight: .bold))
            Spacer()
            Text(odds)
                .font(.system(size: fontSizeOdds, design: .monospaced))
        }
        .foregroundColor(color)
        .opacity(opacity)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                opacity = 0.3
            }
        }
    }
}

// MARK: - Ana View
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
    @State private var tableRows: [DynamicTableRow] = []
    @State private var currentBahisTurleri: [String] = []
    @State private var selectedRace: Race? = nil
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
                tabSelectionBar
                runSelectionBar
                
                if selectedTab == 0 {
                    statusInfoBar
                    dynamicTableHeader
                    dynamicMainList
                } else {
                    agfPlaceholderView
                }
            }
        }
        .background(Color(white: 0.12))
        .task {
            await loadInitialData()
        }
    }
}


// MARK: - View Bileşenleri
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
    
    private var agfPlaceholderView: some View {
        VStack {
            Spacer()
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
                .padding(.bottom, 10)
            Text("At Yarışı Genel Favorileri (AGF)")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Bu veri yakında aktif olacaktır.")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.6))
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
                    Text(selectedCity ?? "")
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
            Button {
                selectedTab = 0
            } label: {
                Text("Muhtemeller")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(selectedTab == 0 ? .orange : .gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(white: 0.12))
                    .overlay(
                        Rectangle()
                            .fill(selectedTab == 0 ? Color.orange : Color.clear)
                            .frame(height: 3),
                        alignment: .bottom
                    )
            }
            .buttonStyle(.plain)
            
            Button {
                selectedTab = 1
            } label: {
                Text("AGF")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(selectedTab == 1 ? .orange : .gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(white: 0.12))
                    .overlay(
                        Rectangle()
                            .fill(selectedTab == 1 ? Color.orange : Color.clear)
                            .frame(height: 3),
                        alignment: .bottom
                    )
            }
            .buttonStyle(.plain)
        }
        .background(Color.black)
        .overlay(Divider(), alignment: .bottom)
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
                let buttonColors = [Color.orange, Color.orange.opacity(0.8)]
                
                Button {
                    selectedRun = index + 1
                    Task { await fetchRaceDetails() }
                } label: {
                    Text(kosuNo)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selectedRun == (index + 1) ? .black : .white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Group {
                                if selectedRun == (index + 1) {
                                    LinearGradient(colors: buttonColors, startPoint: .top, endPoint: .bottom)
                                } else {
                                    Color.white.opacity(0.12)
                                }
                            }
                        )
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(white: 0.12))
    }
    
    private func fetchRaceInfo(_ run: Int, _ city: String?, _ date: Date) async -> String {
        guard let city = city else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: date)

        let urlString = "https://ebayi.tjk.org/s/d/program/\(dateString)/full/\(city).json"

        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let decoded = try? JSONDecoder().decode(ProgramResponse.self, from: data) else {
            return ""
        }

        if let kosul = decoded.kosular?.first(where: { $0.no == String(run) }) {
            let merged = [kosul.cinsDetay, kosul.grup, kosul.mesafe, kosul.pist]
                .compactMap{ $0 }
                .joined(separator: ", ")
            return merged.isEmpty ? "" : merged
        }
        return ""
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
        .task {
            raceInfo = await fetchRaceInfo(selectedRun, selectedCity, selectedDate)
        }
        .onChange(of: selectedRun) {
            Task {
                raceInfo = await fetchRaceInfo(selectedRun, selectedCity, selectedDate)
            }
        }
    }
    
    private var dynamicTableHeader: some View {
        Group {
            if !tableRows.isEmpty {
                HStack(spacing: 0) {
                    ForEach(0..<currentBahisTurleri.count, id: \.self) { index in
                        Text(currentBahisTurleri[index])
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                        if index < currentBahisTurleri.count - 1 {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1.5)
                        }
                    }
                }
                .frame(height: 35)
                .background(Color.white)
                .overlay(VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1.5)
                    Spacer()
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1.5)
                })
            }
        }
    }
    
    private var dynamicMainList: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    if tableRows.isEmpty && !isLoading {
                        emptyStateView(message: "\(turkishDateString) tarihi için muhtemeller henüz yayınlanmamıştır.")
                    } else {
                        tableContent
                    }
                }
            }
            
            if isLoading && !tableRows.isEmpty {
                Color.black.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
                    .tint(.orange)
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .padding(.top, 100)
            .tint(.orange)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 80)
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("\(turkishDateString) tarihi için muhtemeller henüz yayınlanmamıştır.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var tableContent: some View {
        VStack(spacing: 0) {
            let visibleRows = tableRows.filter { hasAnyContent(in: $0) }
            
            ForEach(visibleRows, id: \.id) { row in
                        rowView(for: row)
                    }
            
            Color.clear.frame(height: 60)
        }
    }
    
    private func hasAnyContent(in row: DynamicTableRow) -> Bool {
        return row.cells.contains { !$0.label.isEmpty || !$0.odds.isEmpty }
    }
    
    private func rowView(for row: DynamicTableRow) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<row.cells.count, id: \.self) { index in
                cellView(for: row, at: index)
                if index < row.cells.count - 1 && !isCellEmpty(row: row, fromIndex: index) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1.5)
                }
            }
        }
        .frame(height: 48)
    }
    
    private func cellView(for row: DynamicTableRow, at index: Int) -> some View {
        let cell = row.cells[index]
        let isEmpty = cell.label.isEmpty && cell.odds.isEmpty
        let isFavoriLabel = row.isFavori && index == 0
        
        return VStack(spacing: 0) {
            HStack(spacing: 4) {
                if !isEmpty {
                    if isFavoriLabel {
                        PulseText(
                            label: cell.label,
                            odds: cell.odds,
                            color: .green,
                            fontSizeLabel: calculateSize(for: cell.label),
                            fontSizeOdds: calculateSize(for: cell.odds)
                        )
                    } else {
                        HStack(spacing: 4) {
                            Text(cell.label)
                                .font(.system(size: calculateSize(for: cell.label), weight: .bold))
                            
                            if shouldShowEkuriIcon(for: row, at: index) {
                                ekuriIcon(for: row)
                            }
                            
                            Spacer()
                            
                            Text(cell.odds)
                                .font(.system(size: calculateSize(for: cell.odds), design: .monospaced))
                        }
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    }
                }
            }
            .padding(.horizontal, isEmpty ? 0 : 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !isEmpty {
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1.5)
            } else {
                Color.clear.frame(height: 1.5)
            }
        }
        .background(
            isEmpty ? Color.clear : (index == 0 && row.isKosmaz ? Color.gray.opacity(0.8) : Color.white)
        )
    }
                
     
    
    private func calculateSize(for odds: String) -> CGFloat {
        let length = odds.count
        if length > 6 {
            return 10
        } else if length > 5 {
            return 11
        }
        return 14
    }
    
    private func isCellEmpty(row: DynamicTableRow, fromIndex: Int) -> Bool {
        let currentEmpty = row.cells[fromIndex].label.isEmpty && row.cells[fromIndex].odds.isEmpty
        let nextEmpty = fromIndex + 1 < row.cells.count &&
        row.cells[fromIndex + 1].label.isEmpty &&
        row.cells[fromIndex + 1].odds.isEmpty
        
        return currentEmpty && nextEmpty
    }
    
    private func shouldShowEkuriIcon(for row: DynamicTableRow, at index: Int) -> Bool {
        return currentBahisTurleri[index] == "GANYAN" && !row.ekuriGrubu.isEmpty
    }
    
    private func ekuriIcon(for row: DynamicTableRow) -> some View {
        AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/e\(row.ekuriGrubu).gif")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
            case .failure, .empty:
                EmptyView()
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 16, height: 16)
    }
    
    private func labelColor(for row: DynamicTableRow, at index: Int) -> Color {
        return (row.isFavori && index == 0) ? .green : .primary
    }
    
    private func rowBackground(for row: DynamicTableRow) -> Color {
        if row.isKosmaz {
            return Color.gray.opacity(0.8)
        }
        return Color.white
    }
}

// MARK: - Data Fetching
extension OddsView {
    
    func loadInitialData() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: selectedDate)
        
        let checksumFormatter = DateFormatter()
        checksumFormatter.dateFormat = "yyyy/MM/dd"
        let checksumPath = checksumFormatter.string(from: selectedDate)
        
        let urlString = "https://vhs-medya.tjk.org/muhtemeller/s/\(checksumPath)/checksum.json"
        
        await MainActor.run { isLoading = true }
        
        let parser = JsonParser()
        let localCities = (try? await parser.getRaceCities(raceDate: dateString)) ?? []
        
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let decoded = try? JSONDecoder().decode(ChecksumResponse.self, from: data) else {
            await MainActor.run { isLoading = false }; return
        }
        
        await MainActor.run {
            self.runsData = decoded.runs ?? [:]
            let allKeys = decoded.runs?.keys.map { $0 } ?? []
            self.cities = Array(Set(allKeys.compactMap { key -> String? in
                let cityName = key.components(separatedBy: "-").first ?? ""
                return localCities.contains(cityName) ? cityName : nil
            })).sorted()
            
            if selectedCity == nil || !cities.contains(selectedCity!) {
                selectedCity = cities.first
            }
            isLoading = false
            if selectedCity != nil { Task { await fetchRaceDetails() } }
        }
    }
    
    func fetchRaceDetails() async {
        guard let city = selectedCity else { return }
        let raceKey = "\(city)-\(selectedRun)"
        guard let hash = runsData[raceKey]?.first else { return }
        
        let f = DateFormatter(); f.dateFormat = "yyyy/MM/dd"
        let urlString = "https://vhs-medya-cdn.tjk.org/muhtemeller/s/\(f.string(from: selectedDate))/\(raceKey)-\(hash).json"
        
        await MainActor.run { isLoading = true }
        
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let decoded = try? JSONDecoder().decode(RaceDetailResponse.self, from: data) else {
            await MainActor.run { isLoading = false }; return
        }
        
        await MainActor.run {
            self.raceTime = decoded.data?.muhtemeller?.saat ?? "--:--"
            self.raceStatus = decoded.data?.muhtemeller?.durum ?? ""
            parseDataToRows(bahisler: decoded.data?.muhtemeller?.bahisler ?? [])
            isLoading = false
        }
    }
    
    func parseDataToRows(bahisler: [Bahis]) {
        self.currentBahisTurleri = bahisler.compactMap { $0.tur }
        let maxRows = bahisler.map { $0.muhtemeller?.count ?? 0 }.max() ?? 0
        var newRows: [DynamicTableRow] = []
        
        for i in 0..<maxRows {
            var rowCells: [TableCell] = []
            var favoriMi = false
            var kosmazMi = false
            var ekuriGrubu: String? = nil
            
            for bahis in bahisler {
                let muhtemeller = bahis.muhtemeller ?? []
                if i < muhtemeller.count {
                    let m = muhtemeller[i]
                    if bahis.tur == "GANYAN" {
                        favoriMi = m.a ?? false
                        kosmazMi = m.k ?? false
                        ekuriGrubu = m.e
                    }
                    let label = m.s2 != nil ? "\(m.s1 ?? "")-\(m.s2 ?? "")" : (m.s1 ?? "")
                    let odds = m.k == true ? "K" : (m.ganyan ?? "-")
                    rowCells.append(TableCell(label: label, odds: odds))
                } else {
                    rowCells.append(TableCell(label: "", odds: ""))
                }
            }
            newRows.append(DynamicTableRow(isFavori: favoriMi, isKosmaz: kosmazMi, ekuriGrubu: ekuriGrubu ?? "", cells: rowCells))
        }
        self.tableRows = newRows
        
    }
}

#Preview {
    OddsView(selectedDate: Date())
        .preferredColorScheme(.light)
}

struct OddsView_Previews: PreviewProvider {
    static var previews: some View {
        OddsView(selectedDate: Date())
            .previewDisplayName("Live Odds Trial")
    }
}
