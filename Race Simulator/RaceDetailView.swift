//
//  RaceDetailView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 19.03.2025.
//

import SwiftUI

struct RaceDetailView: View {
    var raceName: String
    var havaData: HavaData
    var kosular: [Race]
    var agf: [[String: Any]]
    @State private var selectedIndex = 0
    
    private func getPistColors(for index: Int) -> [Color] {
        guard kosular.indices.contains(index) else { return [Color.gray, Color.black] }
        let pist = kosular[index].PIST ?? ""
        if pist.contains("cim") {
            return [Color.green.opacity(0.4), Color.green.opacity(1)]
        } else if pist.contains("kum") {
            return [Color.orange.opacity(0.3), Color.brown.opacity(1)]
        } else if pist.contains("sentetik") {
            return [Color.blue.opacity(0.3), Color.gray.opacity(0.5)]
        } else {
            return [Color.gray.opacity(0.2), Color.black.opacity(0.1)]
        }
    }
    
    var body: some View {
        ZStack {
            // Arka plan gradyanı
            LinearGradient(
                gradient: Gradient(colors: getPistColors(for: selectedIndex)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. ÜST ALAN: Koşu Bilgisi (SABİT)
                headerBilgiAlani
                
                // 2. ORTA ALAN: Dikey Liste
                if kosular.indices.contains(selectedIndex) {
                    List {
                        let seciliKosu = kosular[selectedIndex]
                        
                        if let atlar = seciliKosu.atlar {
                            ForEach(atlar, id: \.id) { at in
                                ListItemView(at: at)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button { print("Favori") } label: {
                                            Label("Favori", systemImage: "star")
                                        }
                                        .tint(.yellow)
                                        
                                        Button { print("Analiz") } label: {
                                            Label("Analiz", systemImage: "chart.bar")
                                        }
                                        .tint(.blue)
                                    }
                            }
                        } else {
                            Text("Bu koşu için at bilgisi bulunamadı.")
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                } else {
                    ContentUnavailableView("Veri Bekleniyor", systemImage: "horse.fill")
                }
                
                // 3. ALT ALAN (FOOTER): Tam Genişliğe Sığan Butonlar
                footerKosuSecici
            }
        }
        .navigationTitle(havaData.hipodromAdi)
        .navigationBarTitleDisplayMode(.inline)
    }

    // Üstteki Bilgi Kutusu
    var headerBilgiAlani: some View {
        Group {
            if kosular.indices.contains(selectedIndex) {
                let currentKosu = kosular[selectedIndex]
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(currentKosu.RACENO ?? "0").Koşu")
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "clock")
                        Text("\(currentKosu.SAAT ?? "00:00")")
                            .fontWeight(.bold)
                    }
                    Text(currentKosu.BILGI_TR ?? "")
                        .font(.caption2)
                        .lineLimit(2)
                }
                .padding()
                .background(.ultraThinMaterial)
            } else {
                EmptyView()
            }
        }
    }

    // Alttaki Koşu Numaraları (Tam Genişlik - Scrollsuz)
    var footerKosuSecici: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 4) { // Butonlar arası minimal boşluk
                ForEach(kosular.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring()) { selectedIndex = index }
                    }) {
                        Text("\(kosular[index].RACENO ?? "0")")
                            .font(.system(size: 14, weight: .bold))
                            .minimumScaleFactor(0.5) // Sayı çoksa yazıyı küçültür
                            .frame(maxWidth: .infinity) // EKALANI EŞİT PAYLAŞTIRIR
                            .frame(height: 45)
                            .background(selectedIndex == index ? Color.primary : Color.primary.opacity(0.1))
                            .foregroundColor(selectedIndex == index ? Color(.systemBackground) : .primary)
                            .cornerRadius(8) // Sığması için karemsi-yuvarlak daha iyi alan sağlar
                    }
                }
            }
            .padding(8) // Dış boşluk
            .background(.ultraThinMaterial)
        }
    }
}
