import SwiftUI

struct ResultRowView: View {
    let finisher: HorseResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 4) {
                
                Text(finisher.NO ?? "")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.primary)
                
                jerseyImage
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .top, spacing: 4) {
                        Text(finisher.AD ?? "")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(finisher.KOSMAZ == true ? .red : .primary)
                            .strikethrough(finisher.KOSMAZ == true, color: .red)
                        
                        if let ekuri = finisher.EKURI, ekuri != "false" {
                            AsyncImage(url: URL(string: "https://medya-cdn.tjk.org/imageftp/Img/e\(ekuri).gif")) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                case .failure, .empty:
                                    EmptyView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    
                    HStack(spacing: 4) {
                        
                        let coatTheme = finisher.coatTheme
                        Text("\(finisher.YAS ?? "")")
                            .font(.system(size: 9.5, weight: coatTheme.bg == .clear ? .regular : .semibold))
                            .foregroundColor(coatTheme.fg)
                            .padding(.horizontal, coatTheme.bg == .clear ? 0 : 4)
                            .padding(.vertical, coatTheme.bg == .clear ? 0 : 2)
                            .background(coatTheme.bg)
                            .cornerRadius(3)
                        
                        //Text(finisher.YAS ?? "")
                        Text(String(format: "%.1f", finisher.KILO ?? 0) + "kg")
                        Text(finisher.TAKI ?? "").fontWeight(.semibold).foregroundColor(.green)
                        
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        if finisher.APRANTIFLG == true {
                            Text("AP")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.horizontal, -16)
                                .offset(x: 4, y: -4)
                        }
                        
                        Text(finisher.JOKEYADI ?? "")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    if let ganyan = finisher.GANYAN, ganyan != "0", !ganyan.isEmpty {
                        Text("\(ganyan)")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.12))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
            }
            
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(finisher.ANTRENORADI ?? "")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(finisher.SAHIPADI ?? "")
                            .font(.caption2)
                    }
                    
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .opacity(finisher.KOSMAZ == true ? 0.5 : 1.0)
    }
    
    // MARK: - Jersey Image Component
    private var jerseyImage: some View {
        AsyncImage(url: URL(string: finisher.FORMA ?? "")) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
            case .empty:
                ProgressView().frame(width: 30, height: 30)
            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 4) {
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
    .background(Color(.systemGroupedBackground))
}

// MARK: - Mock Helper
extension HorseResult {
    static func mock(
        no: String = "1",
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
            SONUC: no,
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
            KOSMAZ: true,
            APRANTIFLG: true,
            EKURI:"1"
        )
    }
}
