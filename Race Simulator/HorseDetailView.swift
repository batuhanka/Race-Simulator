//
//  HorseDetailView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 08.03.2026.
//

import SwiftUI

struct HorseDetailView: View {
    let horseCode: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var horseData: Horse?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan gradyanı
                LinearGradient(
                    colors: [Color.black, Color.blue.opacity(0.3), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Yükleniyor...")
                        .tint(.cyan)
                        .foregroundColor(.white)
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else if let horse = horseData {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Üst Kısım: Forma ve Temel Bilgiler
                            horseHeaderSection(horse: horse)
                            
                            // Detaylı İstatistikler
                            horseStatsSection(horse: horse)
                            
                            // Jokey ve Antrenör Bilgileri
                            horsePeopleSection(horse: horse)
                            
                            // Son Yarış Performansı
                            if let son6 = horse.SON6, !son6.isEmpty {
                                recentRacesSection(son6: son6)
                            }
                            
                            // AGF Bilgileri
                            if horse.AGF1 != nil || horse.AGF2 != nil {
                                agfSection(horse: horse)
                            }
                            
                            Spacer(minLength: 30)
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "Veri Bulunamadı",
                        systemImage: "horse.fill",
                        description: Text("At bilgisi yüklenemedi.")
                    )
                }
            }
            .navigationTitle("At Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task {
            await loadHorseDetails()
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private func horseHeaderSection(horse: Horse) -> some View {
        VStack(spacing: 16) {
            // Forma görseli
            if let formaLink = horse.FORMA, let url = URL(string: formaLink) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    } else {
                        Rectangle()
                            .fill(horse.coatTheme.bg.opacity(0.3))
                            .frame(height: 200)
                            .cornerRadius(12)
                    }
                }
            }
            
            // At adı ve numarası
            HStack(alignment: .center, spacing: 12) {
                Text(horse.NO ?? "0")
                    .font(.system(size: 48, weight: .black))
                    .italic()
                    .foregroundColor(.cyan)
                    .frame(width: 80)
                    .minimumScaleFactor(0.6)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(horse.AD ?? "Bilinmeyen At")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .strikethrough(horse.KOSMAZ == true, color: .red)
                    
                    if horse.KOSMAZ == true {
                        Text("KOŞMAZ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Stats Section
    @ViewBuilder
    private func horseStatsSection(horse: Horse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("İstatistikler")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.cyan)
            
            VStack(spacing: 8) {
                statRow(label: "Yaş", value: horse.YAS ?? "-")
                statRow(label: "Kilo", value: String(format: "%.1f kg", horse.KILO ?? 0))
                statRow(label: "Handikap", value: horse.HANDIKAP ?? "-")
                statRow(label: "KGS", value: horse.KGS ?? "-")
                
                if let taki = horse.TAKI, !taki.isEmpty {
                    statRow(label: "Takı", value: taki, valueColor: .green)
                }
                
                statRow(label: "Baba", value: horse.BABA ?? "-")
                statRow(label: "Anne", value: horse.ANNE ?? "-")
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - People Section
    @ViewBuilder
    private func horsePeopleSection(horse: Horse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kadro")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.cyan)
            
            VStack(spacing: 8) {
                if let jokey = horse.JOKEYADI {
                    HStack {
                        Label("Jokey", systemImage: "person.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 120, alignment: .leading)
                        
                        Text(jokey)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        if horse.APRANTIFLG == true {
                            Text("AP")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                }
                
                if let antrenor = horse.ANTRENORADI {
                    HStack {
                        Label("Antrenör", systemImage: "figure.walk")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 120, alignment: .leading)
                        
                        Text(antrenor)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                
                if let sahip = horse.SAHIPADI {
                    HStack {
                        Label("Sahip", systemImage: "person.2.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 120, alignment: .leading)
                        
                        Text(sahip)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Recent Races Section
    @ViewBuilder
    private func recentRacesSection(son6: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son Yarışlar")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.cyan)
            
            HStack(spacing: 4) {
                let yarislarda = stride(from: 0, to: son6.count, by: 2).compactMap { i -> String? in
                    let startIndex = son6.index(son6.startIndex, offsetBy: i)
                    guard let endIndex = son6.index(startIndex, offsetBy: 2, limitedBy: son6.endIndex) else { return nil }
                    return String(son6[startIndex..<endIndex])
                }
                
                ForEach(yarislarda, id: \.self) { yaris in
                    parseSonYarisLarge(yaris)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - AGF Section
    @ViewBuilder
    private func agfSection(horse: Horse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AGF Değerleri")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.cyan)
            
            VStack(spacing: 12) {
                if let agf1 = horse.AGF1, !agf1.isEmpty {
                    agfRow(sira: horse.AGFSIRA1, agf: agf1, label: "AGF 1")
                }
                
                if let agf2 = horse.AGF2, !agf2.isEmpty {
                    agfRow(sira: horse.AGFSIRA2, agf: agf2, label: "AGF 2")
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    private func statRow(label: String, value: String, valueColor: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(valueColor)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func agfRow(sira: Int?, agf: String, label: String) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 60, alignment: .leading)
            
            HStack(spacing: 4) {
                Text("\(sira ?? 0).")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.cyan)
                
                Text("%\(agf)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Progress bar
            let cleanString = agf.replacingOccurrences(of: ",", with: ".") 
            let value = Double(cleanString) ?? 0.0
            let percentage = CGFloat(min(max(value, 0), 100)) / 100.0
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 20)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 100 * percentage, height: 20)
            }
            .frame(width: 100)
        }
    }
    
    private func parseSonYarisLarge(_ veri: String) -> some View {
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
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .frame(minWidth: 30)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(6)
    }
    
    // MARK: - Data Loading
    private func loadHorseDetails() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simüle edilmiş yükleme - Gerçek API'nizi buraya entegre edin
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // TODO: Burada gerçek API çağrısını yapabilirsiniz
        // Örnek: let data = try await JsonParser().getHorseDetails(horseCode: horseCode)
        
        await MainActor.run {
            isLoading = false
            // Şimdilik veri bulunamadı mesajı
            // Gerçek implementasyonda API'den gelen veriyi atayın:
            // self.horseData = parsedHorse
            self.errorMessage = "At detayları için API entegrasyonu gereklidir.\nAt Kodu: \(horseCode)"
        }
    }
}

// MARK: - Preview
#Preview {
    HorseDetailView(horseCode: "123456")
        .preferredColorScheme(.dark)
}
