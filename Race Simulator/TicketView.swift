import SwiftUI

// MARK: - Veri Modelleri
// Models are renamed to avoid conflicts with other parts of the app (e.g., BetHorse, BetRace).
struct BetChecksumResponse: Codable {
    let checksum: String
}

// 1. En dış katman
struct BetDataResponse: Codable {
    let success: Bool
    let data: BetInnerData
    let checksum: String
    let updatetime: Int?
}

// 2. "data" objesinin içi
struct BetInnerData: Codable {
    let yarislar: [BetRaceDay]
}

// This was the missing type. Defined based on the JSON structure.
struct BetType: Codable, Identifiable, Hashable {
    var id: String { TYPE }
    let TYPE: String
    let BAHIS: String
    let POOLUNIT: Int
    let kosular: [Int]
}

struct BetRaceDay: Codable, Identifiable, Hashable {
    var id: String { KOD }
    let CARDID: String?
    let KOD: String
    let KEY: String
    let HIPODROM: String
    let YER: String
    let TARIH: String
    let GUN: String?
    let SIRA: String?
    let ACILIS: String?
    let KAPANIS: String?
    let GECE: Bool?
    let YABANCI: Bool?
    let hava: BetHavaData?
    let pist: BetPistData?
    let kosular: [BetRace]?
    let bahisler: [BetType]
}

struct BetHavaData: Codable, Hashable {
    let KOD: String?
    let DURUM: String?
    let DURUM_EN: String?
    let SICAKLIK: Int?
    let NEM: Int?

    var sicaklikString: String { SICAKLIK.map { "\($0)" } ?? "N/A" }
    var nemString: String { NEM.map { "\($0)%" } ?? "N/A" }
    var havaTr: String { DURUM ?? "N/A" }
}

struct BetPistData: Codable, Hashable {
    let cim: BetPistDetail?
    let kum: BetPistDetail?
    let tapeta: BetPistDetail?
}

struct BetPistDetail: Codable, Hashable {
    let DURUM: String?
    let DURUM_EN: String?
    let AGIRLIK: Int?
}

struct BetRace: Codable, Identifiable, Hashable {
    var id: String { KOD }
    let KOD: String
    let NO: String
    let SAAT: String
    let MESAFE: String
    let PISTKODU: String?
    let PIST: String?
    let PIST_EN: String?
    let KISALTMA: String?
    let GRUP: String?
    let GRUP_EN: String?
    let GRUPKISA: String?
    let CINSDETAY: String?
    let CINSDETAY_EN: String?
    let CINSIYET: String?
    let ONEMLIADI: String?
    let ikramiyeler: [String]?
    let primler: [String]?
    let DOVIZ: String?
    let BILGI: String?
    let BILGI_EN: String?
    let atlar: [BetHorse]?

    var raceDescription: String {
        // Example: "SATIŞ 2, 3 Yaşlı İngilizler, 58 Kg"
        return [CINSDETAY, GRUP, KISALTMA].compactMap { $0 }.joined(separator: ", ")
    }
    
    enum CodingKeys: String, CodingKey {
        case KOD, NO, SAAT, MESAFE, PISTKODU, PIST, PIST_EN, KISALTMA, GRUP, GRUP_EN, GRUPKISA, CINSDETAY, CINSDETAY_EN, CINSIYET, ONEMLIADI, ikramiyeler, primler, DOVIZ, BILGI, BILGI_EN, atlar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let kodString = try? container.decode(String.self, forKey: .KOD) {
            KOD = kodString
        } else if let kodInt = try? container.decode(Int.self, forKey: .KOD) {
            KOD = String(kodInt)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .KOD, in: container, debugDescription: "KOD is not a String or Int")
        }

