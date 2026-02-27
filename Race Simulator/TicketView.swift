import SwiftUI

// MARK: - Veri Modelleri
struct BetChecksumResponse: Codable {
    let checksum: String
}

struct BetDataResponse: Codable {
    // JSON'da "yarislar" bir anahtar-değer koleksiyonu olduğu için Dictionary kullanıyoruz.
    let yarislar: [String: RaceDay]
}

struct RaceDay: Codable, Identifiable, Hashable {
    // Identifiable ve Hashable olması, Picker ve Listelerde kullanımı kolaylaştırır.
    var id: String { KOD }
    
    let KOD: String
    let AD: String
    let bahisler: [BetType]
}

struct BetType: Codable, Identifiable, Hashable {
    var id: String { KOD }
    
    let AD: String
    let KOD: String
}

// MARK: - Ana View
struct TicketView: View {
    @State private var isLoading = true
    @State private var raceDays: [RaceDay] = []
    @State private var selectedRaceDay: RaceDay?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Bahis bilgileri yükleniyor...")
                } else if let errorMessage = errorMessage {
                    ContentUnavailableView("Hata", systemImage: "xmark.octagon", description: Text(errorMessage))
                } else {
                    mainContent
                }
            }
            .navigationTitle("Bahis Kuponu")
            .task {
                await loadBettingData()
            }
        }
    }
    
    // MARK: - View İçerikleri
    @ViewBuilder
    private var mainContent: some View {
        Form {
            Section(header: Text("Yarış Yeri Seçimi")) {
                Picker("Şehir Seçin", selection: $selectedRaceDay) {
                    Text("Lütfen bir şehir seçin").tag(nil as RaceDay?)
                    ForEach(raceDays) { day in
                        Text(day.AD).tag(day as RaceDay?)
                    }
                }
            }
            
            if let selectedRaceDay = selectedRaceDay {
                Section(header: Text("\(selectedRaceDay.AD) Bahis Türleri")) {
                    List(selectedRaceDay.bahisler) { bahis in
                        Text(bahis.AD)
                    }
                }
            }
        }
    }
    
    // MARK: - Veri Çekme İşlemleri
    private func loadBettingData() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // 1. Adım: Checksum değerini al
            let checksumUrl = URL(string: "https://ebayi.tjk.org/s/d/bet/checksum.json")!
            let (checksumData, _) = try await URLSession.shared.data(from: checksumUrl)
            let checksumResponse = try JSONDecoder().decode(BetChecksumResponse.self, from: checksumData)
            let checksum = checksumResponse.checksum
            
            // 2. Adım: Checksum ile ana bahis verisini çek
            let betDataUrl = URL(string: "https://emedya-cdn.tjk.org/s/d/bet/bet-\(checksum).json")!
            let (betData, _) = try await URLSession.shared.data(from: betDataUrl)
            let betResponse = try JSONDecoder().decode(BetDataResponse.self, from: betData)
            
            // 3. Adım: Veriyi filtrele (KOD < 11) ve sırala
            let filteredAndSorted = betResponse.yarislar.values
                .filter { (Int($0.KOD) ?? 99) < 11 }
                .sorted { $0.AD < $1.AD }
            
            // 4. Adım: State'i güncelle
            await MainActor.run {
                self.raceDays = filteredAndSorted
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Bahis verileri yüklenemedi: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    TicketView()
}
