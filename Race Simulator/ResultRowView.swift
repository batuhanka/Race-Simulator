import SwiftUI

struct ResultRowView: View {
    let finisher: HorseResult
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ==========================================
            // 1. ÜST KISIM (HEADER)
            // ==========================================
            ZStack(alignment: .leading) {
                
                Color(.systemBackground)
                
                // FORMA ALANI
                GeometryReader { geo in
                    AsyncImage(url: URL(string: finisher.FORMA ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            // HorseResult'ta horseColor olmadığı için varsayılan bir renk kullanıldı
                            Color.gray.opacity(0.4)
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
                
                // Siyah Gradient
                GeometryReader { geo in
                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: geo.size.width * 0.30)
                }
                
                // İÇERİK
                HStack(alignment: .center, spacing: 0) {
                    
                    // --- SOL TARAF ---
                    // Sonuç sırası gösterilir
                    Text(finisher.SONUC ?? (finisher.NO ?? "0"))
                        .font(.system(size: 20, weight: .heavy))
                        .italic()
                        .foregroundColor(.white)
                        .frame(width: 32, alignment: .center)
                        .minimumScaleFactor(0.6)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                        .padding(.leading, 6)
                    
                    HStack(spacing: 4) {
                        Text(finisher.AD ?? "")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(finisher.KOSMAZ == true ? .red : .white)
                            .strikethrough(finisher.KOSMAZ == true, color: .red)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                            .lineLimit(1)
                        
                        // Ekuri GIF
                        let cleanEkuri = finisher.EKURI?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
                    
                    // --- SAĞ TARAF ---
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            if finisher.APRANTIFLG == true {
                                Text("AP")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            Text(finisher.JOKEYADI ?? "")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        
                        
                    }
                    .padding(.trailing, 8)
                }
            }
            .frame(height: 38)
            .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 8))
            
            // ==========================================
            // 2. ALT KISIM (BODY): SONUÇ DETAYLARI
            // ==========================================
            VStack(alignment: .leading, spacing: 5) {
                
                HStack(spacing: 4) {
                    let coatTheme = finisher.coatTheme
                    Text("\(finisher.YAS ?? "")")
                        .font(.system(size: 9.5, weight: coatTheme.bg == .clear ? .regular : .semibold))
                        .foregroundColor(coatTheme.fg)
                        .padding(.horizontal, coatTheme.bg == .clear ? 0 : 4)
                        .padding(.vertical, coatTheme.bg == .clear ? 0 : 2)
                        .background(coatTheme.bg)
                        .cornerRadius(3)
                    
                    Text("•").foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f", finisher.KILO ?? 0) + "kg")
                        .foregroundColor(.secondary)
                    
                    if let taki = finisher.TAKI, !taki.isEmpty {
                        Text("•").foregroundColor(.secondary)
                        Text(taki).fontWeight(.semibold).foregroundColor(.green)
                    }
                    Spacer()
                    // GANYAN
                    if let ganyan = finisher.GANYAN, ganyan != "0", !ganyan.isEmpty {
                        Text("G: \(ganyan)")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(3)
                    }
                }
                .font(.system(size: 9.5))
                
                
                HStack(spacing: 4) {
                    
                    VStack(alignment: .leading) {
                       Text(finisher.SAHIPADI ?? "")
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .fontWeight(.bold)
                        
                        Text("Ant: \(finisher.ANTRENORADI ?? "")")
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    if let fark = finisher.FARK, !fark.isEmpty {
                        Text(fark)
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.12))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    
                    Text(finisher.DERECE ?? "")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.12))
                        .foregroundColor(.cyan)
                        .cornerRadius(4)
                }
            }
            .padding(8)
            .background(Color(.systemBackground))
            .clipShape(CustomCorners(corners: [.bottomLeft, .bottomRight], radius: 8))
            
        }
        .opacity(finisher.KOSMAZ == true ? 0.5 : 1.0)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 4) {
            // 1. Örnek: Kazanan (Ganyan ve Fark belirgin)
            ResultRowView(finisher: .mock(
                no: "3",
                sonuc: "1", // Sonuç sırasını ekliyoruz
                ad: "GÜLŞAH SULTAN",
                jokey: "G.KOCAKAYA",
                derece: "1.24.45",
                ganyan: "2.45",
                kilo: 58,
                start: "5",
                fark: "2 Boy",
                taki: "KG DB SK"
            ))
            
            // 2. Örnek: Plase (Yakın ara bitiriş)
            ResultRowView(finisher: .mock(
                no: "1",
                sonuc: "2",
                ad: "DEMİR KIRBAÇ",
                jokey: "H.KARATAŞ",
                derece: "1.24.80",
                ganyan: "4.15",
                kilo: 56.5,
                start: "1",
                fark: "Burun",
                taki: "K"
            ))
            
            // 3. Örnek: Derecesiz/Düşük Ganyanlı
            ResultRowView(finisher: .mock(
                no: "12",
                sonuc: "3",
                ad: "RÜZGARIN OĞLU",
                jokey: "M.KAYA",
                derece: "1.26.12",
                ganyan: "15.20",
                kilo: 54,
                start: "10",
                fark: "Uzak",
                taki: "DB"
            ))
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

// MARK: - Mock Helper
extension HorseResult {
    static func mock(
        no: String = "1",
        sonuc: String = "1", // Mock verisine `sonuc` eklendi
        ad: String = "HORSE NAME",
        jokey: String = "JOCKEY",
        derece: String = "1",
        ganyan: String = "10.50",
        kilo: Double = 55.0,
        start: String = "10:00",
        fark: String = "0",
        taki: String = "TAKİ"
    ) -> HorseResult {
        HorseResult(
            KEY: UUID().uuidString,
            AD: ad,
            NO: no,
            JOKEYADI: jokey,
            SONUC: sonuc, // `SONUC` parametresi atandı
            YAS: "4y d a",
            DERECE: derece,
            GANYAN: ganyan,
            FARK: fark,
            KILO: kilo,
            START: start,
            ANTRENORADI: "M.AKSOY",
            SAHIPADI: "ALİ VELİ",
            FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg",
            TAKI: taki,
            KOSMAZ: false,
            APRANTIFLG: true,
            EKURI:"1"
        )
    }
}
