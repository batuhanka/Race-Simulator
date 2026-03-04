import SwiftUI

// MARK: - Veri Modelleri (Shared)

struct BetChecksumResponse: Codable {
    let checksum: String
}

struct BetDataResponse: Codable {
    let success: Bool
    let data: BetInnerData
    let checksum: String
    let updatetime: Int?
}

struct BetInnerData: Codable {
    let yarislar: [BetRaceDay]
}

struct BetType: Codable, Identifiable, Hashable {
    var id: String { "\(TYPE)_\(kosular.first ?? 0)_\(kosular.count)" } // ID daha benzersiz hale getirildi
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
        case KOD, NO, SAAT, MESAFE, PISTKODU, PIST, PIST_EN, KISALTMA, GRUP,
            GRUP_EN, GRUPKISA, CINSDETAY, CINSDETAY_EN, CINSIYET, ONEMLIADI,
            ikramiyeler, primler, DOVIZ, BILGI, BILGI_EN, atlar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let kodString = try? container.decode(String.self, forKey: .KOD) {
            KOD = kodString
        } else {
            KOD = String(try container.decode(Int.self, forKey: .KOD))
        }

        if let noString = try? container.decode(String.self, forKey: .NO) {
            NO = noString
        } else {
            NO = String(try container.decode(Int.self, forKey: .NO))
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
    
    init(KOD: String, NO: String, SAAT: String, MESAFE: String, PISTKODU: String? = nil, PIST: String? = nil, PIST_EN: String? = nil, KISALTMA: String? = nil, GRUP: String? = nil, GRUP_EN: String? = nil, GRUPKISA: String? = nil, CINSDETAY: String? = nil, CINSDETAY_EN: String? = nil, CINSIYET: String? = nil, ONEMLIADI: String? = nil, ikramiyeler: [String]? = nil, primler: [String]? = nil, DOVIZ: String? = nil, BILGI: String? = nil, BILGI_EN: String? = nil, atlar: [BetHorse]? = nil) {
        self.KOD = KOD
        self.NO = NO
        self.SAAT = SAAT
        self.MESAFE = MESAFE
        self.PISTKODU = PISTKODU
        self.PIST = PIST
        self.PIST_EN = PIST_EN
        self.KISALTMA = KISALTMA
        self.GRUP = GRUP
        self.GRUP_EN = GRUP_EN
        self.GRUPKISA = GRUPKISA
        self.CINSDETAY = CINSDETAY
        self.CINSDETAY_EN = CINSDETAY_EN
        self.CINSIYET = CINSIYET
        self.ONEMLIADI = ONEMLIADI
        self.ikramiyeler = ikramiyeler
        self.primler = primler
        self.DOVIZ = DOVIZ
        self.BILGI = BILGI
        self.BILGI_EN = BILGI_EN
        self.atlar = atlar
    }
}

struct BetHorse: Codable, Identifiable, Hashable {
    var id: String { KOD }
    let KOD: String
    let NO: String
    let AD: String
    let JOKEYADI: String?
    let FORMA: String?
    let KOSMAZ: Bool?
    let AGF1: Double?
    let AGF2: Double?
    let EKURI: String?

    enum CodingKeys: String, CodingKey {
        case KOD, NO, AD, JOKEYADI, FORMA, KOSMAZ, AGF1, AGF2, EKURI
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let kodString = try? container.decode(String.self, forKey: .KOD) {
            KOD = kodString
        } else {
            KOD = String(try container.decode(Int.self, forKey: .KOD))
        }

        if let noString = try? container.decode(String.self, forKey: .NO) {
            NO = noString
        } else {
            NO = String(try container.decode(Int.self, forKey: .NO))
        }