        if let noString = try? container.decode(String.self, forKey: .NO) {
            NO = noString
        } else if let noInt = try? container.decode(Int.self, forKey: .NO) {
            NO = String(noInt)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .NO, in: container, debugDescription: "NO is not a String or Int")
        }

        SAAT = try container.decode(String.self, forKey: .SAAT)
        MESAFE = try container.decode(String.self, forKey: .MESAFE)
        PISTKODU = try container.decodeIfPresent(String.self, forKey: .PISTKODU)
        PIST = try container.decodeIfPresent(String.self, forKey: .PIST)
        PIST_EN = try container.decodeIfPresent(String.self, forKey: .PIST_EN)
        KISALTMA = try container.decodeIfPresent(String.self, forKey: .KISALTMA)
        GRUP = try container.decodeIfPresent(String.self, forKey: .GRUP)
        GRUP_EN = try container.decodeIfPresent(String.self, forKey: .GRUP_EN)
        GRUPKISA = try container.decodeIfPresent(String.self, forKey: .GRUPKISA)
        CINSDETAY = try container.decodeIfPresent(String.self, forKey: .CINSDETAY)
        CINSDETAY_EN = try container.decodeIfPresent(String.self, forKey: .CINSDETAY_EN)
        CINSIYET = try container.decodeIfPresent(String.self, forKey: .CINSIYET)
        ONEMLIADI = try container.decodeIfPresent(String.self, forKey: .ONEMLIADI)
        ikramiyeler = try container.decodeIfPresent([String].self, forKey: .ikramiyeler)
        primler = try container.decodeIfPresent([String].self, forKey: .primler)
        DOVIZ = try container.decodeIfPresent(String.self, forKey: .DOVIZ)
        BILGI = try container.decodeIfPresent(String.self, forKey: .BILGI)
        BILGI_EN = try container.decodeIfPresent(String.self, forKey: .BILGI_EN)
        atlar = try container.decodeIfPresent([BetHorse].self, forKey: .atlar)
    }
}

struct BetHorse: Codable, Identifiable, Hashable {
    var id: String { KOD }
    let KEY: String?
    let KOD: String
    let NO: String
    let START: String?
    let AD: String
    let ADKUCUK: String?
    let BABA: String?
    let ANNE: String?
    let ANNEBABA: String?
    let YAS: String?
    let YAS_EN: String?
    let FOAL: String?
    let DOGUMTARIHI: String?
    let KILO: Double?
    let KILOINDIRIM: Double?
    let FAZLAKILO: String?
    let AGFSIRA1: Int?
    let AGF1: Double?
    let GANYAN: Double?
    let SON6: String?
    let SON20: String?
    let PUANCIM: String?
    let PUANKUM: String?
    let HANDIKAP: String?
    let KGS: String?
    let ANTRENOR: String?
    let ANTRENORADI: String?
    let JOKEY: String?
    let JOKEYADI: String?
    let SAHIP: String?
    let SAHIPADI: String?
    let YETISTIRICI: String?
    let YETISTIRICIADI: String?
    let BABAKODU: String?
    let ANNEKODU: String?
    let ANTRENORKODU: String?
    let JOKEYKODU: String?
    let SAHIPKODU: String?
    let ENIYIDERECE: String?
    let ENIYIDERECEACIKLAMA: String?
    let ENIYIDERECEFARKLIHIPODROM: Bool?
    let APRANTI: Bool?
    let FORMA: String?
    let TAKI: String?
    let IDMANVIDEO: String?
    let KOSMAZ: Bool?

    enum CodingKeys: String, CodingKey {
        case KEY, KOD, NO, START, AD, ADKUCUK, BABA, ANNE, ANNEBABA, YAS, YAS_EN, FOAL, DOGUMTARIHI, KILO, KILOINDIRIM, FAZLAKILO, AGFSIRA1, AGF1, GANYAN, SON6, SON20, PUANCIM, PUANKUM, HANDIKAP, KGS, ANTRENOR, ANTRENORADI, JOKEY, JOKEYADI, SAHIP, SAHIPADI, YETISTIRICI, YETISTIRICIADI, BABAKODU, ANNEKODU, ANTRENORKODU, JOKEYKODU, SAHIPKODU, ENIYIDERECE, ENIYIDERECEACIKLAMA, ENIYIDERECEFARKLIHIPODROM, APRANTI, FORMA, TAKI, IDMANVIDEO, KOSMAZ
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let kodString = try? container.decode(String.self, forKey: .KOD) {
            KOD = kodString
        } else if let kodInt = try? container.decode(Int.self, forKey: .KOD) {
            KOD = String(kodInt)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .KOD, in: container, debugDescription: "KOD is not a String or Int")
        }

