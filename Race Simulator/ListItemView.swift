//
//  ListItemView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//

//
//  ListItemView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//

import SwiftUI

// Son yarış derecesini renklendiren yardımcı fonksiyon
private func parseSonYaris(_ veri: String) -> some View {
    let pistChar = veri.first ?? " "
    let derece = String(veri.dropFirst())

    var color: Color = .secondary

    switch pistChar {
    case "K": color = .brown   // Kum pist
    case "C": color = .green   // Çim pist
    case "S": color = .gray    // Sentetik
    default:  color = .secondary
    }

    return Text(derece)
        .font(.system(size: 8, weight: .bold))
        .foregroundColor(.white)
        .frame(minWidth: 6)
        .padding(.horizontal, 2)
        .padding(.vertical, 1)
        .background(color)
        .cornerRadius(3)
}

struct ListItemView: View {
    let at: Horse
    /// Sola kaydırma ile açılan aksiyon butonu için callback.
    /// `nil` ise swipe devre dışı.
    var onSwipeAction: (() -> Void)? = nil

    @State private var dragOffset: CGFloat = 0

    private let actionButtonWidth: CGFloat = 76

    // MARK: - AGF Progress Bar
    @ViewBuilder
    private func agfProgressBar(sira: Int?, agf: String?, colors: [Color]) -> some View {
        let cleanString = agf?.replacingOccurrences(of: ",", with: ".") ?? "0"
        let value = Double(cleanString) ?? 0.0
        let percentage = CGFloat(min(max(value, 0), 100)) / 100.0
        let barWidth: CGFloat = 55
        let barHeight: CGFloat = 14

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.6))

            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                .frame(width: barWidth * percentage)

            HStack(spacing: 2) {
                Text("\(sira ?? 0).")
                    .font(.system(size: 8, weight: .heavy))
                Text("%\(agf ?? "0")")
                    .font(.system(size: 8, weight: .heavy))
            }
            .foregroundColor(.white)
            .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
            .padding(.leading, 4)
        }
        .frame(width: barWidth, height: barHeight)
    }

    // MARK: - Swipe Action Button
    private var swipeActionButton: some View {
        Button {
            onSwipeAction?()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                dragOffset = 0
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("ANALİZ")
                    .font(.system(size: 10, weight: .bold))
                    .kerning(0.5)
            }
            .foregroundColor(.white)
            .frame(width: actionButtonWidth)
            .frame(maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.cyan.opacity(0.85), Color.blue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            // Sadece sağ köşeler yuvarlanır — kartın sağ kenarına yapışık dikdörtgen görünüm
            .clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Drag Gesture
    private var swipeDragGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .local)
            .onChanged { value in
                guard onSwipeAction != nil else { return }
                let tx = value.translation.width
                if tx < 0 {
                    // Sola kayma: buton genişliği kadar sınırla
                    dragOffset = max(tx, -actionButtonWidth)
                } else if dragOffset < 0 {
                    // Geri kaydırma
                    dragOffset = min(0, dragOffset + tx)
                }
            }
            .onEnded { value in
                guard onSwipeAction != nil else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    if -dragOffset > actionButtonWidth * 0.45 {
                        dragOffset = -actionButtonWidth
                    } else {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .trailing) {

            // Swipe butonu: kartın arkasında, sağa yaslanmış.
            // Kart sola kaydıkça ortaya çıkar.
            if onSwipeAction != nil {
                swipeActionButton
            }

            // ==========================================
            // KART İÇERİĞİ
            // ==========================================
            VStack(spacing: 0) {

                // 1. ÜST KISIM (HEADER)
                ZStack(alignment: .leading) {

                    Color(.systemBackground)

                    GeometryReader { geo in
                        if let formaLink = at.FORMA, let url = URL(string: formaLink) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else {
                                    at.coatTheme.bg.opacity(0.4)
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

                    HStack(alignment: .center, spacing: 0) {
                        Text(at.NO ?? "0")
                            .font(.system(size: 20, weight: .heavy))
                            .italic()
                            .foregroundColor(.white)
                            .frame(width: 32, alignment: .center)
                            .minimumScaleFactor(0.6)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                            .padding(.leading, 6)

                        HStack(spacing: 4) {
                            Text(at.AD ?? "")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(at.KOSMAZ == true ? .red : .white)
                                .strikethrough(at.KOSMAZ == true, color: .red)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                                .lineLimit(1)

                            let cleanEkuri = at.EKURI?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            if !cleanEkuri.isEmpty && cleanEkuri != "false" && cleanEkuri != "0" {
                                AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/e\(cleanEkuri).gif")) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFit()
                                    } else {
                                        Color.clear
                                    }
                                }
                                .frame(width: 16, height: 16)
                            }
                        }
                        .padding(.leading, 4)

                        Spacer(minLength: 10)

                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                if at.APRANTIFLG == true {
                                    Text("AP")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.red)
                                }
                                Text(at.JOKEYADI ?? "")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }

                            if let son6 = at.SON6, son6.count >= 2 {
                                HStack(spacing: 1) {
                                    let yarislarda = stride(from: 0, to: son6.count, by: 2).compactMap { i -> String? in
                                        let startIndex = son6.index(son6.startIndex, offsetBy: i)
                                        guard let endIndex = son6.index(startIndex, offsetBy: 2, limitedBy: son6.endIndex) else { return nil }
                                        return String(son6[startIndex..<endIndex])
                                    }
                                    ForEach(yarislarda, id: \.self) { yaris in
                                        parseSonYaris(yaris)
                                    }
                                }
                            } else if let son6 = at.SON6, !son6.isEmpty {
                                Text(son6)
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.trailing, 8)
                    }
                }
                .frame(height: 38)
                .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 8))

                // 2. ALT KISIM (BODY)
                VStack(alignment: .leading, spacing: 5) {

                    HStack(spacing: 4) {
                        let coatTheme = at.coatTheme
                        Text("\(at.YAS ?? "")")
                            .font(.system(size: 9.5, weight: coatTheme.bg == .clear ? .regular : .semibold))
                            .foregroundColor(coatTheme.fg)
                            .padding(.horizontal, coatTheme.bg == .clear ? 0 : 4)
                            .padding(.vertical, coatTheme.bg == .clear ? 0 : 2)
                            .background(coatTheme.bg)
                            .cornerRadius(3)

                        Text("•").foregroundColor(.secondary)

                        Text(String(format: "%.1f", at.KILO ?? 0) + "kg")
                            .foregroundColor(.secondary)

                        if let taki = at.TAKI, !taki.isEmpty {
                            Text("•").foregroundColor(.secondary)
                            Text(taki).fontWeight(.semibold).foregroundColor(.green)
                        }
                    }
                    .font(.system(size: 9.5))

                    Text("\(at.BABA ?? "") / \(at.ANNE ?? "")")
                        .font(.system(size: 9.5))
                        .foregroundColor(.secondary)

                    HStack {
                        Text("HP: \(at.HANDIKAP ?? "")")
                        Text("KGS: \(at.KGS ?? "")")
                        Spacer()
                        Text(at.SAHIPADI ?? "")
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        if let agf1 = at.AGF1, !agf1.isEmpty {
                            agfProgressBar(sira: at.AGFSIRA1, agf: agf1, colors: [.cyan, .blue])
                        }
                        if let agf2 = at.AGF2, !agf2.isEmpty {
                            agfProgressBar(sira: at.AGFSIRA2, agf: agf2, colors: [.cyan, .blue])
                        }
                        Spacer()
                        Text("Ant: \(at.ANTRENORADI ?? "")")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(CustomCorners(corners: [.bottomLeft, .bottomRight], radius: 8))
            }
            .opacity(at.KOSMAZ == true ? 0.5 : 1.0)
            .offset(x: dragOffset)
            .gesture(swipeDragGesture)
        }
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
    }
}

// MARK: - KÖŞE YUVARLATMA YARDIMCISI
struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - PREVIEW
#Preview {
    let ornekAt = Horse(
        KOD: "123",
        NO: "4",
        AD: "BOLD PILOT",
        YAS: "2y y a",
        KILO: 58.0,
        BABA: "PERSIAN BOLD",
        ANNE: "ROSA D'OR",
        JOKEYADI: "H. KARATAŞ",
        SAHIPADI: "ÖZDEMİR ATMAN",
        ANTRENORADI: "S. MUTLU",
        HANDIKAP: "120",
        KGS: "21",
        FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg",
        KOSMAZ: false,
        APRANTIFLG: false,
        EKURI: "1",
        TAKI: "KG K GKR",
        AGF1: "55,50",
        AGFSIRA1: 1,
        AGF2: "18,20",
        AGFSIRA2: 2,
        SON6: "C1K2S3K4C1"
    )

    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ListItemView(at: ornekAt, onSwipeAction: { print("ANALİZ tapped") })
            .padding()
    }
}
