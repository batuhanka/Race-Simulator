//
//  HorseDetailView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 08.03.2026.
//

import SwiftUI
import Foundation

private enum RaceHistorySortKey {
    case sira, tarih, sehir, mesafe, siklet, startNo, derece, jokey, ganyan,
         grup, kosuNo, kosuCins, taki, antrenor, sahip, hp, ikramiye, s20
}

struct HorseDetailView: View {
    let horseCode: String
    let formaURL: String?

    @Environment(\.dismiss) private var dismiss
    @State private var detailInfo: HorseDetailInfo?
    @State private var raceHistory: [HorseRaceHistoryRow] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var loadingVideoIdx: Int? = nil
    @State private var sortKey: RaceHistorySortKey = .tarih
    @State private var sortAscending: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.cyan)
                        Text("Yükleniyor...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()

                        Button("Tekrar Dene") {
                            Task { await loadHorseDetails() }
                        }
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(8)
                    }
                } else if let detail = detailInfo {
                    detailContentView(detail: detail)
                } else {
                    ContentUnavailableView(
                        "Veri Bulunamadı",
                        systemImage: "horse.fill",
                        description: Text("At bilgisi yüklenemedi.")
                    )
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task { await loadHorseDetails() }
    }

    // MARK: - Data Loading
    private func loadHorseDetails() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            async let infoTask    = HtmlParser.shared.parseAtKosuBilgileri(atId: horseCode)
            async let historyTask = HtmlParser.shared.parseAtKosuGecmisi(atId: horseCode)
            let info    = try await infoTask
            let history = (try? await historyTask) ?? []
            await MainActor.run {
                detailInfo   = info
                raceHistory  = history
                isLoading    = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "At bilgileri yüklenemedi:\n\(error.localizedDescription)"
                isLoading    = false
            }
        }
    }

    private func formatCurrency(_ value: String) -> String {
        value.replacingOccurrences(of: "t", with: " ₺")
             .replacingOccurrences(of: "T", with: " ₺")
    }

    // MARK: - Detail Content View
    @ViewBuilder
    private func detailContentView(detail: HorseDetailInfo) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeaderSection(detail: detail)

                VStack(spacing: 12) {
                    twoColumnCard(detail: detail)
                    if !detail.ozetIstatistikleri.isEmpty {
                        statsCard(rows: detail.ozetIstatistikleri)
                    }
                    if !raceHistory.isEmpty {
                        raceHistoryCard(rows: sortedHistory)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero Header
    @ViewBuilder
    private func heroHeaderSection(detail: HorseDetailInfo) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if let formaURL = formaURL, let url = URL(string: formaURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 180)
                                .clipped()
                        } else {
                            gradientPlaceholder
                        }
                    }
                } else {
                    gradientPlaceholder
                }

                LinearGradient(
                    colors: [.black.opacity(0.7), .black.opacity(0.4), .clear, .black.opacity(0.6), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)

                VStack(spacing: 0) {
                    Color.clear.frame(height: geometry.safeAreaInsets.top)

                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Spacer()

                    VStack(spacing: 8) {
                        Text(detail.isim)
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)

                        HStack(spacing: 0) {
                            statBadge(title: "YAŞ", value: detail.yas)
                            dividerLine
                            statBadge(title: "DOĞUM", value: detail.dogumTarihi)
                            dividerLine
                            statBadge(title: "HANDİKAP", value: detail.handikap.isEmpty ? "-" : detail.handikap)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.cyan.opacity(0.4), lineWidth: 1.5)
                                )
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                }
            }
            .frame(height: 180)
        }
        .frame(height: 180)
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 180)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.white.opacity(0.3))
            .frame(width: 1, height: 36)
    }

    @ViewBuilder
    private func statBadge(title: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.cyan)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Two Column Card
    @ViewBuilder
    private func twoColumnCard(detail: HorseDetailInfo) -> some View {
        HStack(alignment: .top, spacing: 0) {
            leftColumn(detail: detail)
            
            columnDivider
            
            rightColumn(detail: detail)
        }
        .padding(14)
        .background(cardBackground)
        .shadow(color: .cyan.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func leftColumn(detail: HorseDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            compactRow(label: "BABA", value: detail.baba)
            rowDivider
            compactRow(label: "ANNE", value: detail.anne)
            rowDivider
            compactRow(label: "YETİŞTİRİCİ", value: detail.yetistirici)
            rowDivider
            compactRow(label: "ANTRENÖR", value: detail.antrenor)
            rowDivider
            compactRow(label: "GERÇEK SAHİP", value: detail.gercekSahip)
            if let uzerineKosan = detail.uzerineKosanSahip, !uzerineKosan.isEmpty {
                rowDivider
                compactRow(label: "ÜZERİNE KOŞAN", value: uzerineKosan)
            }
            if let tercih = detail.tercihAciklamasi, !tercih.isEmpty {
                rowDivider
                compactRow(label: "TERCİH", value: tercih)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func rightColumn(detail: HorseDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            compactRow(label: "İKRAMİYE", value: formatCurrency(detail.ikramiye))
            rowDivider
            compactRow(label: "KAZANÇ", value: formatCurrency(detail.kazanc))
            rowDivider
            compactRow(label: "AT SAHİBİ PRİMİ", value: formatCurrency(detail.atSahibiPrimi))
            rowDivider
            compactRow(label: "YETİŞTİRİCİLİK PRİMİ", value: formatCurrency(detail.yetistiricilikPrimi))
            rowDivider
            compactRow(label: "YURTDIŞI İKRAMİYE", value: formatCurrency(detail.yurtdisiIkramiye))
            if let sponsorluk = detail.sponsorlukGeliri, !sponsorluk.isEmpty {
                rowDivider
                compactRow(label: "SPONSORLUK", value: formatCurrency(sponsorluk))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var columnDivider: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .cyan.opacity(0.3), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 1)
            .padding(.vertical, 8)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    @ViewBuilder
    private func columnHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.cyan)
            .tracking(1.5)
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func compactRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.cyan)
                .tracking(0.5)
            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats Card
    @ViewBuilder
    private func statsCard(rows: [HorseStatRow]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            statsHeaderRow
                .padding(.horizontal, 14)
                .padding(.top, 16)

            Rectangle()
                .fill(Color.cyan.opacity(0.25))
                .frame(height: 1)
                .padding(.horizontal, 14)
                .padding(.top, 6)

            statsDataRows(rows: rows)

            Spacer(minLength: 14)
        }
        .background(cardBackground)
        .shadow(color: .cyan.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func statsDataRows(rows: [HorseStatRow]) -> some View {
        ForEach(Array(rows.enumerated()), id: \.offset) { item in
            let index = item.offset
            let row = item.element
            statsDataRow(row: row, isEven: index % 2 == 0)
            if index < rows.count - 1 {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                    .padding(.horizontal, 14)
            }
        }
    }

    private var statsHeaderRow: some View {
        HStack(spacing: 0) {
            Text("KATEGORİ")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("K")
                .frame(width: 24, alignment: .center)
            Text("1.")
                .frame(width: 24, alignment: .center)
            Text("2.")
                .frame(width: 24, alignment: .center)
            Text("3.")
                .frame(width: 24, alignment: .center)
            Text("4.")
                .frame(width: 24, alignment: .center)
            Text("5.")
                .frame(width: 24, alignment: .center)
            Text("KAZANÇ")
                .frame(width: 80, alignment: .trailing)
        }
        .font(.system(size: 9, weight: .bold))
        .foregroundColor(.white.opacity(0.45))
        .tracking(0.5)
    }

    @ViewBuilder
    private func statsDataRow(row: HorseStatRow, isEven: Bool) -> some View {
        HStack(spacing: 0) {
            Text(row.kategori)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(row.kategori == "TOPLAM" ? .cyan : .white)
                .fontWeight(row.kategori == "TOPLAM" ? .bold : .medium)
            Text(row.kosu)
                .frame(width: 24, alignment: .center)
                .foregroundColor(.white.opacity(0.7))
            Text(row.birinci)
                .frame(width: 24, alignment: .center)
                .foregroundColor(row.birinci != "0" ? .orange : .white.opacity(0.5))
            Text(row.ikinci)
                .frame(width: 24, alignment: .center)
                .foregroundColor(row.ikinci != "0" ? .white.opacity(0.85) : .white.opacity(0.5))
            Text(row.ucuncu)
                .frame(width: 24, alignment: .center)
                .foregroundColor(row.ucuncu != "0" ? .white.opacity(0.85) : .white.opacity(0.5))
            Text(row.dorduncu)
                .frame(width: 24, alignment: .center)
                .foregroundColor(.white.opacity(0.4))
            Text(row.besinci)
                .frame(width: 24, alignment: .center)
                .foregroundColor(.white.opacity(0.4))
            Text(row.kazanc)
                .frame(width: 80, alignment: .trailing)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.system(size: 11, weight: .medium))
        .padding(.vertical, 7)
        .padding(.horizontal, 14)
        .background(isEven ? Color.white.opacity(0.02) : Color.clear)
    }

    // MARK: - Sort

    private var sortedHistory: [HorseRaceHistoryRow] {
        raceHistory.sorted { a, b in
            sortCompare(a, b, key: sortKey, asc: sortAscending)
        }
    }

    private func sortCompare(_ a: HorseRaceHistoryRow, _ b: HorseRaceHistoryRow,
                              key: RaceHistorySortKey, asc: Bool) -> Bool {
        func apply(_ result: Bool) -> Bool { asc ? result : !result }

        switch key {
        case .sira:
            if a.kosmazMi != b.kosmazMi { return !a.kosmazMi }
            return apply(sortNum(a.sira) < sortNum(b.sira))
        case .tarih:
            return apply(sortDate(a.tarih) < sortDate(b.tarih))
        case .sehir:
            return apply(a.sehir.localizedCompare(b.sehir) == .orderedAscending)
        case .mesafe:
            return apply(sortNum(a.mesafe) < sortNum(b.mesafe))
        case .siklet:
            return apply(sortNum(a.siklet) < sortNum(b.siklet))
        case .startNo:
            return apply(sortNum(a.startNo) < sortNum(b.startNo))
        case .derece:
            let na = sortDerece(a.derece), nb = sortDerece(b.derece)
            if na == Int.max && nb == Int.max { return false }
            if na == Int.max { return false }
            if nb == Int.max { return true }
            return apply(na < nb)
        case .jokey:
            return apply(a.jokey.localizedCompare(b.jokey) == .orderedAscending)
        case .ganyan:
            return apply(sortGanyan(a.ganyan) < sortGanyan(b.ganyan))
        case .grup:
            return apply(a.grup.localizedCompare(b.grup) == .orderedAscending)
        case .kosuNo:
            return apply(sortNum(a.kosuNo) < sortNum(b.kosuNo))
        case .kosuCins:
            return apply(a.kosuCins.localizedCompare(b.kosuCins) == .orderedAscending)
        case .taki:
            return apply(a.taki.localizedCompare(b.taki) == .orderedAscending)
        case .antrenor:
            return apply(a.antrenor.localizedCompare(b.antrenor) == .orderedAscending)
        case .sahip:
            return apply(a.sahip.localizedCompare(b.sahip) == .orderedAscending)
        case .hp:
            return apply(sortNum(a.hp) < sortNum(b.hp))
        case .ikramiye:
            return apply(sortNum(a.ikramiye.replacingOccurrences(of: ".", with: "")) < sortNum(b.ikramiye.replacingOccurrences(of: ".", with: "")))
        case .s20:
            return apply(sortNum(a.s20) < sortNum(b.s20))
        }
    }

    private func sortDate(_ s: String) -> Int {
        let p = s.split(separator: ".")
        guard p.count == 3,
              let d = Int(p[0]), let m = Int(p[1]), let y = Int(p[2]) else { return 0 }
        return y * 10000 + m * 100 + d
    }

    private func sortNum(_ s: String) -> Double {
        Double(s.trimmingCharacters(in: .whitespaces)) ?? 0
    }

    private func sortGanyan(_ s: String) -> Double {
        Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func sortDerece(_ s: String) -> Int {
        let p = s.split(separator: ".")
        if p.count == 3, let m = Int(p[0]), let sec = Int(p[1]), let cs = Int(p[2]) {
            return m * 10000 + sec * 100 + cs
        }
        if p.count == 2, let sec = Int(p[0]), let cs = Int(p[1]) {
            return sec * 100 + cs
        }
        return Int.max
    }

    @ViewBuilder
    private func sortHeader(_ title: String, key: RaceHistorySortKey,
                             width: CGFloat, align: Alignment = .center,
                             padLeading: CGFloat = 0) -> some View {
        Button {
            if sortKey == key { sortAscending.toggle() }
            else { sortKey = key; sortAscending = true }
        } label: {
            HStack(spacing: 2) {
                if padLeading > 0 { Color.clear.frame(width: padLeading) }
                if align == .trailing { Spacer(minLength: 0) }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if sortKey == key {
                    Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                        .font(.system(size: 7, weight: .bold))
                }
                if align == .leading { Spacer(minLength: 0) }
            }
            .frame(width: width)
            .foregroundColor(sortKey == key ? .cyan : .white.opacity(0.4))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Race History Card
    @ViewBuilder
    private func raceHistoryCard(rows: [HorseRaceHistoryRow]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("KOŞU GEÇMİŞİ")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.cyan)
                .tracking(1.5)
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    raceHistoryHeader
                        .padding(.leading, 14)
                        .padding(.trailing, 10)

                    Rectangle()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(height: 1)
                        .padding(.leading, 14)
                        .padding(.trailing, 10)
                        .padding(.top, 4)

                    ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                        raceHistoryRow(row: row, idx: idx, isEven: idx % 2 == 0)
                    }
                }
                .frame(minWidth: max(UIScreen.main.bounds.width - 32, 1150))
            }

            Spacer(minLength: 14)
        }
        .background(cardBackground)
        .shadow(color: .cyan.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var raceHistoryHeader: some View {
        HStack(spacing: 0) {
            sortHeader("SONUÇ",      key: .sira,     width: 56, align: .leading)
            sortHeader("TARİH",      key: .tarih,    width: 72, align: .leading, padLeading: 6)
            sortHeader("ŞEHİR",      key: .sehir,    width: 72, align: .leading)
            sortHeader("MSF",        key: .mesafe,   width: 60)
            sortHeader("SKL",        key: .siklet,   width: 42)
            sortHeader("DERECE",     key: .derece,   width: 70, align: .trailing)
            sortHeader("JOKEY",      key: .jokey,    width: 78, align: .trailing)
            sortHeader("GNY",        key: .ganyan,   width: 48, align: .trailing)
            sortHeader("GRP",        key: .grup,     width: 42)
            sortHeader("KOŞU CİNSİ", key: .kosuCins, width: 96, align: .leading, padLeading: 6)
            sortHeader("TAKI",       key: .taki,     width: 48)
            sortHeader("ANTRENÖR",   key: .antrenor, width: 84, align: .leading, padLeading: 6)
            sortHeader("SAHİP",      key: .sahip,    width: 110, align: .leading, padLeading: 6)
            sortHeader("HP",         key: .hp,       width: 38)
            sortHeader("İKRAMİYE",   key: .ikramiye, width: 88, align: .trailing)
            Text("▶").frame(width: 44, alignment: .center).foregroundColor(.white.opacity(0.4))
            Text("📷").frame(width: 44, alignment: .center).foregroundColor(.white.opacity(0.4))
        }
        .font(.system(size: 12, weight: .bold))
        .tracking(0.5)
    }

    @ViewBuilder
    private func raceHistoryRow(row: HorseRaceHistoryRow, idx: Int, isEven: Bool) -> some View {
        let dim: Double = row.kosmazMi ? 0.35 : 1.0
        HStack(spacing: 0) {
            // Sonuç — büyük sıralama rakamı
            sonucView(row.sira, kosmazMi: row.kosmazMi)
                .frame(width: 56, alignment: .leading)

            Text(shortDate(row.tarih))
                .frame(width: 72, alignment: .leading)
                .padding(.leading, 6)
                .foregroundColor(.white.opacity(0.75 * dim))

            Text(row.sehir)
                .frame(width: 72, alignment: .leading)
                .foregroundColor(.white.opacity(0.9 * dim))
                .lineLimit(1)

            // Mesafe — pist renginde arka plan
            Text(row.mesafe)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(pistColor(row.pist).opacity(row.kosmazMi ? 0.35 : 0.75))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(width: 60, alignment: .center)

            Text(row.siklet.isEmpty ? "–" : row.siklet)
                .frame(width: 42, alignment: .center)
                .foregroundColor(.white.opacity(0.65 * dim))

            Text(row.derece.isEmpty ? "–" : row.derece)
                .frame(width: 70, alignment: .trailing)
                .foregroundColor(row.derece.isEmpty ? .white.opacity(0.25) : .white.opacity(0.8 * dim))

            Text(row.kosmazMi ? "Koşmaz" : row.jokey)
                .frame(width: 78, alignment: .trailing)
                .foregroundColor(row.kosmazMi ? .white.opacity(0.3) : .cyan.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(row.ganyan.isEmpty ? "–" : row.ganyan)
                .frame(width: 48, alignment: .trailing)
                .foregroundColor(row.ganyan.isEmpty ? .white.opacity(0.25) : .orange.opacity(0.85))

            Text(row.grup.isEmpty ? "–" : row.grup)
                .frame(width: 42, alignment: .center)
                .foregroundColor(.white.opacity(0.55 * dim))

            Text(row.kosuCins.isEmpty ? "–" : row.kosuCins)
                .frame(width: 96, alignment: .leading)
                .padding(.leading, 6)
                .foregroundColor(.white.opacity(0.75 * dim))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(row.taki.isEmpty ? "–" : row.taki)
                .frame(width: 48, alignment: .center)
                .foregroundColor(.white.opacity(0.55 * dim))
                .lineLimit(1)

            Text(row.antrenor.isEmpty ? "–" : row.antrenor)
                .frame(width: 84, alignment: .leading)
                .padding(.leading, 6)
                .foregroundColor(.white.opacity(0.65 * dim))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(row.sahip.isEmpty ? "–" : row.sahip)
                .frame(width: 110, alignment: .leading)
                .padding(.leading, 6)
                .foregroundColor(.white.opacity(0.65 * dim))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(row.hp.isEmpty ? "–" : row.hp)
                .frame(width: 38, alignment: .center)
                .foregroundColor(.white.opacity(0.55 * dim))

            Text(row.ikramiye.isEmpty ? "–" : row.ikramiye)
                .frame(width: 88, alignment: .trailing)
                .foregroundColor(.white.opacity(0.65 * dim))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            // Video — CDN mp4 URL'ini çekerek açar
            if let videoPageUrl = row.videoUrl {
                Button {
                    Task {
                        loadingVideoIdx = idx
                        let cdnUrl = await HtmlParser.shared.fetchVideoUrl(from: videoPageUrl)
                        let target = cdnUrl ?? videoPageUrl   // CDN başarısız olursa TJK sayfasını aç
                        if let url = URL(string: target) {
                            await UIApplication.shared.open(url)
                        }
                        loadingVideoIdx = nil
                    }
                } label: {
                    if loadingVideoIdx == idx {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(.cyan)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.cyan.opacity(0.9))
                    }
                }
                .frame(width: 44, height: 36, alignment: .center)
                .contentShape(Rectangle())
            } else {
                Text("–")
                    .frame(width: 44, alignment: .center)
                    .foregroundColor(.white.opacity(0.2))
            }

            // Foto — doğrudan URL'i açar
            if let fotoUrl = row.fotoUrl, let url = URL(string: fotoUrl) {
                Button {
                    Task { await UIApplication.shared.open(url) }
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 19))
                        .foregroundColor(.orange.opacity(0.9))
                }
                .frame(width: 44, height: 36, alignment: .center)
                .contentShape(Rectangle())
            } else {
                Text("–")
                    .frame(width: 44, alignment: .center)
                    .foregroundColor(.white.opacity(0.2))
            }
        }
        .font(.system(size: 14, weight: .medium))
        .padding(.vertical, 9)
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .background(isEven ? Color.white.opacity(0.03) : Color.clear)
    }

    
    @ViewBuilder
    private func sonucView(_ sira: String, kosmazMi: Bool) -> some View {
        let trimmed = sira.trimmingCharacters(in: .whitespaces)
        let isPodium = ["1", "2", "3"].contains(trimmed)
        if kosmazMi {
            Text("–")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.2))
        } else if trimmed.isEmpty {
            Text("–")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.2))
        } else if isPodium {
            Text(trimmed)
                .font(.system(size: 26, weight: .black))
                .foregroundColor(.orange)
        } else {
            Text(trimmed)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white.opacity(0.75))
        }
    }

    private func pistColor(_ pist: String) -> Color {
        if pist.hasPrefix("K") { return Color(red: 0.6, green: 0.4, blue: 0.2) }
        if pist.hasPrefix("S") { return Color(red: 0.55, green: 0.55, blue: 0.55) }
        return Color(red: 0.2, green: 0.65, blue: 0.3)
    }

    private func shortDate(_ date: String) -> String {
        // "09.03.2026" → "09.03.26"
        let parts = date.split(separator: ".")
        guard parts.count == 3 else { return date }
        let year = String(parts[2].suffix(2))
        return "\(parts[0]).\(parts[1]).\(year)"
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.07))
            .frame(height: 1)
            .padding(.horizontal, 6)
    }
}

#Preview("Canlı Veri - 101209") {
    HorseDetailView(
        horseCode: "101209",
        formaURL: "https://medya-cdn.tjk.org/formaftp/101209.jpg"
    )
    .preferredColorScheme(.dark)
}
