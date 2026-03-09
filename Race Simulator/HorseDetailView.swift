//
//  HorseDetailView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 08.03.2026.
//

import SwiftUI

struct HorseDetailView: View {
    let horseCode: String
    let formaURL: String?
    
    @Environment(\.dismiss) private var dismiss
    @State private var detailInfo: HorseDetailInfo?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.cyan)
                        Text("Yükleniyor...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Tekrar Dene") {
                            Task {
                                await loadHorseDetails()
                            }
                        }
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(8)
                    }
                } else if let detail = detailInfo {
                    ScrollView {
                        VStack(spacing: 0) {
                            heroHeaderSection(detail: detail)
                            
                            VStack(spacing: 16) {
                                
                                tzStyleCard() {
                                    allInfoContent(detail: detail)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                             
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                } else {
                    ContentUnavailableView(
                        "Veri Bulunamadı",
                        systemImage: "horse.fill",
                        description: Text("At bilgisi yüklenemedi.")
                    )
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task {
            await loadHorseDetails()
        }
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ value: String) -> String {
        return value.replacingOccurrences(of: "t", with: " ₺")
                   .replacingOccurrences(of: "T", with: " ₺")
    }
    
    // MARK: - Data Loading
    private func loadHorseDetails() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let info = try await HtmlParser.shared.parseAtKosuBilgileri(atId: horseCode)
            
            await MainActor.run {
                self.detailInfo = info
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "At bilgileri yüklenemedi:\n\(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    @ViewBuilder
    private func heroHeaderSection(detail: HorseDetailInfo) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Arka plan forma görseli - Daha küçük
                if let formaURL = formaURL, let url = URL(string: formaURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 180)
                                .clipped()
                        } else {
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(height: 180)
                        }
                    }
                } else {
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 180)
                }
                
                // Gradient overlay - Üstten başlayarak
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.4),
                        Color.clear,
                        Color.black.opacity(0.6),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                
                // İçerik - Safe area dahil tüm alan
                VStack(spacing: 0) {
                    // Safe area için boşluk
                    Color.clear
                        .frame(height: geometry.safeAreaInsets.top)
                    
                    // Title Bar
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // At İsmi ve Bilgiler
                    VStack(spacing: 10) {
                        Text(detail.isim)
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                        
                        // Stats Bar - TZ Style
                        HStack(spacing: 0) {
                            statBadge(title: "YAŞ", value: detail.yas, color: .cyan)
                            
                            Divider()
                                .frame(width: 1, height: 36)
                                .background(Color.white.opacity(0.3))
                            
                            statBadge(title: "DOĞUM", value: detail.dogumTarihi, color: .cyan)
                            
                            Divider()
                                .frame(width: 1, height: 36)
                                .background(Color.white.opacity(0.3))
                            
                            statBadge(title: "HANDİKAP", value: detail.handikap.isEmpty ? "-" : detail.handikap, color: .cyan)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.cyan.opacity(0.4), lineWidth: 1.5)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(height: 180)
        }
        .frame(height: 180)
    }
    
    @ViewBuilder
    private func statBadge(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - TZ Style Card Container
    @ViewBuilder
    private func tzStyleCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // İçerik
            content()
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.cyan.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Content Sections
    @ViewBuilder
    private func allInfoContent(detail: HorseDetailInfo) -> some View {
        VStack(spacing: 12) {
            // Aile Bilgileri
            tzInfoRow(label: "Baba", value: detail.baba, icon: "mustache.fill")
            tzDivider()
            tzInfoRow(label: "Anne", value: detail.anne, icon: "heart.fill")
        
            Color.clear.frame(height: 8)
            
            tzInfoRow(label: "Antrenör", value: detail.antrenor, icon: "person.fill")
            tzDivider()
            tzInfoRow(label: "Gerçek Sahip", value: detail.gercekSahip, icon: "crown.fill")
            
            if let uzerineKosan = detail.uzerineKosanSahip, !uzerineKosan.isEmpty {
                tzDivider()
                tzInfoRow(label: "Üzerine Koşan", value: uzerineKosan, icon: "person.2.fill")
            }
            
            tzDivider()
            tzInfoRow(label: "Yetiştirici", value: detail.yetistirici, icon: "leaf.fill")
            
            if let tercih = detail.tercihAciklamasi, !tercih.isEmpty {
                tzDivider()
                tzInfoRow(label: "Tercih", value: tercih, icon: "star.fill")
            }
            
            // Boşluk
            Color.clear.frame(height: 8)
            
            // Finansal Özet
            tzInfoRow(label: "İkramiye", value: formatCurrency(detail.ikramiye), icon: "trophy.fill")
            tzDivider()
            tzInfoRow(label: "At Sahibi Primi", value: formatCurrency(detail.atSahibiPrimi), icon: "dollarsign.circle.fill")
            tzDivider()
            tzInfoRow(label: "Yurtdışı İkramiye", value: formatCurrency(detail.yurtdisiIkramiye), icon: "globe")
            tzDivider()
            tzInfoRow(label: "Kazanç", value: formatCurrency(detail.kazanc), icon: "banknote.fill")
            tzDivider()
            tzInfoRow(label: "Yetiştiricilik Primi", value: formatCurrency(detail.yetistiricilikPrimi), icon: "leaf.circle.fill")
            
            if let sponsorluk = detail.sponsorlukGeliri, !sponsorluk.isEmpty {
                tzDivider()
                tzInfoRow(label: "Sponsorluk Geliri", value: formatCurrency(sponsorluk), icon: "briefcase.fill")
            }
        }
    }
    
    @ViewBuilder
    private func tzInfoRow(label: String, value: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // İkon
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.cyan.opacity(0.7))
                .frame(width: 20)
            
            // Label - Cyan ve bold
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.cyan)
                .frame(width: 130, alignment: .leading)
            
            // Değer
            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder
    private func tzDivider() -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, Color.cyan.opacity(0.2), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
    
    // MARK: - Künye Section
    @ViewBuilder
    private func kunyeSection(kunye: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Künye Bilgileri")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.cyan)
            
            VStack(spacing: 0) {
                ForEach(Array(kunye.keys.sorted()), id: \.self) { key in
                    if let value = kunye[key], !key.hasPrefix("_header_") {
                        kunyeRow(label: key, value: value)
                        
                        if key != kunye.keys.sorted().last {
                            Divider()
                                .background(Color.white.opacity(0.2))
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func kunyeRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - İstatistik Section
    @ViewBuilder
    private func istatistikSection(istatistik: [String: Any]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("İstatistik Bilgileri")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.cyan)
            
            VStack(spacing: 0) {
                ForEach(Array(istatistik.keys.sorted()), id: \.self) { key in
                    if let value = istatistik[key], !key.hasPrefix("_header_") {
                        let valueString = "\(value)"
                        
                        if key.hasPrefix("_header_") {
                            // Başlık satırı
                            Text(valueString)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.cyan)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                        } else {
                            // Normal satır
                            kunyeRow(label: key, value: valueString)
                            
                            if key != istatistik.keys.sorted().last {
                                Divider()
                                    .background(Color.white.opacity(0.2))
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}


#Preview("Canlı Veri - 101209") {
    HorseDetailView(
        horseCode: "101209",
        formaURL: "https://medya-cdn.tjk.org/formaftp/101209.jpg"
    )
    .preferredColorScheme(.dark)
}
