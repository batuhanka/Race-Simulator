import SwiftUI

// MARK: - Main View

struct TicketView: View {

    let themePrimary = Color.cyan
    let themeAccent = Color.orange

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TicketViewModel

    private var pistColors: [Color] {
        let pist = (viewModel.selectedRace?.PIST ?? "").lowercased(with: Locale(identifier: "tr_TR"))
        if pist.contains("çim") || pist.contains("cim") {
            return [Color.green.opacity(0.3), Color.green.opacity(0.9)]
        } else if pist.contains("kum") {
            return [Color.brown.opacity(0.3), Color.brown.opacity(0.9)]
        } else if pist.contains("sentetik") {
            return [Color.gray.opacity(0.3), Color.gray.opacity(0.9)]
        } else {
            return [Color.gray.opacity(0.3), Color.black.opacity(0.9)]
        }
    }

    init(initialSelections: [String: Set<String>]? = nil,
         initialDay: BetRaceDay? = nil,
         initialBet: BetType? = nil,
         initialDays: [BetRaceDay]? = nil) {
        _viewModel = State(initialValue: TicketViewModel(
            initialSelections: initialSelections,
            initialDay: initialDay,
            initialBet: initialBet,
            initialDays: initialDays
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                topBar
                ProgressView("Bahis bilgileri yükleniyor...").padding()
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                topBar
                ContentUnavailableView("Hata", systemImage: "xmark.octagon", description: Text(errorMessage))
            } else {
                mainContent()
            }
        }
        .preferredColorScheme(.dark)
        .background(
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    gradient: Gradient(colors: [
                        pistColors.last?.opacity(0.45) ?? .black,
                        Color.black.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: viewModel.selectedRace?.KOD)
            }
        )
        .navigationBarHidden(true)
        .task { await viewModel.loadBettingData() }
        .onChange(of: viewModel.selectedRaceDay) { _, newValue in viewModel.onRaceDayChanged(to: newValue) }
        .onChange(of: viewModel.selectedBetType) { _, newValue in viewModel.onBetTypeChanged(to: newValue) }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 2) {
                Text("TAY")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white.opacity(0.4))
                Text("ZEKA")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.cyan.opacity(0.9))
            }

            Spacer()

            Image("tayzekatransparent")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 70, height: 70)
        }
        .padding(.horizontal)
        .frame(height: 56)
    }

    @ViewBuilder
    private func mainContent() -> some View {
        VStack(spacing: 0) {
            topBar
            headerPickersView()
            raceLegsView()
            if let race = viewModel.selectedRace, let info = race.BILGI, !info.isEmpty {
                HStack(alignment: .center, spacing: 10) {
                    Text(info)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Label(race.SAAT, systemImage: "clock.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 8).padding(.vertical, 8)
            }
            HStack(alignment: .top, spacing: 8) {
                ScrollView {
                    if let race = viewModel.selectedRace {
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
}

// MARK: - View Components

extension TicketView {

    @ViewBuilder
    private func headerPickersView() -> some View {
        @Bindable var vm = viewModel
        HStack(spacing: 0) {
            Menu {
                Picker("Hipodrom", selection: $vm.selectedRaceDay) {
                    ForEach(vm.raceDays) { day in
                        Text(vm.formattedRaceDayTitle(for: day)).tag(day as BetRaceDay?)
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HİPODROM")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(themePrimary.opacity(0.8))
                        Text(vm.formattedRaceDayTitle(for: vm.selectedRaceDay))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 25)

            Menu {
                Picker("Bahis Türü", selection: $vm.selectedBetType) {
                    ForEach(vm.ganyanBetTypes) { type in
                        Text(vm.betTypeLabel(for: type)).tag(type as BetType?)
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BAHİS TÜRÜ")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(themePrimary.opacity(0.8))
                        Text(vm.selectedBetType.map { vm.betTypeLabel(for: $0) } ?? "")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .padding(.horizontal, 8).padding(.top, 8)
    }

    @ViewBuilder
    private func raceLegsView() -> some View {
        if let raceDay = viewModel.selectedRaceDay, let betType = viewModel.selectedBetType {
            let races = viewModel.filteredRaces(for: raceDay, betType: betType)
            if !races.isEmpty {
                let visibleCount: CGFloat = 6
                let hPadding: CGFloat = 8
                let itemSpacing: CGFloat = 8
                let itemSize = (UIScreen.main.bounds.width - (hPadding * 2) - (itemSpacing * (visibleCount - 1))) / visibleCount

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: itemSpacing) {
                        ForEach(races) { race in
                            Button { viewModel.selectedRace = race } label: {
                                let count = viewModel.selectedHorses[race.KOD]?.count ?? 0
                                let isCurrentRace = viewModel.selectedRace?.KOD == race.KOD
                                ZStack {
                                    Triangle(corner: .bottomLeft)
                                        .fill(isCurrentRace
                                            ? (pistColors.last ?? themePrimary).opacity(0.5)
                                            : Color.gray.opacity(0.2))
                                    Triangle(corner: .topRight)
                                        .fill(count > 0 ? themeAccent.opacity(0.9) : Color.gray.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isCurrentRace ? (pistColors.last ?? themePrimary) : Color.gray.opacity(0.3),
                                                lineWidth: isCurrentRace ? 2 : 1)
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Text("\(count) at")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(count > 0 ? .white : .secondary.opacity(0.5))
                                        }
                                        Spacer()
                                        HStack {
                                            Text("\(race.NO). Koşu")
                                                .font(.system(size: 11, weight: .black))
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                    }
                                    .padding(4)
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
    }

    @ViewBuilder
    private func horseListView(race: BetRace) -> some View {
        VStack(spacing: 0) {
            if let horses = race.atlar {
                Button { viewModel.toggleAllHorses(in: race) } label: {
                    HStack {
                        Text("HEPSİ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: viewModel.isAllSelected(in: race) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.isAllSelected(in: race) ? themePrimary : .secondary)
                            .font(.system(size: 18))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    .padding(.horizontal, 4).padding(.bottom, 6)
                }
                .buttonStyle(.plain)

                LazyVStack(spacing: 4) {
                    ForEach(horses) { horse in
                        HorseRow(
                            horse: horse,
                            isSelected: viewModel.selectedHorses[race.KOD]?.contains(horse.KOD) ?? false
                        ) {
                            viewModel.toggleHorseSelection(raceId: race.KOD, horseKod: horse.KOD)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func sideBettingPanel() -> some View {
        VStack(spacing: 12) {
            Text("KUPON")
                .font(.subheadline.bold())
                .padding(.top, 10)
                .foregroundColor(themePrimary)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    let legSelections = viewModel.getLegSelections()
                    ForEach(0..<legSelections.count, id: \.self) { index in
                        Text(legSelections[index])
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.cyan.opacity(0.9))
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 6)
            }
            Divider()
            HStack(alignment: .top, spacing: 2) {
                Text("Misli:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    
                Spacer()
                
                    Button { if viewModel.multiplier > 1 { viewModel.multiplier -= 1 } } label: {
                        Image(systemName: "minus.square.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    Text("\(viewModel.multiplier)")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 20)
                    Button { if viewModel.multiplier < 99 { viewModel.multiplier += 1 } } label: {
                        Image(systemName: "plus.square.fill")
                            .foregroundColor(themePrimary)
                            .font(.system(size: 16))
                    }
                
            }
            .padding(.horizontal)
            

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bahis Oranı").font(.system(size: 14)).foregroundColor(.secondary)
                    Text("\(viewModel.calculateBetCombinations())")
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Tutar").font(.system(size: 14)).foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", viewModel.calculateTotalBetAmount())) ₺")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeAccent)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Subcomponents

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
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: geo.size.width * 0.4, height: geo.size.height)
                        .mask(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black, location: 0.3),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .leading, endPoint: .trailing
                        ))
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
                        HStack(spacing: 4) {
                            Text(horse.AD)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .shadow(radius: 1)
                            if let ekuri = horse.EKURI, !ekuri.isEmpty, ekuri != "0", ekuri != "false" {
                                AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/e\(ekuri).gif")) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFit().frame(width: 18, height: 18)
                                    }
                                }
                                .frame(width: 18, height: 18)
                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                            }
                        }
                        Text(horse.JOKEYADI ?? "")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        if let agf2 = horse.AGF2, agf2 > 0 {
                            Text("%\(Int(agf2))")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        if let agf1 = horse.AGF1, agf1 > 0 {
                            Text("%\(Int(agf1))")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(themeAccent)
                        }
                    }
                    .padding(.trailing, isSelected ? 4 : 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(themePrimary)
                            .font(.system(size: 16))
                    }
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
        TicketView(initialDay: MockData.raceDayAnkara, initialBet: MockData.ganyan6)
    }
}

#Preview("Yükleniyor") {
    TicketView()
}
