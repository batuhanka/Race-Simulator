import SwiftUI

struct ResultRowView: View {
    let finisher: HorseResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // ÜST SATIR: No, Forma, At Adı ve Jokey/Derece
            HStack(alignment: .center, spacing: 4) {
                
                // At Numarası
                Text(finisher.NO ?? "")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                    //.frame(width: 35) // Numaraların hizalı durması için sabitleyebiliriz
                
                // Forma
                jerseyImage
                
                // At ve Jokey Bilgisi
                VStack(alignment: .leading, spacing: 2) {
                    Text(finisher.AD ?? "")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(finisher.JOKEYADI ?? "-")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Sağ Taraf: Derece ve Ganyan
                VStack(alignment: .trailing, spacing: 2) {
                    Text(finisher.DERECE ?? "-")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    
                    if let ganyan = finisher.GANYAN, ganyan != "0", !ganyan.isEmpty {
                        Text("\(ganyan) TL")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Divider().opacity(0.3)
            
            // ALT SATIR: Detay Bilgiler (Kilo, Start, Takı, Antrenör, Fark)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Kilo, Start ve Takı
                    HStack(spacing: 6) {
                        Label("\(Int(finisher.KILO ?? 0))kg", systemImage: "scalemass")
                        Text("•")
                        Text("St: \(finisher.START ?? "-")")
                        if let taki = finisher.TAKI, !taki.isEmpty {
                            Text("•")
                            Text(taki)
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Antrenör Bilgisi
                    Text(finisher.ANTRENORADI ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    // Sahip Bilgisi
                    Text(finisher.SAHIPADI ?? "")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.8))
                    
                    Spacer()
                    
                    // Yarış Sonu Farkı (Vurgulu)
                    if let fark = finisher.FARK, !fark.isEmpty {
                        Text(fark)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.12))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.all, 5)
        .background(Color(.secondarySystemBackground).opacity(0.4))
        .cornerRadius(12)
    }
    
    // MARK: - Jersey Image Component
    private var jerseyImage: some View {
        AsyncImage(url: URL(string: finisher.FORMA ?? "")) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            case .failure, .empty:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray.opacity(0.5))
            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 12) {
            // 1. Örnek: Kazanan (Ganyan ve Fark belirgin)
            ResultRowView(finisher: .mock(
                no: "3",
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
                ad: "RÜZGARIN OĞLU",
                jokey: "M.KAYA",
                derece: "1.26.12",
                ganyan: "15.20",
                kilo: 54,
                start: "10",
                fark: "",
                taki: "DB"
            ))
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground)) // Liste arka planı hissi verir
}

// MARK: - Mock Helper
extension HorseResult {
    static func mock(
        no: String,
        ad: String,
        jokey: String,
        derece: String,
        ganyan: String,
        kilo: Double,
        start: String,
        fark: String,
        taki: String
    ) -> HorseResult {
        return HorseResult(
            KEY: UUID().uuidString,
            AD: ad,
            NO: no,
            JOKEYADI: jokey,
            SONUC: no, // Sonuç genelde numara ile eşleşir
            DERECE: derece,
            GANYAN: ganyan,
            FARK: fark,
            KILO: kilo,
            START: start,
            ANTRENORADI: "M.AKSOY",
            SAHIPADI: "ALİ VELİ",
            FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg",
            TAKI: taki
        )
    }
}
