import SwiftUI

struct RaceInfoCardPopup: View {
    // MARK: - Properties
    @Binding var isExpanded: Bool
    let race: Race
    let havaData: HavaData
    let cityName: String
    let selectedDate: Date
    let allRaceResults: [RaceResult]
    let allResultsLoaded: Bool
    var previewData: AGFResultData? = nil  // Yalnızca Preview için

    @State private var agfResults: AGFResultData?
    @State private var isLoadingResults = false
    @State private var selectedResultType = 1

    enum CardPosition { case leading, bottom }
    let position: CardPosition

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    // MARK: - Body
    var body: some View {
        content
            .task(id: cityName) { await loadAGFResults() }
            .onChange(of: allResultsLoaded) { _, loaded in
                if loaded { Task { await loadAGFResults() } }
            }
    }

    private var content: some View {
        Group {
            if position == .leading {
                leadingPositionCard
            } else {
                bottomPositionCard
            }
        }
    }

    // MARK: - Load Results
    private func loadAGFResults() async {
        if let preview = previewData {
            await MainActor.run {
                self.agfResults = preview
                if preview.hasType1 { self.selectedResultType = 1 }
                else if preview.hasType2 { self.selectedResultType = 2 }
                self.isLoadingResults = false
            }
            return
        }
        guard !cityName.isEmpty else { return }
        await MainActor.run { isLoadingResults = true }

        if isToday {
            // Bugün: checksum yapısını kullan
            do {
                let data = try await JsonParser().getCityRaceResults(cityName: cityName)
                if let agfData = AGFResultData(from: data) {
                    await MainActor.run {
                        self.agfResults = agfData
                        if agfData.hasType1 { self.selectedResultType = 1 }
                        else if agfData.hasType2 { self.selectedResultType = 2 }
                        self.isLoadingResults = false
                    }
                    return
                }
            } catch {}
            await MainActor.run {
                self.agfResults = nil
                self.isLoadingResults = false
            }
        } else {
            // Eski tarihler: tüm sonuçlar yüklenene kadar bekle
            guard allResultsLoaded else {
                // isLoadingResults = true hâlde bekle, onChange(allResultsLoaded) tetikleyecek
                return
            }
            let agfData = buildPastDateAGF(from: allRaceResults)
            await MainActor.run {
                self.agfResults = agfData
                if let d = agfData {
                    if d.hasType1 { self.selectedResultType = 1 }
                    else if d.hasType2 { self.selectedResultType = 2 }
                }
                self.isLoadingResults = false
            }
        }
    }

    // MARK: - Past Date AGF Builder
    private func buildPastDateAGF(from results: [RaceResult]) -> AGFResultData? {
        guard !results.isEmpty else { return nil }

        // BAHISLER_TR'de "1. 6...GANYAN(...): XXXXTL" formatından son koşuyu ve tutarı bul
        var t1LastRace: Int? = nil
        var t2LastRace: Int? = nil
        var t1Altili: String? = nil
        var t2Altili: String? = nil

        for res in results {
            guard let raceNo = Int(res.RACENO ?? ""),
                  let bahis = res.BAHISLER_TR else { continue }
            let lower = bahis.lowercased(with: Locale(identifier: "tr_TR"))

            // Numaralı: "1. 6'lı Ganyan" veya "2. 6'lı Ganyan"
            if t1LastRace == nil && lower.contains("1. 6") && lower.contains("ganyan") {
                t1LastRace = raceNo
                t1Altili = extractAltiliAmount(from: bahis, typePrefix: "1. 6")
            }
            if t2LastRace == nil && lower.contains("2. 6") && lower.contains("ganyan") {
                t2LastRace = raceNo
                t2Altili = extractAltiliAmount(from: bahis, typePrefix: "2. 6")
            }
            // Tek 6'lı Ganyan olan günler: sadece "6'lı Ganyan" (prefix olmadan)
            if t1LastRace == nil
                && !lower.contains("1. 6") && !lower.contains("2. 6")
                && (lower.contains("6'l") || lower.contains("6li")) && lower.contains("ganyan") {
                t1LastRace = raceNo
                t1Altili = extractAltiliAmount(from: bahis, typePrefix: "6'")
                    ?? extractAltiliAmount(from: bahis, typePrefix: "6L")
            }
        }

        // Son koşudan 5 geri giderek başlangıç koşusunu hesapla
        let t1Start = t1LastRace.map { $0 - 5 }
        let t2Start = t2LastRace.map { $0 - 5 }

        var type1Winners: [AGFResultData.LegResult] = []
        var type2Winners: [AGFResultData.LegResult] = []

        for res in results {
            guard let winner = res.SONUCLAR?.first(where: { $0.SONUC == "1" }),
                  let raceNo = Int(res.RACENO ?? "") else { continue }

            if let s1 = t1Start, raceNo >= s1 && raceNo <= s1 + 5 {
                type1Winners.append(.init(
                    horse: "\(winner.NO ?? "?") - \(winner.AD ?? "Bilinmeyen")",
                    ganyan: winner.GANYAN ?? "-",
                    agf: "\(raceNo - s1 + 1)"
                ))
            }
            if let s2 = t2Start, raceNo >= s2 && raceNo <= s2 + 5 {
                type2Winners.append(.init(
                    horse: "\(winner.NO ?? "?") - \(winner.AD ?? "Bilinmeyen")",
                    ganyan: winner.GANYAN ?? "-",
                    agf: "\(raceNo - s2 + 1)"
                ))
            }
        }

        let sortedT1 = type1Winners.sorted { (Int($0.agf) ?? 0) < (Int($1.agf) ?? 0) }
        let sortedT2 = type2Winners.sorted { (Int($0.agf) ?? 0) < (Int($1.agf) ?? 0) }

        guard !sortedT1.isEmpty || !sortedT2.isEmpty else { return nil }

        return AGFResultData(
            type1Legs: sortedT1,
            type2Legs: sortedT2,
            tevzi: nil,
            altili1: t1Altili,
            altili2: t2Altili,
            aciklama: nil
        )
    }

