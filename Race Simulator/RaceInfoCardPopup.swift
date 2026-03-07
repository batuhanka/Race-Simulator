import SwiftUI

struct RaceInfoCardPopup: View {
    // MARK: - Properties
    @Binding var isExpanded: Bool
    let race: Race
    let havaData: HavaData
    
    @State private var dragOffset: CGFloat = 0
    
    // Kartın konumu - sol/alt seçimi için
    enum CardPosition {
        case leading  // Sol taraf
        case bottom   // Alt taraf
    }
    let position: CardPosition
    
    // MARK: - Body
    var body: some View {
        Group {
            if position == .leading {
                leadingPositionCard
            } else {
                bottomPositionCard
            }
        }
    }
    
    // MARK: - Sol Taraf Konumlandırma
    private var leadingPositionCard: some View {
        HStack(spacing: 0) {
            if isExpanded {
                cardContent
                    .frame(width: 280)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            // Ok Butonu
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
            // Ok Butonu
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
                    .frame(height: 200)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
    
    // MARK: - Kart İçeriği
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Başlık
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.cyan)
                Text("Koşu Bilgileri")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Koşu Bilgileri
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    infoRow(icon: "number.circle.fill", title: "Koşu No", value: race.RACENO ?? "-")
                    infoRow(icon: "clock.fill", title: "Saat", value: race.SAAT ?? "-")
                    
                    if let pist = race.PIST {
                        infoRow(icon: "flag.checkered", title: "Pist", value: pist)
                    }
                    
                    if let mesafe = race.MESAFE {
                        infoRow(icon: "ruler", title: "Mesafe", value: "\(mesafe)m")
                    }
                    
                    // Hava Durumu
                    HStack(spacing: 8) {
                        Image(systemName: weatherIcon(for: havaData.havaDurumIcon))
                            .foregroundColor(.yellow)
                            .frame(width: 24)
                        Text("Hava:")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(havaData.havaTr), \(havaData.sicaklik)°C")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                    
                    if let bilgi = race.BILGI_TR, !bilgi.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Detaylar:")
                                .font(.caption)
                                .foregroundColor(.cyan)
                            Text(bilgi)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(3)
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                // Arka plan efekti
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.7))
                
                // Cam efekti
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                // Border
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
    
    // MARK: - Helper Views
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 24)
            Text("\(title):")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
    }
    
    private func weatherIcon(for iconName: String) -> String {
        switch iconName {
        case "icon-w-1":  return "sun.max.fill"
        case "icon-w-2":  return "cloud.sun.fill"
        case "icon-w-3":  return "cloud.fill"
        case "icon-w-4":  return "cloud.rain.fill"
        case "icon-w-5":  return "cloud.snow.fill"
        case "icon-w-6":  return "cloud.fog.fill"
        case "icon-w-7":  return "cloud.bolt.fill"
        case "icon-w-8":  return "cloud.drizzle.fill"
        default:          return "cloud.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            // Sol taraf örneği
            RaceInfoCardPopup(
                isExpanded: .constant(true),
                race: Race(
                    KOD: "123",
                    RACENO: "1",
                    SAAT: "14:30",
                    BILGI_TR: "Arap Atları, 3 yaş ve üzeri",
                    PIST: "ÇİM",
                    MESAFE: "1600",
                    atlar: nil
                ),
                havaData: HavaData(
                    aciklama: 0,
                    cimPistagirligi: 0,
                    cimEn: "Good",
                    cimTr: "İyi",
                    gece: 0,
                    havaDurumIcon: "icon-w-1",
                    havaEn: "Sunny",
                    havaTr: "Güneşli",
                    hipodromAdi: "Test Hipodrom",
                    hipodromYeri: "İstanbul",
                    kumPistagirligi: 0,
                    kumEn: "Good",
                    kumTr: "İyi",
                    nem: 60,
                    sicaklik: 25
                ),
                position: .leading
            )
            .frame(maxHeight: .infinity, alignment: .center)
            
            Divider().background(Color.white)
            
            // Alt taraf örneği
            RaceInfoCardPopup(
                isExpanded: .constant(true),
                race: Race(
                    KOD: "456",
                    RACENO: "2",
                    SAAT: "15:00",
                    BILGI_TR: "İngiliz Atları",
                    PIST: "KUM",
                    MESAFE: "2000",
                    atlar: nil
                ),
                havaData: HavaData(
                    aciklama: 0,
                    cimPistagirligi: 0,
                    cimEn: "Soft",
                    cimTr: "Yumuşak",
                    gece: 0,
                    havaDurumIcon: "icon-w-4",
                    havaEn: "Rainy",
                    havaTr: "Yağmurlu",
                    hipodromAdi: "Test Hipodrom",
                    hipodromYeri: "İstanbul",
                    kumPistagirligi: 0,
                    kumEn: "Soft",
                    kumTr: "Yumuşak",
                    nem: 85,
                    sicaklik: 18
                ),
                position: .bottom
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}
