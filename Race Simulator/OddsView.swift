import SwiftUI

// MARK: - Main View

struct OddsView: View {

    private let separatorWidth: CGFloat = 1.0

    @State private var viewModel: OddsViewModel

    init(selectedDate: Date, initialTab: Int = 0) {
        _viewModel = State(initialValue: OddsViewModel(selectedDate: selectedDate, initialTab: initialTab))
    }

    var body: some View {
        VStack(spacing: 0) {
            citySelectionBar

            if viewModel.isLoading && viewModel.cities.isEmpty {
                loadingView
            } else if viewModel.cities.isEmpty {
                emptyStateView(message: "Seçilen tarih için henüz muhtemeller yayınlanmamıştır.")
            } else {
                runSelectionBar
                tabSelectionBar
                Spacer()
                statusInfoBar.padding(.horizontal, 8)
                dynamicTableHeader.padding(.horizontal, 8)
                dynamicMainList.padding(.horizontal, 8)
            }
        }
        .background(Color(white: 0.12))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadInitialData()
        }
        .onDisappear { viewModel.stopRefreshTimer() }
        .onChange(of: viewModel.selectedTab) { _, _ in viewModel.manageRefreshTimer() }
    }
}

// MARK: - View Components

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

    private var citySelectionBar: some View {
        HStack {
            Menu {
                ForEach(viewModel.cities, id: \.self) { city in
                    Button {
                        viewModel.selectedCity = city
                        viewModel.selectedRun = 1
                        viewModel.fetchRaceDetails()
                    } label: {
                        Label(
                            city,
                            systemImage: city == viewModel.selectedCity ? "mappin.circle.fill" : "mappin.circle"
                        )
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.cyan)
                    Text((viewModel.selectedCity ?? "Şehir Seçin").turkishCityUppercased)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            }
            Spacer()
            Text(viewModel.turkishDateString)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal)
        .frame(height: 55)
        .background(Color(white: 0.12))
    }

    private var tabSelectionBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Muhtemeller", index: 0)
            tabButton(title: "AGF", index: 1)
        }
        .background(Color.black)
        .overlay(Divider(), alignment: .bottom)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button { viewModel.selectedTab = index } label: {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(viewModel.selectedTab == index ? .orange : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(white: 0.12))
                .overlay(
                    Rectangle()
                        .fill(viewModel.selectedTab == index ? Color.orange : Color.clear)
                        .frame(height: 3),
                    alignment: .bottom
                )
        }
        .buttonStyle(.plain)
    }

    private var runSelectionBar: some View {
        let city = viewModel.selectedCity ?? ""
        let matchingKeys = viewModel.runsData.keys.filter { $0.hasPrefix(city) }.sorted { a, b in
            let numA = Int(a.components(separatedBy: "-").last ?? "0") ?? 0
            let numB = Int(b.components(separatedBy: "-").last ?? "0") ?? 0
            return numA < numB
        }

        return HStack(spacing: 4) {
            ForEach(0..<matchingKeys.count, id: \.self) { index in
                let kosuNo = "\(index + 1)"
                Button {
                    viewModel.selectedRun = index + 1
                    viewModel.fetchRaceDetails()
                } label: {
                    Text(kosuNo)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(viewModel.selectedRun == (index + 1) ? .black : .white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(viewModel.selectedRun == (index + 1) ? Color.orange : Color.white.opacity(0.12))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(white: 0.12))
    }

    private var statusInfoBar: some View {
        HStack {
            Label(viewModel.raceTime, systemImage: "clock.fill")
            Spacer()
            Text(viewModel.raceInfo)
        }
        .lineLimit(1)
        .font(.footnote).bold()
        .padding(.horizontal)
        .frame(height: 35)
        .background(Color(white: 0.9))
        .foregroundColor(.black)
    }

    private var dynamicTableHeader: some View {
        let headers = viewModel.selectedTab == 0 ? viewModel.currentBahisTurleri : viewModel.agfBahisTurleri
        let rows = viewModel.selectedTab == 0 ? viewModel.tableRows : viewModel.agfTableRows

        return Group {
            if !rows.isEmpty {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ForEach(0..<headers.count, id: \.self) { index in
                            HStack {
                                Spacer()
                                Text(headers[index])
                                    .font(.system(size: 11, weight: .bold))
                                Spacer()
                            }
                            .frame(width: columnWidth(for: index, totalWidth: geometry.size.width))

                            if index < headers.count - 1 {
                                Rectangle().fill(Color.gray.opacity(0.3)).frame(width: separatorWidth)
                            }
                        }
                    }
                }
                .frame(height: 35)
                .background(Color.white)
                .overlay(Divider(), alignment: .bottom)
            }
        }
    }

    private var dynamicMainList: some View {
        let rows = viewModel.selectedTab == 0 ? viewModel.tableRows : viewModel.agfTableRows

        return ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        if rows.isEmpty && !viewModel.isLoading {
                            emptyStateView(message: "\(viewModel.selectedTab == 0 ? "Muhtemeller" : "AGF") verisi henüz yayınlanmamıştır.")
                        } else {
                            tableContent(for: rows, totalWidth: geometry.size.width)
                        }
                    }
                }
            }
            if viewModel.isLoading && !rows.isEmpty {
                Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)
                ProgressView().tint(.orange)
            }
        }
    }

    private var loadingView: some View {
        ProgressView().padding(.top, 100).tint(.orange)
    }

    private func tableContent(for rows: [DynamicTableRow], totalWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                rowView(for: row, totalWidth: totalWidth)
            }
            Color.clear.frame(height: 60)
        }
    }

    private func rowView(for row: DynamicTableRow, totalWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<row.cells.count, id: \.self) { index in
                cellView(for: row, at: index, totalWidth: totalWidth)

                if index < row.cells.count - 1 {
                    let currentEmpty = row.cells[index].label.isEmpty && row.cells[index].odds.isEmpty
                    if !currentEmpty {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: separatorWidth)
                    }
                }
            }
        }
    }

    private func columnWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        let headers = viewModel.selectedTab == 0 ? viewModel.currentBahisTurleri : viewModel.agfBahisTurleri
        guard !headers.isEmpty else { return 0 }

        let totalSeparatorWidth = separatorWidth * CGFloat(max(0, headers.count - 1))
        let contentWidth = totalWidth - totalSeparatorWidth
        guard contentWidth > 0 else { return 0 }

        if viewModel.selectedTab == 1 {
            let firstColumnWidth: CGFloat = 40
            guard contentWidth > firstColumnWidth else {
                return contentWidth / CGFloat(headers.count)
            }
            let remainingWidth = contentWidth - firstColumnWidth
            switch index {
            case 0: return firstColumnWidth
            case 1: return remainingWidth * 0.40
            case 2: return remainingWidth * 0.35
            case 3: return remainingWidth * 0.25
            default: return 0
            }
        }

        return contentWidth / CGFloat(headers.count)
    }

    private func cellView(for row: DynamicTableRow, at index: Int, totalWidth: CGFloat) -> some View {
        let cell = row.cells[index]
        let isEmpty = cell.label.isEmpty && cell.odds.isEmpty
        let headers = viewModel.selectedTab == 0 ? viewModel.currentBahisTurleri : viewModel.agfBahisTurleri

        let isGanyanColumn = index < headers.count && headers[index].uppercased().contains("GANYAN")
        let isAGFColumn = viewModel.selectedTab == 1 && index == 3
        let isAGFAtColumn = viewModel.selectedTab == 1 && index == 1
        let isAGFJokeyColumn = viewModel.selectedTab == 1 && index == 2
        let shouldShowAsFavori = row.isFavori && (isGanyanColumn || isAGFColumn) && !row.isKosmaz
        let isKosmazCell = row.isKosmaz && (isGanyanColumn || viewModel.selectedTab == 1)

        @ViewBuilder
        var cellContent: some View {
            if isAGFColumn {
                if isKosmazCell {
                    Text("Koşmaz")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                } else {
                    VStack(spacing: 2) {
                        let hasAGF2 = !cell.odds.isEmpty
                        if !cell.label.isEmpty {
                            Text(cell.label)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(shouldShowAsFavori ? .green : .primary)
                                .modifier(PulseModifier(active: shouldShowAsFavori && !hasAGF2))
                        }
                        if hasAGF2 {
                            Text(cell.odds)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(shouldShowAsFavori ? .green : .primary)
                                .modifier(PulseModifier(active: shouldShowAsFavori))
                        }
                    }
                }
            } else {
                HStack(spacing: 2) {
                    let labelText = Text(cell.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(shouldShowAsFavori ? .green : (isKosmazCell ? .black : .primary))

                    if isAGFJokeyColumn {
                        labelText.lineLimit(1).truncationMode(.tail)
                    } else {
                        labelText.lineLimit(1).minimumScaleFactor(0.7)
                    }

                    if (isGanyanColumn || isAGFAtColumn) && !row.ekuriGrubu.isEmpty {
                        ekuriIcon(for: row.ekuriGrubu)
                    }

                    if viewModel.selectedTab == 0 { Spacer(minLength: 2) }

                    if isKosmazCell && isGanyanColumn {
                        Text("Koşmaz")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                    } else {
                        Text(cell.odds)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(shouldShowAsFavori ? .green : (isKosmazCell ? .black : .primary))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .modifier(PulseModifier(active: shouldShowAsFavori))
                    }
                }
            }
        }

        return VStack(spacing: 0) {
            if !isEmpty {
                HStack {
                    if viewModel.selectedTab == 1 { Spacer(minLength: 0) }
                    cellContent
                    if viewModel.selectedTab == 1 { Spacer(minLength: 0) }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
                .frame(minHeight: 48)

                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1.5)
            } else {
                Color.clear
            }
        }
        .frame(width: columnWidth(for: index, totalWidth: totalWidth))
        .background(isEmpty ? Color.clear : (isKosmazCell ? Color.gray.opacity(0.6) : Color.white))
    }

    private func ekuriIcon(for ekuri: String) -> some View {
        AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/\(ekuri).gif")) { phase in
            if let image = phase.image { image.resizable().scaledToFit() } else { Color.clear }
        }
        .frame(width: 14, height: 14)
    }
}

#Preview {
    NavigationStack {
        OddsView(selectedDate: Date())
            .preferredColorScheme(.dark)
    }
}
