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
    
    // YENİ: İçinde Sıra ve Yüzde yazan Oyun Tarzı Güç Barı
    @ViewBuilder
    private func agfProgressBar(sira: Int?, agf: String?, colors: [Color]) -> some View {
        let cleanString = agf?.replacingOccurrences(of: ",", with: ".") ?? "0"
        let value = Double(cleanString) ?? 0.0
        let percentage = CGFloat(min(max(value, 0), 100)) / 100.0
        let barWidth: CGFloat = 55 // İçine yazı sığması için biraz genişletildi
        let barHeight: CGFloat = 14 // İçine yazı sığması için kalınlaştırıldı
        
        ZStack(alignment: .leading) {
            // Arka Plan (Boş Bar)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.25))
            
            // Dolu Kısım (Gradient)
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                .frame(width: barWidth * percentage)
            
            // Üzerindeki Yazı (Gölgesi sayesinde dolu veya boş alanda da net okunur)
            HStack(spacing: 2) {
                Text("\(sira ?? 0).")
                    .font(.system(size: 8, weight: .bold))
                Text("%\(agf ?? "0")")
                    .font(.system(size: 8, weight: .heavy))
            }
            .foregroundColor(.white)
            .shadow(color: .black, radius: 1, x: 0.5, y: 0.5) // Yazının her zeminde okunmasını sağlar
            .padding(.leading, 4)
        }
        .frame(width: barWidth, height: barHeight)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ==========================================
            // 1. ÜST KISIM (HEADER)
            // ==========================================
            ZStack(alignment: .leading) {
                
                Color(.systemBackground)
                
                GeometryReader { geo in
                    if let formaLink = at.FORMA, let url = URL(string: formaLink) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Color(at.horseColor).opacity(0.4)
                            }
                        }
                        .frame(width: geo.size.width * 0.55, height: 38)
                        .mask(
                            LinearGradient(gradient: Gradient(stops: [
                                .init(color: .black, location: 0.7),
                                .init(color: .clear, location: 1.0)
                            ]), startPoint: .leading, endPoint: .trailing)
                        )
                        .clipped()
                    }
                }
                
                GeometryReader { geo in
                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: geo.size.width * 0.4)
                }
                
                // İÇERİK
                HStack(alignment: .center, spacing: 0) {
                    
                    // --- SOL TARAF ---
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
                        
                        if let ekuri = at.EKURI, ekuri != "false" {
                            AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/e\(ekuri).gif")) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().scaledToFit().frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                    .padding(.leading, 4)
                    
                    Spacer(minLength: 10)
                    
                    // --- SAĞ TARAF ---
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
            
            // ==========================================
            // 2. ALT KISIM (BODY): DETAYLAR
            // ==========================================
            VStack(alignment: .leading, spacing: 5) {
                
                HStack(spacing: 4) {
                    Text("\(at.YAS ?? "")")
                    Text("•")
                    Text(String(format: "%.1f", at.KILO ?? 0) + "kg")
                    if let taki = at.TAKI, !taki.isEmpty {
                        Text("•")
                        Text(taki).fontWeight(.semibold).foregroundColor(.green)
                    }
                }
                .font(.system(size: 9.5))
                .foregroundColor(.secondary)
                
                Text("\(at.BABA ?? "") / \(at.ANNE ?? "")")
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("HP: \(at.HANDIKAP ?? "")")
                    Text("KGS: \(at.KGS ?? "")")
                    Spacer()
                    Text(at.ANTRENORADI ?? "")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .font(.system(size: 10))
                .foregroundColor(.primary)
                
                // YENİ: AGF 1 ve AGF 2 Güç Barları yan yana
                HStack(spacing: 6) {
                    
                    if let agf1 = at.AGF1, !agf1.isEmpty {
                        agfProgressBar(sira: at.AGFSIRA1, agf: agf1, colors: [.cyan, .blue])
                    }
                    
                    // Eğer AGF2 adında bir değişkenin varsa onu da turuncu bir güç barıyla çizdirecek
                    if let agf2 = at.AGF2, !agf2.isEmpty {
                        agfProgressBar(sira: at.AGFSIRA2, agf: agf2, colors: [.cyan, .blue])
                    }
                    
                    Spacer()
                    
                    Text(at.SAHIPADI ?? "")
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
        YAS: "4y d a",
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
        EKURI: "false",
        TAKI: "KG K GKR",
        AGF1: "55,50",
        AGFSIRA1: 1,
        AGF2: "18,20", // İkinci barı görmek için eklendi (Modeline eklemeyi unutma)
        AGFSIRA2: 2,   // İkinci barın sırası
        SON6: "C1K2S3K4C1"
    )
    
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ListItemView(at: ornekAt)
            .padding()
    }
}

