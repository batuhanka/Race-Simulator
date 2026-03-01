import SwiftUI

// MARK: - Veri Modelleri

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
    var id: String { "\(TYPE)_\(kosular.first ?? 0)" } // Aynı isimli bahisleri ayırmak için ID güncellendi
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
}

struct BetHorse: Codable, Identifiable, Hashable {
    var id: String { KOD }
    let KOD: String
    let NO: String
    let AD: String
    let JOKEYADI: String?
    let FORMA: String?
    let KOSMAZ: Bool?

    enum CodingKeys: String, CodingKey {
        case KOD, NO, AD, JOKEYADI, FORMA, KOSMAZ
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
    }
}

// MARK: - Ana View

struct TicketView: View {
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
        return raceDay.bahisler.filter {
            $0.BAHIS.localizedCaseInsensitiveContains("Ganyan") ||
            $0.BAHIS.localizedCaseInsensitiveContains("Plase")
        }
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
        .preferredColorScheme(.dark)
        .background(themeBackground)
        .task { await loadBettingData() }
        .navigationBarTitleDisplayMode(.inline)
        // Hipodrom değiştiğinde öncelikli bahis türünü seç ve sıfırla
        .onChange(of: selectedRaceDay) { _, newValue in
            if let bahisler = newValue?.bahisler {
                selectedBetType = findPriorityBetType(in: bahisler)
            }
            resetSelections()
        }
        // Bahis türü değiştiğinde seçimleri temizle ve ilk koşuyu seç
        .onChange(of: selectedBetType) { _, newValue in
            resetSelections()
            if let firstRace = filteredRaces(for: selectedRaceDay, betType: newValue).first {
                selectedRace = firstRace
            }
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
                }
                .padding(.horizontal, 8).padding(.bottom, 8).padding(.top, 8)
            }

            HStack(alignment: .top, spacing: 8) {
                ScrollView {
                    if let race = selectedRace {
                        horseListView(race: race)
                    } else {
                        ContentUnavailableView("Koşu Seçin", systemImage: "arrow.up")
                    }
                }
                .frame(maxWidth: .infinity)

                sideBettingPanel()
                    .frame(width: 180)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.top, 4)
                    .padding(.trailing, 8)
            }
            .padding(.bottom, 80)
        }
    }

    @ViewBuilder
    private func headerPickersView() -> some View {
        HStack(spacing: 0) {
            // Hipodrom & Gün Seçici
            Menu {
                Picker("Hipodrom", selection: $selectedRaceDay) {
                    ForEach(raceDays) { day in
                        Text(formattedRaceDayTitle(for: day)).tag(day as BetRaceDay?)
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HİPODROM").font(.system(size: 10, weight: .bold)).foregroundColor(themePrimary.opacity(0.8))
                        Text(formattedRaceDayTitle(for: selectedRaceDay)).font(.system(size: 12, weight: .bold)).foregroundColor(.primary).lineLimit(1)
                    }
                    Spacer(); Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                }
                .padding(.horizontal, 12).padding(.vertical, 8).frame(maxWidth: .infinity, alignment: .leading)
            }

            Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 25)

            Menu {
                Picker("Bahis Türü", selection: $selectedBetType) {
                    ForEach(ganyanBetTypes) { type in
                        Text(betTypeLabel(for: type)).tag(type as BetType?)
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BAHİS").font(.system(size: 10, weight: .bold)).foregroundColor(themePrimary.opacity(0.8))
                        Text(selectedBetType.map { betTypeLabel(for: $0) } ?? "").font(.system(size: 12, weight: .bold)).foregroundColor(.primary).lineLimit(1)
                    }
                    Spacer(); Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                }
                .padding(.horizontal, 12).padding(.vertical, 8).frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.white.opacity(0.05)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .padding(.horizontal, 8).padding(.top, 8)
    }

    @ViewBuilder
    private func raceLegsView() -> some View {
        if let raceDay = selectedRaceDay, let betType = selectedBetType {
            let visibleCount: CGFloat = 6
            let hPadding: CGFloat = 8
            let itemSpacing: CGFloat = 8
            let screenWidth = UIScreen.main.bounds.width
            let itemSize = (screenWidth - (hPadding * 2) - (itemSpacing * (visibleCount - 1))) / visibleCount

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    ForEach(filteredRaces(for: raceDay, betType: betType)) { race in
                        Button { selectedRace = race } label: {
                            let count = selectedHorses[race.KOD]?.count ?? 0
                            let isCurrentRace = selectedRace?.KOD == race.KOD
                            ZStack {
                                Triangle(corner: .bottomLeft).fill(isCurrentRace ? themePrimary.opacity(0.4) : Color.gray.opacity(0.2))
                                Triangle(corner: .topRight).fill(count > 0 ? themeAccent.opacity(0.9) : Color.gray.opacity(0.1))
                                RoundedRectangle(cornerRadius: 8).stroke(isCurrentRace ? themePrimary : Color.gray.opacity(0.3), lineWidth: isCurrentRace ? 2 : 1)
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("\(count) at").font(.system(size: 11, weight: .bold)).foregroundColor(count > 0 ? .white : .secondary.opacity(0.5))
                                    }
                                    Spacer()
                                    HStack {
                                        Text("\(race.NO). Koşu").font(.system(size: 11, weight: .black)).foregroundColor(.white)
                                        Spacer()
                                    }
                                }.padding(4)
                            }
                            .frame(width: itemSize, height: itemSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, hPadding).padding(.vertical, 8)
            }
        }
    }

    @ViewBuilder
    private func horseListView(race: BetRace) -> some View {
        if let horses = race.atlar {
            LazyVStack(spacing: 4) {
                ForEach(horses) { horse in
                    HorseRow(horse: horse, isSelected: selectedHorses[race.KOD]?.contains(horse.KOD) ?? false) {
                        toggleHorseSelection(raceId: race.KOD, horseKod: horse.KOD)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func sideBettingPanel() -> some View {
        VStack(spacing: 12) {
            Label("KUPON", systemImage: "banknotes.fill").font(.caption.bold()).padding(.top, 10)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(getLegSelections(), id: \.self) { legStr in
                        Text(legStr).font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(Color.cyan.opacity(0.9))
                            .padding(.horizontal, 8).padding(.vertical, 4).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.2)).cornerRadius(6)
                    }
                }
                .padding(.horizontal, 6)
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
                }
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Logic Helpers
    
    private func formattedRaceDayTitle(for day: BetRaceDay?) -> String {
        guard let day = day else { return "" }
        let yer = day.YER.uppercased()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let date = formatter.date(from: day.TARIH) {
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "tr_TR")
            dayFormatter.dateFormat = "EEEE"
            let dayName = dayFormatter.string(from: date).uppercased()
            return "\(yer) (\(dayName))"
        }
        
        return yer
    }

    private func findPriorityBetType(in types: [BetType]) -> BetType? {
        let priorities = ["6'lı Ganyan", "5'li Ganyan", "4'lü Ganyan", "3'lü Ganyan"]
        for priority in priorities {
            if let found = types.first(where: { $0.BAHIS.localizedCaseInsensitiveContains(priority) }) {
                return found
            }
        }
        return types.first(where: { $0.BAHIS.localizedCaseInsensitiveContains("Ganyan") })
    }

    private func betTypeLabel(for type: BetType) -> String {
        let sameNameTypes = ganyanBetTypes.filter { $0.BAHIS == type.BAHIS }
        if sameNameTypes.count > 1 {
            let sortedByRace = sameNameTypes.sorted { ($0.kosular.first ?? 0) < ($1.kosular.first ?? 0) }
            if let index = sortedByRace.firstIndex(where: { $0.id == type.id }) {
                return "\(index + 1). \(type.BAHIS.uppercased())"
            }
        }
        return type.BAHIS.uppercased()
    }
    
    private func getLegSelections() -> [String] {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType else { return [] }
        let races = filteredRaces(for: raceDay, betType: betType)

        return races.map { race in
            let selectedCodes = selectedHorses[race.KOD] ?? []
            if selectedCodes.isEmpty { return "-" }
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

    private func loadBettingData() async {
        do {
            let (cData, _) = try await URLSession.shared.data(from: URL(string: "https://ebayi.tjk.org/s/d/bet/checksum.json")!)
            let checksum = try JSONDecoder().decode(BetChecksumResponse.self, from: cData).checksum
            let (bData, _) = try await URLSession.shared.data(from: URL(string: "https://emedya-cdn.tjk.org/s/d/bet/bet-\(checksum).json")!)
            let decoded = try JSONDecoder().decode(BetDataResponse.self, from: bData)
            let filtered = decoded.data.yarislar.filter { (Int($0.KOD) ?? 99) < 11 }

            await MainActor.run {
                self.raceDays = filtered
                self.isLoading = false
                if let day = filtered.first {
                    self.selectedRaceDay = day
                }
            }
        } catch {
            await MainActor.run { self.errorMessage = "Hata oluştu"; self.isLoading = false }
        }
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
        } else {
            return races.reduce(0) { $0 + (selectedHorses[$1.KOD]?.count ?? 0) }
        }
    }

    private func calculateTotalBetAmount() -> Double {
        guard let betType = selectedBetType else { return 0.0 }
        return Double(calculateBetCombinations()) * Double(multiplier) * (Double(betType.POOLUNIT) / 100.0)
    }

    private func resetSelections() {
        selectedHorses = [:]
        multiplier = 1
    }
}

// MARK: - Bileşenler

struct HorseRow: View {
    let horse: BetHorse
    let isSelected: Bool
    let action: () -> Void
    let themePrimary = Color.cyan

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    if let forma = horse.FORMA, let url = URL(string: forma) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: geo.size.width * 0.4, height: geo.size.height)
                        .mask(LinearGradient(gradient: Gradient(stops: [.init(color: .black, location: 0.3), .init(color: .clear, location: 1.0)]), startPoint: .leading, endPoint: .trailing))
                        .opacity(0.6)
                    }
                }
                HStack(spacing: 8) {
                    Text(horse.NO).font(.system(size: 16, weight: .heavy)).foregroundColor(.white).frame(width: 30).shadow(radius: 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(horse.AD).font(.system(size: 11, weight: .bold)).foregroundColor(.white).lineLimit(1).shadow(radius: 1)
                        Text(horse.JOKEYADI ?? "Jokey Belirtilmemiş").font(.system(size: 9)).foregroundColor(.secondary).lineLimit(1)
                    }
                    Spacer()
                    if isSelected { Image(systemName: "checkmark.circle.fill").foregroundColor(themePrimary).font(.system(size: 16)) }
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
            }
            .background(isSelected ? themePrimary.opacity(0.1) : Color(UIColor.secondarySystemBackground).opacity(0.8))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? themePrimary : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(horse.KOSMAZ == true)
        .opacity(horse.KOSMAZ == true ? 0.4 : 1.0)
        .padding(.horizontal, 4)
    }
}

struct Triangle: Shape {
    enum Corner { case bottomLeft, topRight }
    var corner: Corner
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if corner == .bottomLeft {
            path.move(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: 0, y: rect.maxY)); path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: rect.maxX, y: 0)); path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        path.closeSubpath(); return path
    }
}

#Preview {
    NavigationStack { TicketView() }
}