        AD = try container.decode(String.self, forKey: .AD)
        JOKEYADI = try container.decodeIfPresent(String.self, forKey: .JOKEYADI)
        FORMA = try container.decodeIfPresent(String.self, forKey: .FORMA)
        KOSMAZ = try container.decodeIfPresent(Bool.self, forKey: .KOSMAZ)
        AGF1 = try container.decodeIfPresent(Double.self, forKey: .AGF1)
        AGF2 = try container.decodeIfPresent(Double.self, forKey: .AGF2)
        
        if let stringValue = try? container.decode(String.self, forKey: .EKURI) {
            EKURI = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .EKURI) {
            EKURI = String(intValue)
        } else {
            EKURI = nil
        }
    }
    
    init(KOD: String, NO: String, AD: String, JOKEYADI: String?, FORMA: String?, KOSMAZ: Bool?, AGF1: Double?, AGF2: Double?, EKURI: String?) {
        self.KOD = KOD
        self.NO = NO
        self.AD = AD
        self.JOKEYADI = JOKEYADI
        self.FORMA = FORMA
        self.KOSMAZ = KOSMAZ
        self.AGF1 = AGF1
        self.AGF2 = AGF2
        self.EKURI = EKURI
    }
}

// MARK: - ANA KUPON SAYFASI (TicketView)

struct TicketView: View {
    var initialSelections: [String: Set<String>]? = nil
    var initialDay: BetRaceDay? = nil
    var initialBet: BetType? = nil
    
    @State private var isLoading = true
    @State private var raceDays: [BetRaceDay] = []
    @State private var selectedRaceDay: BetRaceDay?
    @State private var selectedBetType: BetType?
    @State private var selectedRace: BetRace?
    @State private var errorMessage: String?
    @State private var selectedHorses: [String: Set<String>] = [:]
    @State private var multiplier: Int = 1

    let themePrimary = Color.cyan
    let themeAccent = Color.orange
    let themeBackground = Color.black