        if let noString = try? container.decode(String.self, forKey: .NO) {
            NO = noString
        } else if let noInt = try? container.decode(Int.self, forKey: .NO) {
            NO = String(noInt)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .NO, in: container, debugDescription: "NO is not a String or Int")
        }
        
        KEY = try container.decodeIfPresent(String.self, forKey: .KEY)
        START = try container.decodeIfPresent(String.self, forKey: .START)
        AD = try container.decode(String.self, forKey: .AD)
        ADKUCUK = try container.decodeIfPresent(String.self, forKey: .ADKUCUK)
        BABA = try container.decodeIfPresent(String.self, forKey: .BABA)
        ANNE = try container.decodeIfPresent(String.self, forKey: .ANNE)
        ANNEBABA = try container.decodeIfPresent(String.self, forKey: .ANNEBABA)
        YAS = try container.decodeIfPresent(String.self, forKey: .YAS)
        YAS_EN = try container.decodeIfPresent(String.self, forKey: .YAS_EN)
        FOAL = try container.decodeIfPresent(String.self, forKey: .FOAL)
        DOGUMTARIHI = try container.decodeIfPresent(String.self, forKey: .DOGUMTARIHI)
        KILO = try container.decodeIfPresent(Double.self, forKey: .KILO)
        KILOINDIRIM = try container.decodeIfPresent(Double.self, forKey: .KILOINDIRIM)
        
        if let stringValue = try? container.decode(String.self, forKey: .FAZLAKILO) {
            FAZLAKILO = stringValue
        } else if let doubleValue = try? container.decode(Double.self, forKey: .FAZLAKILO) {
            FAZLAKILO = String(doubleValue)
        } else if let intValue = try? container.decode(Int.self, forKey: .FAZLAKILO) {
            FAZLAKILO = String(intValue)
        } else {
            FAZLAKILO = nil
        }

        AGFSIRA1 = try container.decodeIfPresent(Int.self, forKey: .AGFSIRA1)
        AGF1 = try container.decodeIfPresent(Double.self, forKey: .AGF1)
        GANYAN = try container.decodeIfPresent(Double.self, forKey: .GANYAN)
        SON6 = try container.decodeIfPresent(String.self, forKey: .SON6)
        SON20 = try container.decodeIfPresent(String.self, forKey: .SON20)
        PUANCIM = try container.decodeIfPresent(String.self, forKey: .PUANCIM)
        PUANKUM = try container.decodeIfPresent(String.self, forKey: .PUANKUM)
        HANDIKAP = try container.decodeIfPresent(String.self, forKey: .HANDIKAP)
        KGS = try container.decodeIfPresent(String.self, forKey: .KGS)
        ANTRENOR = try container.decodeIfPresent(String.self, forKey: .ANTRENOR)
        ANTRENORADI = try container.decodeIfPresent(String.self, forKey: .ANTRENORADI)
        JOKEY = try container.decodeIfPresent(String.self, forKey: .JOKEY)
        JOKEYADI = try container.decodeIfPresent(String.self, forKey: .JOKEYADI)
        SAHIP = try container.decodeIfPresent(String.self, forKey: .SAHIP)
        SAHIPADI = try container.decodeIfPresent(String.self, forKey: .SAHIPADI)
        YETISTIRICI = try container.decodeIfPresent(String.self, forKey: .YETISTIRICI)
        YETISTIRICIADI = try container.decodeIfPresent(String.self, forKey: .YETISTIRICIADI)
        BABAKODU = try container.decodeIfPresent(String.self, forKey: .BABAKODU)
        ANNEKODU = try container.decodeIfPresent(String.self, forKey: .ANNEKODU)
        ANTRENORKODU = try container.decodeIfPresent(String.self, forKey: .ANTRENORKODU)
        JOKEYKODU = try container.decodeIfPresent(String.self, forKey: .JOKEYKODU)
        SAHIPKODU = try container.decodeIfPresent(String.self, forKey: .SAHIPKODU)
        ENIYIDERECE = try container.decodeIfPresent(String.self, forKey: .ENIYIDERECE)
        ENIYIDERECEACIKLAMA = try container.decodeIfPresent(String.self, forKey: .ENIYIDERECEACIKLAMA)
        ENIYIDERECEFARKLIHIPODROM = try container.decodeIfPresent(Bool.self, forKey: .ENIYIDERECEFARKLIHIPODROM)
        APRANTI = try container.decodeIfPresent(Bool.self, forKey: .APRANTI)
        FORMA = try container.decodeIfPresent(String.self, forKey: .FORMA)
        TAKI = try container.decodeIfPresent(String.self, forKey: .TAKI)
        IDMANVIDEO = try container.decodeIfPresent(String.self, forKey: .IDMANVIDEO)
        KOSMAZ = try container.decodeIfPresent(Bool.self, forKey: .KOSMAZ)
    }

    var shortJockeyName: String {
        guard let jockey = JOKEYADI else { return "N/A" }
        let components = jockey.split(separator: " ")
        if components.count > 1, let firstInitial = components.first?.first {
            return "\(firstInitial). \(components.last!)"
        }
        return jockey
    }
}


