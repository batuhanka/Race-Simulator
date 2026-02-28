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
        CINSDETAY = try container.decodeIfPresent(
            String.self,
            forKey: .CINSDETAY
        )
        CINSDETAY_EN = try container.decodeIfPresent(
            String.self,
            forKey: .CINSDETAY_EN
        )
        CINSIYET = try container.decodeIfPresent(String.self, forKey: .CINSIYET)
        ONEMLIADI = try container.decodeIfPresent(
            String.self,
            forKey: .ONEMLIADI
        )
        ikramiyeler = try container.decodeIfPresent(
            [String].self,
            forKey: .ikramiyeler
        )
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
                selectedRace =
                    filteredRaces(
                        for: selectedRaceDay,
                        betType: selectedBetType
                    ).first
                resetSelections()
            }
        }
    }
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
            $0.BAHIS.localizedCaseInsensitiveContains("Ganyan")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Bahis bilgileri yükleniyor...").padding()
                Spacer()
            } else if let errorMessage = errorMessage {
                ContentUnavailableView(
                    "Hata",
                    systemImage: "xmark.octagon",
                    description: Text(errorMessage)
                )
            } else {
                mainContent()
            }
        }
        .preferredColorScheme(.dark)
        .background(themeBackground)
        .task { await loadBettingData() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Hipodrom", selection: $selectedRaceDay) {
                    ForEach(raceDays) { day in
                        Text("\(day.YER.uppercased()) (\(day.TARIH))").tag(
                            day as BetRaceDay?
                        )
                    }
                    
                }
                .pickerStyle(.menu)
            }
        }
    }

    @ViewBuilder
    private func mainContent() -> some View {
        VStack(spacing: 0) {
            selectionView()

            raceLegsView()

            HStack(alignment: .top, spacing: 8) {
                // SOL TARAF: Dinamik At Listesi
                ScrollView {
                    if let race = selectedRace {
                        horseListView(race: race)
                    } else {
                        ContentUnavailableView(
                            "Koşu Seçin",
                            systemImage: "arrow.up"
                        )
                    }
                }
                .frame(maxWidth: .infinity)

                // SAĞ TARAF: Sabit Kupon Paneli
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
    private func selectionView() -> some View {
        Menu {
            Picker("Bahis Türü", selection: $selectedBetType) {
                ForEach(ganyanBetTypes) { type in
                    Text(type.BAHIS).tag(type as BetType?)
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedBetType?.BAHIS ?? "Ganyan Türü Seçin").font(
                        .subheadline
                    )
                    /*
                    Text(
                        "Ayaklar: \(selectedBetType?.kosular.map(String.init).joined(separator: "-") ?? "...")"
                    ).font(.caption).foregroundColor(.secondary)
                     */
                }
                Spacer()
                Image(systemName: "chevron.down").foregroundColor(.secondary)
            }
            .padding()
            //.background(Color(UIColor.secondarySystemBackground))
        }
    }

    @ViewBuilder
    private func raceLegsView() -> some View {
        if let raceDay = selectedRaceDay, let betType = selectedBetType {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filteredRaces(for: raceDay, betType: betType)) {
                        race in
                        Button {
                            selectedRace = race
                        } label: {
                            let count = selectedHorses[race.KOD]?.count ?? 0
                            let isCurrentRace = selectedRace?.KOD == race.KOD
                            ZStack {
                                Triangle(corner: .bottomLeft).fill(
                                    isCurrentRace
                                        ? themePrimary.opacity(0.4)
                                        : Color.gray.opacity(0.2)
                                )
                                Triangle(corner: .topRight).fill(
                                    count > 0
                                        ? themeAccent.opacity(0.9)
                                        : Color.gray.opacity(0.1)
                                )

                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        isCurrentRace
                                            ? themePrimary
                                            : Color.gray.opacity(0.3),
                                        lineWidth: isCurrentRace ? 2 : 1
                                    )

                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("\(count) at").font(
                                            .system(size: 11, weight: .bold)
                                        ).foregroundColor(
                                            count > 0
                                                ? .white
                                                : .secondary.opacity(0.5)
                                        )
                                    }
                                    Spacer()
                                    HStack {
                                        Text("\(race.NO). Koşu").font(
                                            .system(size: 11, weight: .black)
                                        ).foregroundColor(.white)
                                        Spacer()
                                    }
                                }.padding(6)
                            }
                            .frame(width: 65 , height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 8).padding(.vertical, 8)
            }
        }
    }

    @ViewBuilder
    private func horseListView(race: BetRace) -> some View {
        if let horses = race.atlar {
            LazyVStack(spacing: 4) {
                ForEach(horses) { horse in
                    HorseRow(
                        horse: horse,
                        isSelected: selectedHorses[race.KOD]?.contains(
                            horse.KOD
                        ) ?? false
                    ) {
                        toggleHorseSelection(
                            raceId: race.KOD,
                            horseKod: horse.KOD
                        )
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func sideBettingPanel() -> some View {
        VStack(spacing: 12) {
            // Header
            Label("KUPON", systemImage: "banknotes.fill")
                .font(.caption.bold())
                .padding(.top, 10)
            
            Divider()
            
            // At Seçimleri Listesi
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(getLegSelections(), id: \.self) { legStr in
                        Text(legStr)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.cyan.opacity(0.9))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 6)
            }
            
            Divider()

            // Misli (Tek Satırda)
            HStack(spacing: 0) {
                Text("Misli:").font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { if multiplier > 1 { multiplier -= 1 } }) {
                        Image(systemName: "minus.square.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
                    }
                    Text("\(multiplier)")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 20)
                    Button(action: { if multiplier < 99 { multiplier += 1 } }) {
                        Image(systemName: "plus.square.fill")
                            .foregroundColor(themePrimary)
                            .font(.system(size: 24))
                    }
                }
            }.padding(.horizontal)
            
            // Bahis Oranı ve Tutar (Yan yana)
            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bahis Oranı").font(.system(size: 12)).foregroundColor(.secondary)
                        Text("\(calculateBetCombinations())")
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(1)
                    }
                    Spacer(minLength: 4)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Tutar").font(.system(size: 12)).foregroundColor(.secondary)
                        Text("\(String(format: "%.2f", calculateTotalBetAmount())) ₺")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeAccent)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 8)
            }

            
            .padding(.horizontal, 8)
            .padding(.bottom, 20)
            
            /*
            Button { /* Onayla */
            } label: {
                VStack {
                    Image(systemName: "checkmark.circle.fill").font(.title3)
                    Text("ONAYLA").font(.caption2.bold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(themePrimary)
                .foregroundColor(.black)
                .cornerRadius(12)
            }
            .padding(.horizontal, 8)
             .padding(.bottom, 20)
             */
        }
    }

    // MARK: - Logic Helpers
    
    /// Kupon panelinde her ayak için seçilen atların numaralarını formatlar (Örn: "1-3-5")
    private func getLegSelections() -> [String] {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType else { return [] }
        
        // Bahis türündeki koşu numaralarını sıralı alalım
        let sortedLegRaceNos = betType.kosular.sorted()

        return sortedLegRaceNos.compactMap { raceNoInt in
            let raceNoStr = String(raceNoInt)
            // İlgili koşu objesini bulalım
            guard let race = raceDay.kosular?.first(where: { $0.NO == raceNoStr }) else { return nil }
            let selectedCodes = selectedHorses[race.KOD] ?? []
            
            if selectedCodes.isEmpty { return "-" }

            // Seçilen atların kodlarını numaralarına (NO) çevirip sıralayalım
            let horseNos = race.atlar?.filter { selectedCodes.contains($0.KOD) }
                .compactMap { Int($0.NO) }
                .sorted()
                .map { String($0) } ?? []

            return horseNos.joined(separator: "-")
        }
    }

    private func filteredRaces(for raceDay: BetRaceDay?, betType: BetType?)
        -> [BetRace]
    {
        guard let raceDay, let betType, let kosular = raceDay.kosular else {
            return []
        }
        let availableRaceNumbers = Set(betType.kosular.map { String($0) })
        return kosular.filter { availableRaceNumbers.contains($0.NO) }.sorted {
            (Int($0.NO) ?? 0) < (Int($1.NO) ?? 0)
        }
    }

    private func loadBettingData() async {
        do {
            let (cData, _) = try await URLSession.shared.data(
                from: URL(
                    string: "https://ebayi.tjk.org/s/d/bet/checksum.json"
                )!
            )
            let checksum = try JSONDecoder().decode(
                BetChecksumResponse.self,
                from: cData
            ).checksum
            let (bData, _) = try await URLSession.shared.data(
                from: URL(
                    string:
                        "https://emedya-cdn.tjk.org/s/d/bet/bet-\(checksum).json"
                )!
            )
            let decoded = try JSONDecoder().decode(
                BetDataResponse.self,
                from: bData
            )
            let filtered = decoded.data.yarislar.filter {
                (Int($0.KOD) ?? 99) < 11
            }

            await MainActor.run {
                self.raceDays = filtered
                self.isLoading = false
                if let day = filtered.first {
                    self.selectedRaceDay = day
                    self.selectedBetType = ganyanBetTypes.first
                    self.selectedRace =
                        filteredRaces(for: day, betType: selectedBetType).first
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Hata oluştu"
                self.isLoading = false
            }
        }
    }

    private func toggleHorseSelection(raceId: String, horseKod: String) {
        var selections = selectedHorses[raceId] ?? []
        if selections.contains(horseKod) {
            selections.remove(horseKod)
        } else {
            if selectedBetType?.BAHIS == "Ganyan" { selections.removeAll() }
            selections.insert(horseKod)
        }
        selectedHorses[raceId] = selections
    }

    private func calculateBetCombinations() -> Int {
        guard let raceDay = selectedRaceDay, let betType = selectedBetType
        else { return 0 }
        let filtered = filteredRaces(for: raceDay, betType: betType)
        if betType.kosular.count > 1 {
            let product = filtered.reduce(1) {
                $0 * (max(selectedHorses[$1.KOD]?.count ?? 0, 1))
            }
            return selectedHorses.values.flatMap({ $0 }).isEmpty ? 0 : product
        }
        return filtered.reduce(0) { $0 + (selectedHorses[$1.KOD]?.count ?? 0) }
    }

    private func calculateTotalBetAmount() -> Double {
        guard let betType = selectedBetType else { return 0.0 }
        return Double(calculateBetCombinations()) * Double(multiplier)
            * (Double(betType.POOLUNIT) / 100.0)
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
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(
                            width: geo.size.width * 0.4,
                            height: geo.size.height
                        )
                        .mask(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black, location: 0.3),
                                    .init(color: .clear, location: 1.0),
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(0.6)
                    }
                }

                HStack(spacing: 8) {
                    Text(horse.NO)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.white)
                        .frame(width: 30)
                        .shadow(radius: 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(horse.AD)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .shadow(radius: 1)

                        Text(horse.JOKEYADI ?? "Jokey Belirtilmemiş")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(themePrimary)
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .background(
                isSelected
                    ? themePrimary.opacity(0.1)
                    : Color(UIColor.secondarySystemBackground).opacity(0.8)
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? themePrimary : Color.clear,
                        lineWidth: 1
                    )
            )
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
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        TicketView()
    }
}