    private var ganyanBetTypes: [BetType] {
        guard let raceDay = selectedRaceDay else { return [] }
        let allowedTypes = ["6'lı Ganyan", "5'li Ganyan", "4'lü Ganyan", "3'lü Ganyan"]
        return raceDay.bahisler.filter { type in allowedTypes.contains { allowed in type.BAHIS.localizedCaseInsensitiveContains(allowed) } }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Bahis bilgileri yükleniyor...").padding()
                Spacer()
            } else if let errorMessage = errorMessage {
                ContentUnavailableView("Hata", systemImage: "xmark.octagon", description: Text(errorMessage))
            } else {
                mainContent()
            }
        }
        .preferredColorScheme(.dark).background(themeBackground).task { await loadBettingData() }.navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedRaceDay) { _, newValue in
            if initialSelections == nil {
                if let bahisler = newValue?.bahisler { selectedBetType = findPriorityBetType(in: bahisler) }
                resetSelections()
            }
        }
        .onChange(of: selectedBetType) { _, newValue in
            if initialSelections == nil { resetSelections() }
            if let firstRace = filteredRaces(for: selectedRaceDay, betType: newValue).first { selectedRace = firstRace }
        }
    }

    @ViewBuilder
    private func mainContent() -> some View {
        VStack(spacing: 0) {
            headerPickersView()
            raceLegsView()
            if let race = selectedRace, let info = race.BILGI, !info.isEmpty {
                HStack(alignment: .center, spacing: 10) {
                    Text(info).font(.system(size: 10, weight: .bold)).foregroundColor(.primary).lineLimit(1).truncationMode(.tail)
                    Spacer()
                    Label(race.SAAT, systemImage: "clock.fill").font(.system(size: 10, weight: .bold)).foregroundColor(.primary)
                }.padding(.horizontal, 8).padding(.bottom, 8).padding(.top, 8)
            }
            HStack(alignment: .top, spacing: 8) {
                ScrollView {
                    if let race = selectedRace { horseListView(race: race) }
                    else { ContentUnavailableView("Koşu Seçin", systemImage: "arrow.up") }
                }.frame(maxWidth: .infinity)
                sideBettingPanel().frame(width: 180).background(Color(UIColor.systemGray6)).cornerRadius(12).padding(.top, 4).padding(.trailing, 8)
            }.padding(.bottom, 80)
        }
    }

    @ViewBuilder
    private func headerPickersView() -> some View {
        HStack(spacing: 0) {
            Menu {
                Picker("Hipodrom", selection: $selectedRaceDay) {
                    ForEach(raceDays) { day in Text(formattedRaceDayTitle(for: day)).tag(day as BetRaceDay?) }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HİPODROM").font(.system(size: 10, weight: .bold)).foregroundColor(themePrimary.opacity(0.8))
                        Text(formattedRaceDayTitle(for: selectedRaceDay)).font(.system(size: 11, weight: .bold)).foregroundColor(.primary).lineLimit(1).minimumScaleFactor(0.7)
                    }
                    Spacer(); Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                }.padding(.horizontal, 10).padding(.vertical, 8).frame(maxWidth: .infinity, alignment: .leading)
            }
            Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 25)
            Menu {
                Picker("Bahis Türü", selection: $selectedBetType) {
                    ForEach(ganyanBetTypes) { type in Text(betTypeLabel(for: type)).tag(type as BetType?) }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BAHİS TÜRÜ").font(.system(size: 10, weight: .bold)).foregroundColor(themePrimary.opacity(0.8))
                        Text(selectedBetType.map { betTypeLabel(for: $0) } ?? "").font(.system(size: 12, weight: .bold)).foregroundColor(.primary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    Spacer(); Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                }.padding(.horizontal, 10).padding(.vertical, 8).frame(maxWidth: .infinity, alignment: .leading)
            }
        }.background(Color.white.opacity(0.05)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1)).padding(.horizontal, 8).padding(.top, 8)
    }

    @ViewBuilder
    private func raceLegsView() -> some View {
        if let raceDay = selectedRaceDay, let betType = selectedBetType {
            let races = filteredRaces(for: raceDay, betType: betType)
            if !races.isEmpty {
                let visibleCount: CGFloat = 6
                let hPadding: CGFloat = 8
                let itemSpacing: CGFloat = 8
                let screenWidth = UIScreen.main.bounds.width
                let itemSize = (screenWidth - (hPadding * 2) - (itemSpacing * (visibleCount - 1))) / visibleCount
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: itemSpacing) {
                        ForEach(races) { race in
                            Button { selectedRace = race } label: {
                                let count = selectedHorses[race.KOD]?.count ?? 0
                                let isCurrentRace = selectedRace?.KOD == race.KOD
                                ZStack {
                                    Triangle(corner: .bottomLeft).fill(isCurrentRace ? themePrimary.opacity(0.4) : Color.gray.opacity(0.2))
                                    Triangle(corner: .topRight).fill(count > 0 ? themeAccent.opacity(0.9) : Color.gray.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 8).stroke(isCurrentRace ? themePrimary : Color.gray.opacity(0.3), lineWidth: isCurrentRace ? 2 : 1)
                                    VStack {
                                        HStack { Spacer(); Text("\(count) at").font(.system(size: 11, weight: .bold)).foregroundColor(count > 0 ? .white : .secondary.opacity(0.5)) }
                                        Spacer()
                                        HStack { Text("\(race.NO). Koşu").font(.system(size: 11, weight: .black)).foregroundColor(.white); Spacer() }
                                    }.padding(4)
                                }.frame(width: itemSize, height: itemSize).clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }.padding(.horizontal, hPadding).padding(.vertical, 8)
                }
            }
        }
    }

    @ViewBuilder
    private func horseListView(race: BetRace) -> some View {
        VStack(spacing: 0) {
            if let horses = race.atlar {
                Button(action: { toggleAllHorses(in: race) }) {
                    HStack {
                        Text("HEPSİ").font(.system(size: 12, weight: .bold)).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: isAllSelected(in: race) ? "checkmark.circle.fill" : "circle").foregroundColor(isAllSelected(in: race) ? themePrimary : .secondary).font(.system(size: 18))
                    }.padding(.horizontal, 16).padding(.vertical, 10).background(Color.white.opacity(0.05)).cornerRadius(8).padding(.horizontal, 4).padding(.bottom, 6)
                }.buttonStyle(.plain)
                LazyVStack(spacing: 4) {
                    ForEach(horses) { horse in HorseRow(horse: horse, isSelected: selectedHorses[race.KOD]?.contains(horse.KOD) ?? false) { toggleHorseSelection(raceId: race.KOD, horseKod: horse.KOD) } }
                }
            }
        }.padding(.vertical, 4)
    }

    @ViewBuilder
    private func sideBettingPanel() -> some View {
        VStack(spacing: 12) {
            Label("KUPON", systemImage: "turkishlirasign.circle.fill").font(.caption.bold()).padding(.top, 10)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    let legSelections = getLegSelections()
                    // ID ÇAKIŞMASINI ÖNLEMEK İÇİN INDEX KULLANIYORUZ
                    ForEach(0..<legSelections.count, id: \.self) { index in
                        Text(legSelections[index]).font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(Color.cyan.opacity(0.9)).padding(.horizontal, 8).padding(.vertical, 4).frame(maxWidth: .infinity, alignment: .leading).background(Color.black.opacity(0.2)).cornerRadius(6)
                    }
                }.padding(.horizontal, 6)
            }
            Divider()
            HStack(spacing: 0) {
                Text("Misli:").font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { if multiplier > 1 { multiplier -= 1 } }) { Image(systemName: "minus.square.fill").foregroundColor(.secondary).font(.system(size: 24)) }
                    Text("\(multiplier)").font(.system(size: 12, weight: .bold)).frame(width: 20)
                    Button(action: { if multiplier < 99 { multiplier += 1 } }) { Image(systemName: "plus.square.fill").foregroundColor(themePrimary).font(.system(size: 24)) }
                }
            }.padding(.horizontal)
            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bahis Oranı").font(.system(size: 10)).foregroundColor(.secondary)
                        Text("\(calculateBetCombinations())").font(.system(size: 16, weight: .bold)).lineLimit(1)
                    }
                    Spacer(minLength: 4)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Tutar").font(.system(size: 10)).foregroundColor(.secondary)
                        Text("\(String(format: "%.2f", calculateTotalBetAmount())) ₺").font(.system(size: 16, weight: .bold)).foregroundColor(themeAccent).lineLimit(1)
                    }
                }.padding(.horizontal, 8)
            }.padding(.bottom, 20)
        }
    }

    // Logic Helpers...
    private func formattedRaceDayTitle(for day: BetRaceDay?) -> String {
        guard let day = day else { return "" }
        let yer = day.YER.uppercased()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        if let date = formatter.date(from: day.TARIH) {
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "tr_TR")
            dayFormatter.dateFormat = "EEEE"
            return "\(yer) (\(dayFormatter.string(from: date).uppercased()))"
        }
        return yer
    }
    private func findPriorityBetType(in types: [BetType]) -> BetType? {
        let allowedTypes = ["6'lı Ganyan", "5'li Ganyan", "4'lü Ganyan", "3'lü Ganyan"]
        for priority in allowedTypes { if let found = types.first(where: { $0.BAHIS.localizedCaseInsensitiveContains(priority) }) { return found } }
        return nil
    }
    private func betTypeLabel(for type: BetType) -> String {
        let allowed = ["6'lı Ganyan", "5'li Ganyan", "4'lü Ganyan", "3'lü Ganyan"]
        let filteredList = (selectedRaceDay?.bahisler ?? []).filter { t in allowed.contains { allowed in t.BAHIS.localizedCaseInsensitiveContains(allowed) } }
        let sameNameTypes = filteredList.filter { $0.BAHIS == type.BAHIS }
        if sameNameTypes.count > 1 {
            let sortedByRace = sameNameTypes.sorted { ($0.kosular.first ?? 0) < ($1.kosular.first ?? 0) }
            if let index = sortedByRace.firstIndex(where: { $0.id == type.id }) { return "\(index + 1). \(type.BAHIS.uppercased())" }
        }
        return type.BAHIS.uppercased()
    }
    private func getLegSelections() -> [String] {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType else { return [] }
        let races = filteredRaces(for: raceDay, betType: betType)
        return races.map { race in
            let selectedCodes = selectedHorses[race.KOD] ?? []
            if selectedCodes.isEmpty { return "-" }
            let validHorseKods = race.atlar?.filter { $0.KOSMAZ != true }.map { $0.KOD } ?? []
            if !validHorseKods.isEmpty && validHorseKods.allSatisfy({ selectedCodes.contains($0) }) { return "HEPSİ" }
            let horseNos = race.atlar?.filter { selectedCodes.contains($0.KOD) }
                .compactMap { Int($0.NO) }.sorted().map { String($0) } ?? []
            return horseNos.joined(separator: "-")
        }
    }
    private func filteredRaces(for raceDay: BetRaceDay?, betType: BetType?) -> [BetRace] {
        guard let raceDay, let betType, let allRaces = raceDay.kosular else { return [] }
        let startRaceNo = betType.kosular.first ?? 1
        let name = betType.BAHIS.lowercased()
        var legCount = 1
        if name.contains("7'li") { legCount = 7 }
        else if name.contains("6'lı") { legCount = 6 }
        else if name.contains("5'li") { legCount = 5 }
        else if name.contains("4'lü") { legCount = 4 }
        else if name.contains("3'lü") { legCount = 3 }
        let sortedRaces = allRaces.sorted { (Int($0.NO) ?? 0) < (Int($1.NO) ?? 0) }
        if let startIndex = sortedRaces.firstIndex(where: { Int($0.NO) == startRaceNo }) {
            let endIndex = min(startIndex + legCount, sortedRaces.count)
            return Array(sortedRaces[startIndex..<endIndex])
        }
        return []
    }
    private func isAllSelected(in race: BetRace) -> Bool {
        let validHorseKods = race.atlar?.filter { $0.KOSMAZ != true }.map { $0.KOD } ?? []
        if validHorseKods.isEmpty { return false }
        let selectedKods = selectedHorses[race.KOD] ?? []
        return validHorseKods.allSatisfy { selectedKods.contains($0) }
    }
    private func toggleAllHorses(in race: BetRace) {
        let validHorseKods = race.atlar?.filter { $0.KOSMAZ != true }.map { $0.KOD } ?? []
        if isAllSelected(in: race) { selectedHorses[race.KOD] = [] }
        else { selectedHorses[race.KOD] = Set(validHorseKods) }
    }
    private func loadBettingData() async {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.raceDays = [MockData.raceDayAnkara]
            self.selectedRaceDay = MockData.raceDayAnkara
            self.selectedBetType = MockData.ganyan6
            self.selectedHorses = MockData.initialSelections
            self.isLoading = false
            return
        }
        
        do {
            let (cData, _) = try await URLSession.shared.data(from: URL(string: "https://ebayi.tjk.org/s/d/bet/checksum.json")!)
            let checksum = try JSONDecoder().decode(BetChecksumResponse.self, from: cData).checksum
            let (bData, _) = try await URLSession.shared.data(from: URL(string: "https://emedya-cdn.tjk.org/s/d/bet/bet-\(checksum).json")!)
            let decoded = try JSONDecoder().decode(BetDataResponse.self, from: bData)
            let filtered = decoded.data.yarislar.filter { (Int($0.KOD) ?? 99) < 11 }
            await MainActor.run {
                self.raceDays = filtered
                self.isLoading = false
                if let day = initialDay {
                    self.selectedRaceDay = day; self.selectedBetType = initialBet
                    if let selections = initialSelections { self.selectedHorses = selections }
                } else if let day = filtered.first { self.selectedRaceDay = day }
            }
        } catch { await MainActor.run { self.errorMessage = "Hata oluştu"; self.isLoading = false } }
    }
    private func toggleHorseSelection(raceId: String, horseKod: String) {
        var selections = selectedHorses[raceId] ?? []
        if selections.contains(horseKod) { selections.remove(horseKod) }
        else { selections.insert(horseKod) }
        selectedHorses[raceId] = selections
    }
    private func calculateBetCombinations() -> Int {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType else { return 0 }
        let races = filteredRaces(for: raceDay, betType: betType)
        if races.count > 1 {
            let product = races.reduce(1) { $0 * (max(selectedHorses[$1.KOD]?.count ?? 0, 1)) }
            let totalSelected = selectedHorses.values.reduce(0) { $0 + $1.count }
            return totalSelected == 0 ? 0 : product
        } else { return races.reduce(0) { $0 + (selectedHorses[$1.KOD]?.count ?? 0) } }
    }
    private func calculateTotalBetAmount() -> Double {
        guard let betType = selectedBetType else { return 0.0 }
        return Double(calculateBetCombinations()) * Double(multiplier) * (Double(betType.POOLUNIT) / 100.0)
    }
    private func resetSelections() { selectedHorses = [:]; multiplier = 1 }
}

