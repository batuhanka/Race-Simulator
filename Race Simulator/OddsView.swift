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
    enum CodingKeys: String, CodingKey { case s1 = "S1", s2 = "S2", ganyan = "G", k = "K", a = "A" }
}

// MARK: - Ana View
struct OddsView: View {
    let selectedDate: Date
    @State private var runsData: [String: [String]] = [:]
    @State private var cities: [String] = []
    @State private var selectedCity: String? = nil
    @State private var selectedRun: Int = 1
    @State private var isLoading = false
    @State private var raceTime: String = ""
    @State private var raceStatus: String = ""
    
    // Değişen State Tanımları
    @State private var tableRows: [DynamicTableRow] = [] // TİP GÜNCELLENDİ
    @State private var currentBahisTurleri: [String] = []
    
    private var turkishDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy EEEE"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            citySelectionBar
            if !tableRows.isEmpty {
                runSelectionBar
                statusInfoBar
                dynamicTableHeader
            }
            dynamicMainList
        }
        .background(Color.white)
        .task {
            await loadInitialData()
        }
    }
}

// MARK: - View Bileşenleri
extension OddsView {
    
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
        .background(Color(white: 0.15))
    }
    
    private var statusInfoBar: some View {
        HStack {
            Spacer()
            Label(raceTime, systemImage: "clock.fill")
                .font(.subheadline.bold())
        }
        .padding(.horizontal)
        .frame(height: 35)
        .background(Color(white: 0.9))
        .foregroundColor(.black)
    }

    // DİNAMİK HEADER
    private var dynamicTableHeader: some View {
        Group {
            if !tableRows.isEmpty {
                HStack(spacing: 0) {
                    ForEach(0..<currentBahisTurleri.count, id: \.self) { index in
                        Text(currentBahisTurleri[index])
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                        if index < currentBahisTurleri.count - 1 { Divider() }
                    }
                }
                .frame(height: 35)
                .background(Color.white)
                .overlay(VStack{Divider(); Spacer(); Divider()})
            }
        }
    }
    
    // DİNAMİK LİSTE
    private var dynamicMainList: some View {
        ScrollView {
            VStack(spacing: 0) {
                        if isLoading {
                            ProgressView()
                                .padding(.top, 100)
                                .tint(.orange) // Uygulama rengine uyum sağlar
                        } else if tableRows.isEmpty {
                            // VERİ OLMADIĞI DURUM TASARIMI
                            VStack(spacing: 20) {
                                Spacer(minLength: 80)
                                
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                VStack(spacing: 8) {
                                    
                                    Text("\(turkishDateString) tarihi için muhtemeller henüz yayınlanmamıştir.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }

                            }
                        } else {
                    ForEach(tableRows) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<row.cells.count, id: \.self) { index in
                                let cell = row.cells[index]
                                HStack {
                                    Text(cell.label)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(row.isFavori && index == 0 ? .green : .primary)
                                    Spacer()
                                    Text(cell.odds)
                                        .font(.system(size: 13, design: .monospaced))
                                }
                                .padding(.horizontal, 8)
                                .frame(maxWidth: .infinity)
                                
                                if index < row.cells.count - 1 { Divider() }
                            }
                        }
                        .frame(height: 42)
                        .background(row.isKosmaz ? Color.gray.opacity(0.3) : Color.white)
                        Divider()
                    }
                    Color.clear.frame(height: 60)
                }
            }
        }
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
            
            for bahis in bahisler {
                let muhtemeller = bahis.muhtemeller ?? []
                if i < muhtemeller.count {
                    let m = muhtemeller[i]
                    if bahis.tur == "GANYAN" {
                        favoriMi = m.a ?? false
                        kosmazMi = m.k ?? false
                    }
                    let label = m.s2 != nil ? "\(m.s1 ?? "")-\(m.s2 ?? "")" : (m.s1 ?? "")
                    let odds = m.k == true ? "K" : (m.ganyan ?? "-")
                    rowCells.append(TableCell(label: label, odds: odds))
                } else {
                    rowCells.append(TableCell(label: "", odds: ""))
                }
            }
            newRows.append(DynamicTableRow(isFavori: favoriMi, isKosmaz: kosmazMi, cells: rowCells))
        }
        self.tableRows = newRows
    }
}

#Preview {
    // 1 gün öncesinin verilerini gösterir (genelde geçmiş veriler daha stabildir)
    OddsView(selectedDate: Date())
        .preferredColorScheme(.light)
}

// Preview için sahte veri üretici (Opsiyonel: Eğer verisiz ekranı görmek istersen)
struct OddsView_Previews: PreviewProvider {
    static var previews: some View {
        OddsView(selectedDate: Date())
            .previewDisplayName("Canlı Veri Denemesi")
    }
}