    private func extractAltiliAmount(from bahislerTR: String, typePrefix: String) -> String? {
        guard let prefixRange = bahislerTR.range(of: typePrefix, options: .caseInsensitive) else { return nil }
        let fromPrefix = String(bahislerTR[prefixRange.lowerBound...])

        // At numaralarını içeren parantezi atla: "(...): " sonrasından al
        guard let colonRange = fromPrefix.range(of: "): ") else { return nil }
        let fromColon = String(fromPrefix[colonRange.upperBound...])

        // "XXXXTL" formatından "XXXX" kısmını çıkar
        let amount = fromColon.components(separatedBy: "TL").first?.trimmingCharacters(in: .whitespaces)
        return amount?.isEmpty == false ? amount : nil
    }

    // MARK: - Sol Taraf Konumlandırma
    private var leadingPositionCard: some View {
        HStack(spacing: 0) {
            if isExpanded {
                cardContent
                    .frame(width: 350, height: 420)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.left" : "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 80)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 0)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Alt Taraf Konumlandırma
    private var bottomPositionCard: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 32)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: -4)
            }
            .buttonStyle(.plain)

            if isExpanded {
                cardContent
                    .frame(height: 250)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }

    // MARK: - Kart İçeriği
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let results = agfResults {
                agfResultsSection(results: results)
            } else if isLoadingResults {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.cyan)
                        .scaleEffect(1.2)
                    Text("Sonuçlar yükleniyor...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.3))
                    Text("AGF sonucu bulunamadı")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.7))
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.5), Color.blue.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
        .padding(8)
    }

    // MARK: - AGF Results Section
    @ViewBuilder
    private func agfResultsSection(results: AGFResultData) -> some View {
        VStack(alignment: .center, spacing: 0) {
            // Tab Seçici (her iki tip varsa)
            if results.hasType1 && results.hasType2 {
                HStack(spacing: 20) {
                    tabButton(type: 1, isSelected: selectedResultType == 1)
                    tabButton(type: 2, isSelected: selectedResultType == 2)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            // Tablo
            VStack(spacing: 4) {
                HStack(spacing: 10) {
                    //Text("#")
                    //    .font(.caption.bold())
                    //    .foregroundColor(.cyan)
                    //    .frame(width: 35, alignment: .center)
                    Text("At")
                        .font(.caption.bold())
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Ganyan")
                        .font(.caption.bold())
                        .foregroundColor(.cyan)
                        .frame(width: 55, alignment: .trailing)
                    //Text("Ayak")
                    //    .font(.caption.bold())
                    //    .foregroundColor(.cyan)
                    //    .frame(width: 35, alignment: .trailing)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.cyan.opacity(0.25))
                .cornerRadius(8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        let legs = selectedResultType == 1 && results.hasType1 ? results.type1Legs : results.type2Legs

                        ForEach(legs.indices, id: \.self) { index in
                            agfResultRow(
                                //rank: index + 1,
                                horseName: legs[index].horse,
                                ganyan: legs[index].ganyan,
                                //agf: legs[index].agf
                            )
                            if index < legs.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                    .padding(.horizontal, 12)
                            }
                        }
                    }
                }
                
                
                // Altılı Kazanç (tevzi sadece bugün için gösterilir)
                let currentAltili = selectedResultType == 1 ? results.altili1 : results.altili2
                if results.tevzi != nil || currentAltili != nil {
                    HStack(spacing: 16) {
                        if let tevzi = results.tevzi {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tevzi")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text(tevzi)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                            }
                            Divider().frame(height: 10)
                        }

                        if let altili = currentAltili {
                            HStack(spacing: 8) {
                                Text("Altılı Kazanç:")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white.opacity(0.6))
                                Text(altili + " ₺")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Color.orange)
                            }
                            .padding(.top, 0)
                        }

                        
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.cyan.opacity(0.15)))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }

            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func tabButton(type: Int, isSelected: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedResultType = type
            }
        } label: {
            Text("\(type). 6lı Ganyan")
                .font(.headline.bold())
                .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 6).fill(isSelected ? Color.cyan : Color.clear))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.cyan.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func agfResultRow(horseName: String, ganyan: String) -> some View {
        HStack(spacing: 4) {
            //Text("\(rank)")
            //    .font(.caption.bold())
            //    .foregroundColor(.white)
            //    .frame(width: 35, alignment: .center)
            //    .padding(.vertical, 10)
            Text(horseName)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
            Text(ganyan)
                .font(.caption.bold())
                .foregroundColor(.green)
                .frame(width: 55, alignment: .trailing)
            //Text(agf)
            //    .font(.caption.bold())
            //    .foregroundColor(.orange)
            //    .frame(width: 35, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - AGF Result Data Model
struct AGFResultData {
    struct LegResult {
        let horse: String
        let ganyan: String
        let agf: String
    }

    let hasType1: Bool
    let hasType2: Bool
    let type1Legs: [LegResult]
    let type2Legs: [LegResult]
    let tevzi: String?    // Yalnızca bugün (checksum'dan gelir)
    let altili1: String?  // 1. Altılı Ganyan tutarı
    let altili2: String?  // 2. Altılı Ganyan tutarı
    let aciklama: String?

    /// Bugün için checksum API'den gelen dictionary'den oluştur
    init?(from dictionary: [String: Any]) {
        var t1: [LegResult] = []
        var t2: [LegResult] = []

        let gType = (dictionary["Ganyantipi"] as? Int) ?? Int(dictionary["Ganyantipi"] as? String ?? "0") ?? 0

        for i in 1...6 {
            if let horse = dictionary["Ayak\(i)"] as? String,
               let ganyan = dictionary["Ganyan\(i)"] as? String {
                let res = LegResult(horse: horse, ganyan: ganyan, agf: dictionary["AGF\(i)"] as? String ?? "-")
                if gType == 1 { t1.append(res) }
                else if gType == 2 { t2.append(res) }
            }
        }

        self.type1Legs = t1
        self.type2Legs = t2
        self.hasType1 = !t1.isEmpty
        self.hasType2 = !t2.isEmpty
        self.tevzi = dictionary["Tevzi"] as? String
        let altiliValue = dictionary["Altili"] as? String
        self.altili1 = gType != 2 ? altiliValue : nil
        self.altili2 = gType == 2 ? altiliValue : nil
        self.aciklama = dictionary["Aciklama"] as? String

        if t1.isEmpty && t2.isEmpty { return nil }
    }

    /// Geçmiş tarihler için manuel oluştur
    init(type1Legs: [LegResult], type2Legs: [LegResult], tevzi: String?, altili1: String?, altili2: String?, aciklama: String?) {
        self.type1Legs = type1Legs
        self.type2Legs = type2Legs
        self.hasType1 = !type1Legs.isEmpty
        self.hasType2 = !type2Legs.isEmpty
        self.tevzi = tevzi
        self.altili1 = altili1
        self.altili2 = altili2
        self.aciklama = aciklama
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RaceInfoCardPopup(
            isExpanded: .constant(true),
            race: Race(KOD: "1", RACENO: "6", SAAT: "16:30", BILGI_TR: "G 3, 3 Yaşlı İngilizler, 1900 Kum", PIST: "Kum", MESAFE: "1900", atlar: nil),
            havaData: HavaData(aciklama: 0, cimPistagirligi: 0, cimEn: "", cimTr: "", gece: 0, havaDurumIcon: "icon-w-1", havaEn: "Sunny", havaTr: "Güneşli", hipodromAdi: "", hipodromYeri: "", kumPistagirligi: 0, kumEn: "", kumTr: "", nem: 44, sicaklik: 15),
            cityName: "IZMIR",
            selectedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            allRaceResults: [],
            allResultsLoaded: false,
            previewData: AGFResultData(
                type1Legs: [
                    .init(horse: "6 - HUGE SUCCES", ganyan: "9,90", agf: "1"),
                    .init(horse: "4 - KOCAMUTLU", ganyan: "3,85", agf: "2"),
                    .init(horse: "6 - MAGIC BANK", ganyan: "6,45", agf: "3"),
                    .init(horse: "4 - RÜZGARDAHAN", ganyan: "1,60", agf: "4"),
                    .init(horse: "7 - JOLENE", ganyan: "1,30", agf: "5"),
                    .init(horse: "4 - COOL POWER", ganyan: "9,55", agf: "6")
                ],
                type2Legs: [
                    .init(horse: "2 - STAR RUNNER", ganyan: "4,20", agf: "1"),
                    .init(horse: "5 - GOLDEN FLASH", ganyan: "2,75", agf: "2"),
                    .init(horse: "1 - BRAVE HEART", ganyan: "5,10", agf: "3"),
                    .init(horse: "3 - SWIFT ARROW", ganyan: "3,30", agf: "4"),
                    .init(horse: "8 - THUNDER BOLT", ganyan: "7,80", agf: "5"),
                    .init(horse: "6 - STORM KING", ganyan: "2,90", agf: "6")
                ],
                tevzi: nil,
                altili1: "29.789,50",
                altili2: "14.200,00",
                aciklama: nil
            ),
            position: .leading
        )
        .padding(.top, 80)
        .padding(.bottom, 100)
    }
}