// MARK: - Bileşenler (Aynen Korundu)

struct HorseRow: View {
    let horse: BetHorse
    let isSelected: Bool
    let action: () -> Void
    let themePrimary = Color.cyan
    let themeAccent = Color.orange

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    if let forma = horse.FORMA, let url = URL(string: forma) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image { image.resizable().aspectRatio(contentMode: .fill) }
                        }
                        .frame(width: geo.size.width * 0.4, height: geo.size.height)
                        .mask(LinearGradient(gradient: Gradient(stops: [.init(color: .black, location: 0.3), .init(color: .clear, location: 1.0)]), startPoint: .leading, endPoint: .trailing))
                        .opacity(0.6)
                    }
                }
                HStack(spacing: 8) {
                    Text(horse.NO).font(.system(size: 16, weight: .heavy)).foregroundColor(.white).frame(width: 30).shadow(radius: 2)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(horse.AD).font(.system(size: 11, weight: .bold)).foregroundColor(.white).lineLimit(1).shadow(radius: 1)
                            if let ekuri = horse.EKURI, !ekuri.isEmpty, ekuri != "0", ekuri != "false" {
                                AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/e\(ekuri).gif")) { phase in
                                    if let image = phase.image { image.resizable().scaledToFit().frame(width: 18, height: 18) }
                                }
                                .frame(width: 18, height: 18).shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                            }
                        }
                        Text(horse.JOKEYADI ?? "").font(.system(size: 9)).foregroundColor(.secondary).lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        if let agf2 = horse.AGF2, agf2 > 0 { Text("%\(Int(agf2))").font(.system(size: 9, weight: .bold)).foregroundColor(.secondary) }
                        if let agf1 = horse.AGF1, agf1 > 0 { Text("%\(Int(agf1))").font(.system(size: 10, weight: .bold)).foregroundColor(themeAccent) }
                    }
                    .padding(.trailing, isSelected ? 4 : 0)
                    if isSelected { Image(systemName: "checkmark.circle.fill").foregroundColor(themePrimary).font(.system(size: 16)) }
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
            }
            .background(isSelected ? themePrimary.opacity(0.1) : Color(UIColor.secondarySystemBackground).opacity(0.8))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? themePrimary : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain).disabled(horse.KOSMAZ == true).opacity(horse.KOSMAZ == true ? 0.4 : 1.0).padding(.horizontal, 4)
    }
}