// MARK: - Ana View
struct TicketView: View {
    @State private var isLoading = true
    @State private var raceDays: [BetRaceDay] = []
    @State private var selectedRaceDay: BetRaceDay? {
        didSet {
            if selectedRaceDay?.id != oldValue?.id {
                selectedBetType = ganyanBetTypes.first
            }
        }
    }
    @State private var selectedBetType: BetType? {
        didSet {
            if selectedBetType?.id != oldValue?.id {
                selectedRace = filteredRaces(for: selectedRaceDay, betType: selectedBetType).first
                resetSelections()
            }
        }
    }
    @State private var selectedRace: BetRace?
    @State private var errorMessage: String?
    
    @State private var selectedHorses: [String: Set<String>] = [:]
    @State private var multiplier: Int = 1
    
    // Theme Colors
    let themePrimary = Color.cyan
    let themeAccent = Color.orange
    let themeBackground = Color.black
    
    // Computed property for filtered bet types
    private var ganyanBetTypes: [BetType] {
        guard let raceDay = selectedRaceDay else { return [] }
        return raceDay.bahisler.filter { $0.BAHIS.localizedCaseInsensitiveContains("Ganyan") }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Bahis bilgileri yükleniyor...").padding()
                Spacer()
            } else if let errorMessage = errorMessage {
                ContentUnavailableView("Hata", systemImage: "xmark.octagon", description: Text(errorMessage))
            } else if raceDays.isEmpty {
                ContentUnavailableView("Yarış Bulunamadı", systemImage: "calendar.badge.exclamationmark")
            } else {
                mainContent()
            }
        }
        .preferredColorScheme(.dark)
        .background(themeBackground)
        .ignoresSafeArea(edges: .bottom)
        .task {
            await loadBettingData()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Hipodrom", selection: $selectedRaceDay) {
                    ForEach(raceDays) { day in
                        Text("\(day.YER.uppercased()) (\(day.TARIH))")
                            .tag(day as BetRaceDay?)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    // MARK: - UI Components
    @ViewBuilder
    private func mainContent() -> some View {
        VStack(spacing: 0) {
            selectionView()
            raceLegsView()
            
            if selectedRace != nil {
                raceInfoHeader()
                ScrollView {
                    horseListView()
                }
            } else {
                Spacer()
                ContentUnavailableView("Koşu Seçin", systemImage: "arrow.up", description: Text("Lütfen yukarıdan bir koşu seçin."))
                
                Spacer()
            }
            
            bettingFooter()
        }
    }

    @ViewBuilder
    private func selectionView() -> some View {
        Menu {
            Picker("Bahis Türü", selection: $selectedBetType) {
                Text("Lütfen Bahis Türü Seçin").tag(nil as BetType?)
                ForEach(ganyanBetTypes) { type in
                    Text(type.BAHIS).tag(type as BetType?)
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedBetType?.BAHIS ?? "Ganyan Türü Seçin")
                        .font(.headline)
                    Text("Ayaklar: \(selectedBetType?.kosular.map(String.init).joined(separator: "-") ?? "...")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
    }

    @ViewBuilder
    private func raceLegsView() -> some View {
        if let raceDay = selectedRaceDay, let betType = selectedBetType {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(filteredRaces(for: raceDay, betType: betType)) { race in
                        Button {
                            selectedRace = race
                        } label: {
                            VStack {
                                Text("\(race.NO). Ayak")
                                Text("\(selectedHorses[race.KOD]?.count ?? 0)")
                                    .font(.caption.bold())
                                    .foregroundColor(.black)
                                    .frame(width: 18, height: 18)
                                    .background(themeAccent)
                                    .clipShape(Circle())
                            }
                            .padding(8)
                            .frame(minWidth: 40)
                            .background(selectedRace?.id == race.id ? themePrimary : Color.gray.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color.gray.opacity(0.2))
        }
    }

    @ViewBuilder
    private func raceInfoHeader() -> some View {
        if let race = selectedRace {
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(race.NO). Koşu")
                        .font(.subheadline.bold())
                    
                    Spacer()
                    
                    Label(race.SAAT, systemImage: "clock.fill")
                        .font(.subheadline.bold())
                }
                
                Text(race.BILGI ?? "")
                    .font(.subheadline)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .frame(height: 80, alignment: .top)
            
        }
    }
    
    @ViewBuilder
    private func horseListView() -> some View {
        if let race = selectedRace, let horses = race.atlar {
            LazyVStack(spacing: 0) {
                ForEach(horses) { horse in
                    HorseRow(
                        horse: horse,
                        isSelected: selectedHorses[race.KOD]?.contains(horse.KOD) ?? false
                    ) {
                        toggleHorseSelection(raceId: race.KOD, horseKod: horse.KOD)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func bettingFooter() -> some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 2) {
                Text("B: \(calculateBetCombinations())")
                    .font(.subheadline.bold())
                Text("T: \(String(format: "%.2f", calculateTotalBetAmount())) ₺")
                    .font(.subheadline.bold())
                    .foregroundColor(themeAccent)
            }
            
            Spacer()
            
            Text("M:")
                .font(.subheadline.bold())

            Stepper(value: $multiplier, in: 1...99) {
                Text("\(multiplier)")
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(4)
            }
            .labelsHidden()
            
            Button {
                // Kuponu onayla eylemi
            } label: {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .padding(10)
                    .background(themePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .foregroundColor(.primary)
    }

    // MARK: - Helper Functions
    private func filteredRaces(for raceDay: BetRaceDay?, betType: BetType?) -> [BetRace] {
        guard let raceDay, let betType, let kosular = raceDay.kosular else { return [] }
        let availableRaceNumbers = Set(betType.kosular.map { String($0) })
        let racesToDisplay = kosular.filter { availableRaceNumbers.contains($0.NO) }
        return racesToDisplay.sorted { (Int($0.NO) ?? 0) < (Int($1.NO) ?? 0) }
    }

    private func loadBettingData() async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        
        do {
            let checksumUrl = URL(string: "https://ebayi.tjk.org/s/d/bet/checksum.json")!
            let (checksumData, _) = try await URLSession.shared.data(from: checksumUrl)
            let checksumResponse = try JSONDecoder().decode(BetChecksumResponse.self, from: checksumData)
            let checksum = checksumResponse.checksum
            
            let betDataUrlString = "https://emedya-cdn.tjk.org/s/d/bet/bet-\(checksum).json"
            let (betData, _) = try await URLSession.shared.data(from: URL(string: betDataUrlString)!)
            
            let decodedResponse = try JSONDecoder().decode(BetDataResponse.self, from: betData)
            let filteredByKOD = decodedResponse.data.yarislar.filter { (Int($0.KOD) ?? 99) < 11 }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            let sortedFiltered = filteredByKOD.sorted { raceDay1, raceDay2 in
                let date1 = dateFormatter.date(from: raceDay1.TARIH) ?? .distantPast
                let date2 = dateFormatter.date(from: raceDay2.TARIH) ?? .distantPast
                return date1 != date2 ? date1 < date2 : raceDay1.YER < raceDay2.YER
            }

            await MainActor.run {
                self.raceDays = sortedFiltered
                self.isLoading = false
                
                if let firstRaceDay = sortedFiltered.first {
                    self.selectedRaceDay = firstRaceDay
                    self.selectedBetType = ganyanBetTypes.first
                    if let betType = self.selectedBetType {
                        self.selectedRace = self.filteredRaces(for: firstRaceDay, betType: betType).first
                    }
                }
            }
        } catch {
            print("🔴 DECODE VEYA NETWORK HATASI: \(error)")
            await MainActor.run {
                self.errorMessage = "Veri yapısı değişmiş veya çekilemedi."
                self.isLoading = false
            }
        }
    }
    
    private func toggleHorseSelection(raceId: String, horseKod: String) {
        // Single horse selection for the exact "Ganyan" bet type.
        if selectedBetType?.BAHIS == "Ganyan" {
            var selections = selectedHorses[raceId] ?? []
            // If the same horse is tapped again, deselect it.
            if selections.contains(horseKod) {
                selections.remove(horseKod)
            } else {
                // For a new selection, clear previous and add the new one.
                selections.removeAll()
                selections.insert(horseKod)
            }
            selectedHorses[raceId] = selections
        } else {
            // Multiple horse selection for all other bet types (e.g., 6'lı Ganyan).
            var selections = selectedHorses[raceId] ?? []
            if selections.contains(horseKod) {
                selections.remove(horseKod)
            } else {
                selections.insert(horseKod)
            }
            selectedHorses[raceId] = selections
        }
    }
    
    private func calculateBetCombinations() -> Int {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType else { return 0 }
        
        let filtered = filteredRaces(for: raceDay, betType: betType)
        
        // Multi-leg bets are multiplicative, single-leg bets are additive.
        if betType.kosular.count > 1 {
            // Multiplicative logic for bets like 6'lı Ganyan
            let product = filtered.reduce(1) { result, race in
                let count = selectedHorses[race.KOD]?.count ?? 0
                return result * (count > 0 ? count : 1)
            }
            
            // If no horses are selected at all, combinations should be 0.
            let totalSelections = selectedHorses.values.flatMap { $0 }.count
            return totalSelections == 0 ? 0 : product
        } else {
            // Additive logic for single-leg bets like Ganyan, Plase.
            return filtered.reduce(0) { $0 + (selectedHorses[$1.KOD]?.count ?? 0) }
        }
    }
    
    private func calculateTotalBetAmount() -> Double {
        guard let betType = selectedBetType else { return 0.0 }
        let combinations = calculateBetCombinations()
        let poolUnit = Double(betType.POOLUNIT) / 100.0
        return Double(combinations) * Double(multiplier) * poolUnit
    }
    
    private func resetSelections() {
        selectedHorses = [:]
        multiplier = 1
    }
}

// MARK: - HorseRow Component
struct HorseRow: View {
    let horse: BetHorse
    let isSelected: Bool
    let action: () -> Void
    
    let themePrimary = Color.cyan

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                
                topSection
                
                
            }
            .padding(12)
            .background(horse.KOSMAZ == true ? Color.red.opacity(0.3) : Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themePrimary : Color.clear, lineWidth: 2)
            )
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .disabled(horse.KOSMAZ == true)
        .opacity(horse.KOSMAZ == true ? 0.6 : 1.0)
    }

    private var topSection: some View{
        ZStack(alignment: .leading) {
            
            GeometryReader { geo in
                
                if let formaLink = horse.FORMA, let url = URL(string: formaLink) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(width: geo.size.width * 0.38, height: 38)
                    .mask(
                        LinearGradient(gradient: Gradient(stops: [
                            .init(color: .black, location: 0.5),
                            .init(color: .clear, location: 1.0)
                        ]), startPoint: .leading, endPoint: .trailing)
                    )
                    .clipped()
                }
            }
            
            GeometryReader { geo in
                LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: geo.size.width * 0.30)
            }
            // İÇERİK
            HStack(alignment: .center, spacing: 0) {
                
                // --- SOL TARAF ---
                Text(horse.NO)
                    .font(.system(size: 20, weight: .heavy))
                    .italic()
                    .foregroundColor(.white)
                    .frame(width: 32, alignment: .center)
                    .minimumScaleFactor(0.6)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                    .padding(.leading, 6)
                
                HStack(spacing: 4) {
                    Text(horse.AD)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(horse.KOSMAZ == true ? .red : .white)
                        .strikethrough(horse.KOSMAZ == true, color: .red)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(horse.JOKEYADI ?? "")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    /*
                    let cleanEkuri = horse.EKURI?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if !cleanEkuri.isEmpty && cleanEkuri != "false" && cleanEkuri != "0" {
                        AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/e\(cleanEkuri).gif")) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFit()
                            } else {
                                Color.clear
                            }
                        }
                        .frame(width: 16, height: 16)
                     */
                    }
                }
                .padding(.leading, 4)
                
                Spacer(minLength: 10)
                
        }
        .frame(height: 38)
        .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 8))
    }
}


#Preview {
    NavigationStack {
        TicketView()
    }
}

