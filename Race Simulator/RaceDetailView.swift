import SwiftUI

// MARK: - 1. YAN MENÜ BİLEŞENİ
struct SideMenuView: View {
    let kosular: [Race]
    @Binding var selectedIndex: Int
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                // Menü Başlığı
                Text("Yarış Programı")
                    .font(.title2.bold())
                    .padding(.top, 60)
                    .padding(.horizontal)
                
                // Koşu Listesi
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(kosular.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedIndex = index
                                    isMenuOpen = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.caption)
                                    Text("\(kosular[index].RACENO ?? "0"). Koşu")
                                        .fontWeight(selectedIndex == index ? .bold : .regular)
                                    Spacer()
                                    Text(kosular[index].SAAT ?? "")
                                        .font(.caption)
                                        .monospacedDigit()
                                }
                                .padding()
                                .background(selectedIndex == index ? Color.blue.opacity(0.15) : Color.clear)
                                .foregroundColor(selectedIndex == index ? .blue : .primary)
                            }
                            Divider().padding(.horizontal)
                        }
                    }
                }
                Spacer()
                
                // Alt Bilgi
                Text("TJK Verileriyle Senkronize")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .frame(width: 270)
            .background(Color(.systemBackground))
            .offset(x: isMenuOpen ? 0 : -270) // Menü kayma efekti
            
            // Boş alan (Kapatma tetikleyicisi için)
            if isMenuOpen {
                Color.black.opacity(0.01)
                    .onTapGesture {
                        withAnimation(.spring()) { isMenuOpen = false }
                    }
            } else {
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 2. ANA DETAY GÖRÜNÜMÜ
struct RaceDetailView: View {
    var raceName: String
    var havaData: HavaData
    var kosular: [Race]
    var agf: [[String: Any]]
    
    @State private var selectedIndex = 0
    @State private var isMenuOpen = false
    
    // Pist tipine göre dinamik renkler
    private func getPistColors(for index: Int) -> [Color] {
        guard kosular.indices.contains(index) else { return [Color.gray, Color.black] }
        let pist = (kosular[index].PIST ?? "").lowercased(with: Locale(identifier: "tr_TR"))
        
        if pist.contains("cim") || pist.contains("çim") {
            return [Color.green.opacity(0.4), Color.green.opacity(0.8)]
        } else if pist.contains("kum") {
            return [Color.orange.opacity(0.4), Color.brown.opacity(0.8)]
        } else if pist.contains("sentetik") {
            return [Color.blue.opacity(0.3), Color.gray.opacity(0.6)]
        } else {
            return [Color.gray.opacity(0.3), Color.black.opacity(0.4)]
        }
    }
    
    var body: some View {
        ZStack {
            // --- ANA İÇERİK KATMANI ---
            VStack(spacing: 0) {
                headerBilgiAlani
                
                if kosular.indices.contains(selectedIndex) {
                    List {
                        let seciliKosu = kosular[selectedIndex]
                        if let atlar = seciliKosu.atlar, !atlar.isEmpty {
                            ForEach(atlar) { at in
                                // At kartı bileşeniniz (ListItemView)
                                ListItemView(at: at)
                            }
                        } else {
                            ContentUnavailableView("At Bilgisi Yok", systemImage: "horse.fill")
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                
                footerKosuSecici
            }
            .background(
                LinearGradient(gradient: Gradient(colors: getPistColors(for: selectedIndex)),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            )
            // Menü açıldığında içeriği sağa itme ve küçültme
            .scaleEffect(isMenuOpen ? 0.92 : 1)
            .offset(x: isMenuOpen ? 270 : 0)
            .disabled(isMenuOpen)
            
            // --- KARARTMA (OVERLAY) ---
            if isMenuOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { isMenuOpen = false }
                    }
            }
            
            // --- YAN MENÜ KATMANI ---
            SideMenuView(kosular: kosular, selectedIndex: $selectedIndex, isMenuOpen: $isMenuOpen)
        }
        .navigationTitle(raceName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isMenuOpen.toggle()
                    }
                } label: {
                    Image(systemName: isMenuOpen ? "xmark" : "line.3.horizontal")
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    // Üst Bilgi Paneli
    var headerBilgiAlani: some View {
        Group {
            if kosular.indices.contains(selectedIndex) {
                let currentKosu = kosular[selectedIndex]
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(currentKosu.RACENO ?? "0"). Koşu").font(.title3.bold())
                        Spacer()
                        Label(currentKosu.SAAT ?? "00:00", systemImage: "clock.badge").bold()
                    }
                    Text(currentKosu.BILGI_TR ?? "")
                        .font(.subheadline)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
    
    // Alt Koşu Seçici (Hızlı Geçiş)
    var footerKosuSecici: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 4) {
                ForEach(kosular.indices, id: \.self) { index in
                    Button {
                        withAnimation(.spring()) { selectedIndex = index }
                    } label: {
                        Text(kosular[index].RACENO ?? "0")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(selectedIndex == index ? Color.primary : Color.primary.opacity(0.1))
                            .foregroundColor(selectedIndex == index ? Color(.systemBackground) : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(8)
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Previews
#Preview("Race Detail Görünümü") {
    // Örnek bir HavaData oluşturuyoruz
    let mockHava = HavaData(
        aciklama: 0,
        cimPistagirligi: 1,
        cimEn: "Good",
        cimTr: "Çim: Normal (3.3)",
        gece: 0,
        havaDurumIcon: "sun.max.fill",
        havaEn: "Sunny",
        havaTr: "Güneşli",
        hipodromAdi: "Veliefendi Hipodromu",
        hipodromYeri: "İstanbul",
        kumPistagirligi: 1,
        kumEn: "Normal",
        kumTr: "Kum: Normal",
        nem: 40,
        sicaklik: 22
    )

    // Örnek bir Race listesi oluşturuyoruz (Race modelinizdeki init'e uygun)
    // Not: JSON'dan gelmediği için manuel bir test verisi oluşturmak adına
    // modelinize bir test init'i eklemek gerekebilir veya aşağıdaki gibi boş bir diziyle başlatılabilir.
    
    NavigationStack {
        RaceDetailView(
            raceName: "İstanbul",
            havaData: mockHava,
            kosular: mockRaces(), // Aşağıdaki yardımcı fonksiyonu kullanır
            agf: []
        )
    }
}

// Preview için test verisi üreten yardımcı fonksiyon
func mockRaces() -> [Race] {
    // Not: Race modeliniz Decodable olduğu için manuel init zordur.
    // Preview için en sağlıklı yol JSON string'inden decode etmektir:
    let json = """
    [
        {
            "KOD": "IST1",
            "RACENO": "1",
            "SAAT": "14:00",
            "PIST": "Çim",
            "PISTADI_TR": "Çim Pist",
            "MESAFE": "1900",
            "BILGI_TR": "3 Yaşlı İngilizler, Handikap 15",
            "ONEMLIKOSUADI_TR": false,
            "ONEMLIKOSUADI_EN": false,
            "OZELADI": false,
            "APRANTI": false,
            "hasSatisbedeli": false,
            "hasNonRunner": false,
            "atlar": []
        },
        {
            "KOD": "IST2",
            "RACENO": "2",
            "SAAT": "14:30",
            "PIST": "Kum",
            "PISTADI_TR": "Kum Pist",
            "MESAFE": "1400",
            "BILGI_TR": "4+ Araplar, Şartlı 4",
            "ONEMLIKOSUADI_TR": false,
            "ONEMLIKOSUADI_EN": false,
            "OZELADI": false,
            "APRANTI": true,
            "hasSatisbedeli": false,
            "hasNonRunner": false,
            "atlar": []
        }
    ]
    """.data(using: .utf8)!
    
    return (try? JSONDecoder().decode([Race].self, from: json)) ?? []
}