struct Triangle: Shape {
    enum Corner { case bottomLeft, topRight }
    var corner: Corner
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if corner == .bottomLeft { path.move(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: 0, y: rect.maxY)); path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) }
        else { path.move(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: rect.maxX, y: 0)); path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) }
        path.closeSubpath(); return path
    }
}

// MARK: - Preview
private struct MockData {
    static let horse1 = BetHorse(KOD: "H1", NO: "1", AD: "YALNIZEFE", JOKEYADI: "A. ÇELİK", FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg", KOSMAZ: false, AGF1: 22.5, AGF2: 1.0, EKURI: "1")
    static let horse2 = BetHorse(KOD: "H2", NO: "2", AD: "GÜL FIRTINASI", JOKEYADI: "M. KAYA", FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg", KOSMAZ: false, AGF1: 18.2, AGF2: 2.0, EKURI: "1")
    static let horse3 = BetHorse(KOD: "H3", NO: "3", AD: "CESUR RÜZGAR", JOKEYADI: "V. ABİŞ", FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg", KOSMAZ: false, AGF1: 15.0, AGF2: 3.0, EKURI: nil)
    static let horse4 = BetHorse(KOD: "H4", NO: "4", AD: "KRAL ARTHUR", JOKEYADI: "H. KARATAŞ", FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg", KOSMAZ: true, AGF1: 10.0, AGF2: 4.0, EKURI: nil)
    static let race1 = BetRace(KOD: "R1", NO: "1", SAAT: "14:00", MESAFE: "1400m", PIST: "Kum", BILGI: "Maiden/Dişi", atlar: [horse1, horse2, horse3, horse4])
    static let race2 = BetRace(KOD: "R2", NO: "2", SAAT: "14:30", MESAFE: "1600m", PIST: "Çim", BILGI: "Handikap 15", atlar: [horse1, horse2, horse3])
    static let race3 = BetRace(KOD: "R3", NO: "3", SAAT: "15:00", MESAFE: "1200m", PIST: "Kum", BILGI: "KV-6", atlar: [horse2, horse3])
    static let race4 = BetRace(KOD: "R4", NO: "4", SAAT: "15:30", MESAFE: "2000m", PIST: "Çim", BILGI: "Açık G3", atlar: [horse1, horse3])
    static let race5 = BetRace(KOD: "R5", NO: "5", SAAT: "16:00", MESAFE: "1900m", PIST: "Kum", BILGI: "Şartlı 4", atlar: [horse1, horse2])
    static let race6 = BetRace(KOD: "R6", NO: "6", SAAT: "16:30", MESAFE: "2200m", PIST: "Çim", BILGI: "Handikap 16", atlar: [horse1, horse2, horse3])

    static let ganyan6 = BetType(TYPE: "G6", BAHIS: "6'lı Ganyan", POOLUNIT: 15, kosular: [1, 2, 3, 4, 5, 6])
    static let ganyan5 = BetType(TYPE: "G5", BAHIS: "5'li Ganyan", POOLUNIT: 20, kosular: [2, 3, 4, 5, 6])

    static let raceDayAnkara = BetRaceDay(CARDID: "1", KOD: "ANK", KEY: "ANK20240101", HIPODROM: "Ankara", YER: "Ankara", TARIH: "01/01/2024", GUN: "PAZARTESİ", SIRA: "1", ACILIS: nil, KAPANIS: nil, GECE: false, YABANCI: false, hava: nil, pist: nil, kosular: [race1, race2, race3, race4, race5, race6], bahisler: [ganyan6, ganyan5])
    
    static let initialSelections: [String: Set<String>] = ["R1": ["H1"], "R2": ["H2", "H3"]]
}


#Preview("Veri Yüklü Halde") {
    NavigationView {
        TicketView(
            initialSelections: MockData.initialSelections,
            initialDay: MockData.raceDayAnkara,
            initialBet: MockData.ganyan6
        )
    }
}

#Preview("Boş Kupon") {
    NavigationView {
        TicketView(
            initialDay: MockData.raceDayAnkara,
            initialBet: MockData.ganyan6
        )
    }
}

#Preview("Yükleniyor") {
    TicketView()
}

