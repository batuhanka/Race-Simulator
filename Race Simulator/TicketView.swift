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
            return "\(firstInitial).\(components.last!)"
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
                selectedBetType = nil
                selectedRace = nil
                resetSelections()
            }
        }
    }
    @State private var selectedBetType: BetType? {
        didSet {
            if selectedBetType?.id != oldValue?.id {
                selectedRace = nil
                if let newSelectedBetType = selectedBetType, let firstPlayable = filteredRaces(for: selectedRaceDay, betType: newSelectedBetType).first {
                    selectedRace = firstPlayable
                }
                resetSelections()
            }
        }
    }
    @State private var selectedRace: BetRace?
    @State private var errorMessage: String?
    
    @State private var selectedHorses: [String: Set<String>] = [:] // [BetRace.KOD: Set<BetHorse.KOD>]
    @State private var multiplier: Int = 1
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Kupon Oluştur")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(.ultraThinMaterial)

            if isLoading {
                ProgressView("Bahis bilgileri yükleniyor...")
            } else if let errorMessage = errorMessage {
                ContentUnavailableView("Hata", systemImage: "xmark.octagon", description: Text(errorMessage))
            } else if raceDays.isEmpty {
                ContentUnavailableView("Yarış Bulunamadı", systemImage: "calendar.badge.exclamationmark", description: Text("Bugün için yerli yarış programı bulunamadı."))
            } else {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        selectionControlsSection()
                        
                        if let raceDay = selectedRaceDay, let betType = selectedBetType {
                            horseListSection(for: raceDay, betType: betType)
                        }
                        
                        selectedHorsesSection()
                        
                        betCalculationSection()
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadBettingData()
        }
    }
    
    // MARK: - Section Views
    
    @ViewBuilder
    private func selectionControlsSection() -> some View {
        
            VStack {
                Picker("Şehir Seçin", selection: $selectedRaceDay) {
                    Text("Lütfen bir şehir seçin").tag(nil as BetRaceDay?)
                    ForEach(raceDays) { day in
                        Text("\(day.YER) - \(day.TARIH)").tag(day as BetRaceDay?)
                    }
                }
                .pickerStyle(.menu)
                
                if let selectedRaceDay = selectedRaceDay {
                    Picker("Bahis Türü Seçin", selection: $selectedBetType) {
                        Text("Lütfen bir bahis türü seçin").tag(nil as BetType?)
                        ForEach(selectedRaceDay.bahisler) { bahis in
                            Text(bahis.BAHIS).tag(bahis as BetType?)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        

        if let raceDay = selectedRaceDay, let betType = selectedBetType {
            raceSelectionBar(for: raceDay, betType: betType)
        }
    }
    
    @ViewBuilder
    private func horseListSection(for raceDay: BetRaceDay, betType: BetType) -> some View {
        
            let currentFilteredRaces = filteredRaces(for: raceDay, betType: betType)
            
            if let selectedRace = selectedRace, let horses = selectedRace.atlar {
                HorseTableView(race: selectedRace, horses: horses, selectedHorses: $selectedHorses, betType: betType)
            } else if !currentFilteredRaces.isEmpty && selectedRace == nil {
                ContentUnavailableView("Yarış Seçin", systemImage: "arrow.up.left.circle", description: Text("Lütfen yukarıdan bir yarış seçin."))
            } else {
                ContentUnavailableView("Yarış Yok", systemImage: "calendar.badge.exclamationmark", description: Text("Bu bahis türü için program bulunamadı."))
            }
        }
    
    @ViewBuilder
    private func selectedHorsesSection() -> some View {
        
            VStack(alignment: .leading, spacing: 15) {
                if let raceDay = selectedRaceDay, let betType = selectedBetType {
                    let racesWithSelections = filteredRaces(for: raceDay, betType: betType).filter {
                        !(selectedHorses[$0.KOD]?.isEmpty ?? true)
                    }

                    if racesWithSelections.isEmpty {
                        Text("Kuponunuza at eklemek için yukarıdaki listeden seçim yapın.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                    } else {
                        ForEach(racesWithSelections) { race in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(race.NO). Koşu:")
                                    .font(.headline.weight(.semibold))
                                
                                let columns = [GridItem(.adaptive(minimum: 150), spacing: 8)]
                                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                                    ForEach(Array(selectedHorses[race.KOD]!.sorted()), id: \.self) { horseKod in
                                        if let horse = race.atlar?.first(where: { $0.KOD == horseKod }) {
                                            HorseBettingChip(horse: horse) {
                                                toggleHorseSelection(raceId: race.KOD, horseKod: horse.KOD)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                } else {
                     Text("Kuponunuzu görmek için bir yarış ve bahis türü seçin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    

    @ViewBuilder
    private func betCalculationSection() -> some View {
        if let raceDay = selectedRaceDay, let betType = selectedBetType {
            
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Misli:")
                                .font(.headline)
                            Stepper(value: $multiplier, in: 1...999) {
                                Text("\(multiplier)")
                                    .font(.headline.bold())
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Toplam Seçim:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f", calculateTotalHorsesBet()))
                                .font(.title2.bold())
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Tutar:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f TL", calculateTotalBetAmount(for: raceDay, betType: betType)))
                            .font(.title.bold())
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 5)
            }
        }
    
    
    // MARK: - Helper Functions
    
    private func filteredRaces(for raceDay: BetRaceDay?, betType: BetType?) -> [BetRace] {
        guard let raceDay = raceDay, let betType = betType, let kosular = raceDay.kosular else {
            return []
        }
        
        let availableRaceNumbersForBetType = Set(betType.kosular.map { String($0) })
        
        let racesToDisplay = kosular.filter { race in
            availableRaceNumbersForBetType.contains(race.NO)
        }
        
        return racesToDisplay.sorted { (Int($0.NO) ?? 0) < (Int($1.NO) ?? 0) }
    }
    
    private func raceSelectionBar(for raceDay: BetRaceDay, betType: BetType) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filteredRaces(for: raceDay, betType: betType)) { race in
                    Button {
                        selectedRace = race
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(race.NO). Koşu")
                                .font(.headline.bold())
                            Text(race.SAAT)
                                .font(.caption2)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedRace?.id == race.id ? Color.cyan : Color.gray.opacity(0.2))
                        .foregroundColor(selectedRace?.id == race.id ? .black : .primary)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 50)
    }

    private func loadBettingData() async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        
        do {
            let checksumUrl = URL(string: "https://ebayi.tjk.org/s/d/bet/checksum.json")!
            let (checksumData, _) = try await URLSession.shared.data(from: checksumUrl)
            let checksumResponse = try JSONDecoder().decode(BetChecksumResponse.self, from: checksumData)
            let checksum = checksumResponse.checksum
            
            let betDataUrlString = "https://emedya-cdn.tjk.org/s/d/bet/bet-\(checksum).json"
            print("➡️ DEBUG: Veri çekiliyor: \(betDataUrlString)")
            let (betData, _) = try await URLSession.shared.data(from: URL(string: betDataUrlString)!)
            
            let decodedResponse = try JSONDecoder().decode(BetDataResponse.self, from: betData)

            let filteredByKOD = decodedResponse.data.yarislar
                .filter { (Int($0.KOD) ?? 99) < 11 }
            print("➡️ DEBUG: KOD filtresi sonrası yarış günü sayısı: \(filteredByKOD.count)")
            if let firstRace = filteredByKOD.first {
                print("➡️ DEBUG: JSON'dan gelen ilk yarış tarihi: \(firstRace.TARIH)")
            }
            
            // Tarih filtresi kaldırıldı, artık tüm tarihlerdeki yarışlar listelenecek.
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            let sortedFiltered = filteredByKOD.sorted { raceDay1, raceDay2 in
                let date1 = dateFormatter.date(from: raceDay1.TARIH) ?? .distantPast
                let date2 = dateFormatter.date(from: raceDay2.TARIH) ?? .distantPast
                
                if date1 != date2 {
                    return date1 < date2
                } else {
                    return raceDay1.YER < raceDay2.YER
                }
            }

            await MainActor.run {
                self.raceDays = sortedFiltered
                self.isLoading = false
                
                if let firstRaceDay = sortedFiltered.first {
                    self.selectedRaceDay = firstRaceDay
                    if let firstBetType = firstRaceDay.bahisler.first {
                        self.selectedBetType = firstBetType
                        if let firstPlayableRace = filteredRaces(for: firstRaceDay, betType: firstBetType).first {
                            self.selectedRace = firstPlayableRace
                        }
                    }
                }
                print("➡️ DEBUG: Ekrana yüklenecek son yarış günü sayısı: \(self.raceDays.count)")
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
        if selectedBetType?.BAHIS.lowercased().contains("ganyan") == true {
            if var selections = selectedHorses[raceId] {
                if selections.contains(horseKod) {
                    selections.remove(horseKod)
                } else {
                    selections.removeAll()
                    selections.insert(horseKod)
                }
                selectedHorses[raceId] = selections
            } else {
                selectedHorses[raceId] = [horseKod]
            }
        } else {
            if var selections = selectedHorses[raceId] {
                if selections.contains(horseKod) {
                    selections.remove(horseKod)
                } else {
                    selections.insert(horseKod)
                }
                selectedHorses[raceId] = selections
            } else {
                selectedHorses[raceId] = [horseKod]
            }
        }
    }
    
    private func calculateTotalHorsesBet() -> Double {
        var totalSelections = 0
        if let currentRaceDay = selectedRaceDay, let currentBetType = selectedBetType {
            for race in filteredRaces(for: currentRaceDay, betType: currentBetType) {
                totalSelections += selectedHorses[race.KOD]?.count ?? 0
            }
        }
        return Double(totalSelections)
    }
    
    private func calculateTotalBetAmount(for raceDay: BetRaceDay, betType: BetType) -> Double {
        var productOfSelections = 1
        let filtered = filteredRaces(for: raceDay, betType: betType)
        
        if betType.BAHIS.lowercased().contains("ganyan") || betType.BAHIS.lowercased().contains("sıralı") || betType.BAHIS.lowercased().contains("plase") {
            productOfSelections = filtered.reduce(0) { sum, race in
                sum + (selectedHorses[race.KOD]?.count ?? 0)
            }
        } else {
             productOfSelections = filtered.reduce(1) { product, race in
                let count = selectedHorses[race.KOD]?.count ?? 0
                return product * (count > 0 ? count : 1)
            }
        }

        let poolUnit = Double(betType.POOLUNIT) / 100.0
        return Double(productOfSelections) * Double(multiplier) * poolUnit
    }
    
    private func resetSelections() {
        selectedHorses = [:]
        multiplier = 1
    }
}

// MARK: - Reusable Components
struct HorseTableView: View {
    let race: BetRace
    let horses: [BetHorse]
    @Binding var selectedHorses: [String: Set<String>]
    let betType: BetType
    
    let headers: [String] = ["No", "Forma", "At İsmi", "Jokey", "AGF"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                ForEach(headers.indices, id: \.self) { index in
                    headerCell(text: headers[index])
                }
            }
            .frame(height: 40)
            .background(Color(UIColor.secondarySystemBackground))
            .padding(.horizontal, 8)
            
            // Rows
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(horses) { horse in
                        HorseTableRow(horse: horse, isSelected: isHorseSelected(raceId: race.KOD, horseKod: horse.KOD), betType: betType) {
                            toggleHorseSelection(raceId: race.KOD, horseKod: horse.KOD)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
            }
            .frame(maxHeight: 500) // Avoid taking up too much space
        }
    }
    
    private func headerCell(text: String) -> some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
    }
    
    private func isHorseSelected(raceId: String, horseKod: String) -> Bool {
        selectedHorses[raceId]?.contains(horseKod) ?? false
    }
    
    private func toggleHorseSelection(raceId: String, horseKod: String) {
        if betType.BAHIS.lowercased().contains("ganyan") {
            if var selections = selectedHorses[raceId] {
                if selections.contains(horseKod) {
                    selections.remove(horseKod)
                } else {
                    selections.removeAll()
                    selections.insert(horseKod)
                }
                selectedHorses[raceId] = selections
            } else {
                selectedHorses[raceId] = [horseKod]
            }
        } else {
            if var selections = selectedHorses[raceId] {
                if selections.contains(horseKod) {
                    selections.remove(horseKod)
                } else {
                    selections.insert(horseKod)
                }
                selectedHorses[raceId] = selections
            } else {
                selectedHorses[raceId] = [horseKod]
            }
        }
    }
}

struct HorseTableRow: View {
    let horse: BetHorse
    let isSelected: Bool
    let betType: BetType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // No
                Text(horse.NO)
                    .font(.system(size: 11, weight: .bold))
                    .frame(width: 30, alignment: .leading)

                // Forma
                AsyncImage(url: URL(string: horse.FORMA ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        Image(systemName: "tshirt.fill").resizable().scaledToFit().padding(8)
                    }
                }
                .frame(width: 30, height: 30)
                .padding(.horizontal, 5)
                
                // At Ismi
                textCell(horse.AD, alignment: .leading)
                
                // Jokey
                textCell(horse.shortJockeyName, alignment: .leading)
                
                // AGF
                VStack(alignment: .leading, spacing: 2) {
                    Text(horse.AGF1.map { String(format: "%%%.1f", $0) } ?? "-")
                    + Text(horse.AGFSIRA1.map { "(\($0))" } ?? "")
                }
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(horse.AGFSIRA1 == 1 ? .red : .primary)
                .frame(width: 60, alignment: .leading)
            }
            .padding(.vertical, 8)
            .background(horse.KOSMAZ == true ? Color.red.opacity(0.2) : (isSelected ? Color.cyan.opacity(0.3) : Color.clear))
            .cornerRadius(5)
        }
        .buttonStyle(.plain)
        .disabled(horse.KOSMAZ == true)
    }
    
    @ViewBuilder
    private func textCell(_ text: String?, alignment: HorizontalAlignment = .center) -> some View {
        Text(text ?? "N/A")
            .font(.system(size: 11))
            .foregroundColor(horse.KOSMAZ == true ? .red : .primary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

fileprivate struct HorseBettingChip: View {
    let horse: BetHorse
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(horse.NO)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                Text(horse.AD)
                    .font(.caption)
                    .lineLimit(1)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TicketView()
    }
}

