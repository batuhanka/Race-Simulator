// JsonParser.swift

import Foundation

class JsonParser {
    
    func getRaceCities(raceDate: String) async throws -> [String] {
        let urlValue = URL(string: "https://ebayi.tjk.org/s/d/program/\(raceDate)/yarislar.json")!
        let (data, _) = try await URLSession.shared.data(from: urlValue)
        
        guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            return []
        }
        
        var result: [String] = []
        for object in jsonArray {
            if let code = object["KOD"] as? String,
               let intCode = Int(code), intCode < 11,
               let city = object["KEY"] as? String {
                result.append(city)
            }
        }
        return result
    }
    
    func getProgramData(raceDate: String, cityName: String) async throws -> [String: Any] {
        let urlValue = URL(string: "https://ebayi.tjk.org/s/d/program/\(raceDate)/full/\(cityName).json")!
        let (data, _) = try await URLSession.shared.data(from: urlValue)
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDict = jsonObject as? [String: Any] else {
            throw NSError(domain: "InvalidJSON", code: 1, userInfo: [NSLocalizedDescriptionKey: "Expected a dictionary"])
        }
        return jsonDict
    }
    
    
    // MARK: - Muhtemeller (OddsView)

    func getMuhtemellerChecksum(date: Date) async throws -> ChecksumResponse {
        let f = DateFormatter(); f.dateFormat = "yyyy/MM/dd"
        guard let url = URL(string: "https://vhs-medya.tjk.org/muhtemeller/s/\(f.string(from: date))/checksum.json") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ChecksumResponse.self, from: data)
    }

    func getMuhtemeller(date: Date, raceKey: String, hash: String) async throws -> RaceDetailResponse {
        let f = DateFormatter(); f.dateFormat = "yyyy/MM/dd"
        guard let url = URL(string: "https://vhs-medya-cdn.tjk.org/muhtemeller/s/\(f.string(from: date))/\(raceKey)-\(hash).json") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(RaceDetailResponse.self, from: data)
    }

    func getProgramResponse(date: Date, cityName: String) async throws -> ProgramResponse {
        let f = DateFormatter(); f.dateFormat = "yyyyMMdd"
        guard let url = URL(string: "https://ebayi.tjk.org/s/d/program/\(f.string(from: date))/full/\(cityName).json") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ProgramResponse.self, from: data)
    }

    // MARK: - Betting (TicketView)

    func getBetData() async throws -> BetDataResponse {
        guard let checksumURL = URL(string: "https://ebayi.tjk.org/s/d/bet/checksum.json") else {
            throw URLError(.badURL)
        }
        let (cData, _) = try await URLSession.shared.data(from: checksumURL)
        let checksum = try JSONDecoder().decode(BetChecksumResponse.self, from: cData).checksum
        guard let betURL = URL(string: "https://emedya-cdn.tjk.org/s/d/bet/bet-\(checksum).json") else {
            throw URLError(.badURL)
        }
        let (bData, _) = try await URLSession.shared.data(from: betURL)
        return try JSONDecoder().decode(BetDataResponse.self, from: bData)
    }

    // MARK: - Race Results

    func getRaceResult(raceDate: String, cityName: String, targetKod: String) async throws -> RaceResult? {
        // 1. Sanitize the city name (Aynı kalıyor)
        let sanitized = cityName
            .replacingOccurrences(of: "ğ", with: "g")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "ş", with: "s")
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ç", with: "c")
        
        let uppercaseCity = sanitized.uppercased(with: Locale(identifier: "tr_TR"))

        let urlString = "https://ebayi.tjk.org/s/d/sonuclar/\(raceDate)/full/\(uppercaseCity).json"
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any],
              let kosularArray = jsonObject["kosular"] as? [[String: Any]] else {
            return nil
        }
        
        if let targetDict = kosularArray.first(where: { "\($0["KOD"] ?? "")" == targetKod }) {
            let resultData = try JSONSerialization.data(withJSONObject: targetDict, options: [])
            let decoder = JSONDecoder()
            return try decoder.decode(RaceResult.self, from: resultData)
        }
        
        return nil
    }
    
    // MARK: - Day Data (Checksum & Complete Data)
    
    /// Günlük checksum verisini getirir
    func getDayChecksum() async throws -> DayChecksumData {
        guard let url = URL(string: "https://ebayi.tjk.org/s/d/day/checksum.json") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(DayChecksumData.self, from: data)
    }
    
    /// Tüm günlük verileri organize bir şekilde getirir
    func getDayCompleteData() async throws -> OrganizedDayData {
        guard let url = URL(string: "https://ebayi.tjk.org/s/d/day/checksum.json") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "InvalidJSON", code: 1, userInfo: [NSLocalizedDescriptionKey: "Expected a dictionary"])
        }
        
        return OrganizedDayData(
            hava: jsonObject["hava"] as? [String: Any] ?? [:],
            sonuclar: jsonObject["sonuclar"] as? [String: Any] ?? [:],
            muhtemeller: jsonObject["muhtemeller"] as? [String: Any] ?? [:],
            jokeyler: jsonObject["jokeyler"] as? [String: Any] ?? [:],
            agf: jsonObject["agf"] as? [String: Any] ?? [:],
            program: jsonObject["program"] as? [String: Any] ?? [:],
            ganyan: jsonObject["ganyan"] as? [String: Any] ?? [:],
            ikili: jsonObject["ikili"] as? [String: Any] ?? [:],
            uclu: jsonObject["uclu"] as? [String: Any] ?? [:],
            plase: jsonObject["plase"] as? [String: Any] ?? [:],
            aptalon: jsonObject["aptalon"] as? [String: Any] ?? [:],
            allKeys: jsonObject
        )
    }
    
    /// Belirli bir şehir için güncel yarış sonuçlarını getirir (AGF dahil)
    /// - Parameter cityName: Şehir ismi (örnek: "IZMIR")
    /// - Returns: Sonuç verilerini içeren dictionary
    func getCityRaceResults(cityName: String) async throws -> [String: Any] {
        // 1. Checksum'ı al
        let checksumData = try await getDayChecksum()
        
        print("🔍 Checksum AGF keys: \(checksumData.agf?.keys.map(Array.init) ?? [])")
        
        // 2. AGF içinden şehir hash'ini al (sonuclar değil!)
        guard let agfData = checksumData.agf,
              let cityHash = agfData[cityName] else {
            throw NSError(domain: "CityNotFound", code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "AGF verisi bulunamadı: \(cityName)"])
        }
        
        print("🔑 \(cityName) için AGF hash: \(cityHash)")
        
        // 3. Hash ile AGF JSON'ını çek (sonuclar değil, agf endpoint'i!)
        guard let url = URL(string: "https://ebayi.tjk.org/s/d/day/agf/\(cityName).json?c=\(cityHash)") else {
            throw URLError(.badURL)
        }
        
        print("🌐 AGF URL: \(url.absoluteString)")
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "InvalidJSON", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "Geçersiz JSON formatı"])
        }
        
        print("📦 AGF JSON anahtarları: \(jsonObject.keys)")
        
        return jsonObject
    }
    
    /// İzmir için AGF sonuçlarını getirir (kısayol fonksiyon)
    func getIzmirRaceResults() async throws -> [String: Any] {
        return try await getCityRaceResults(cityName: "IZMIR")
    }
    
    /// Belirli bir şehir için gerçek yarış sonuçlarını getirir (AGF değil, koşu sonuçları)
    /// - Parameter cityName: Şehir ismi (örnek: "IZMIR")
    /// - Returns: Sonuç verilerini içeren dictionary
    func getCityRaceActualResults(cityName: String) async throws -> [String: Any] {
        // 1. Checksum'ı al
        let checksumData = try await getDayChecksum()
        
        // 2. Sonuclar içinden şehir hash'ini al
        guard let sonuclar = checksumData.sonuclar,
              let cityHash = sonuclar[cityName] else {
            throw NSError(domain: "CityNotFound", code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "Şehir sonuçları bulunamadı: \(cityName)"])
        }
        
        // 3. Hash ile sonuç JSON'ını çek
        guard let url = URL(string: "https://ebayi.tjk.org/s/d/day/sonuclar/\(cityName).json?c=\(cityHash)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "InvalidJSON", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "Geçersiz JSON formatı"])
        }
        
        return jsonObject
    }
    
}

// MARK: - Day Data Models

/// Checksum verilerini içeren model
struct DayChecksumData: Decodable {
    let hava: [String: String]?
    let sonuclar: [String: String]?
    let muhtemeller: [String: AnyCodable]?  // Dictionary veya String olabilir
    let jokeyler: [String: String]?
    let agf: [String: AnyCodable]?  // Dictionary veya String olabilir
    let program: [String: String]?
    let ganyan: [String: String]?
    let ikili: [String: String]?
    let uclu: [String: String]?
    let plase: [String: String]?
    let aptalon: [String: String]?
    let dateHuman: String?  // "6 Mart 2026 Cuma"
}

/// JSON'da hem dictionary hem String olabilen değerler için wrapper
struct AnyCodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let dict = try? container.decode([String: String].self) {
            value = dict
        } else {
            value = ""
        }
    }
    
    var stringValue: String? {
        return value as? String
    }
    
    var dictionaryValue: [String: Any]? {
        return value as? [String: Any]
    }
    
    var stringDictionaryValue: [String: String]? {
        return value as? [String: String]
    }
}
/// Organize edilmiş günlük veri yapısı
struct OrganizedDayData {
    let hava: [String: Any]           // Hava durumu bilgileri
    let sonuclar: [String: Any]       // Koşu sonuçları
    let muhtemeller: [String: Any]    // Muhtemel sonuçlar/tahminler
    let jokeyler: [String: Any]       // Jokey bilgileri
    let agf: [String: Any]            // AGF (Altılı Ganyan) bilgileri
    let program: [String: Any]        // Program bilgileri
    let ganyan: [String: Any]         // Ganyan sonuçları
    let ikili: [String: Any]          // İkili bahis sonuçları
    let uclu: [String: Any]           // Üçlü bahis sonuçları
    let plase: [String: Any]          // Plase sonuçları
    let aptalon: [String: Any]        // Aptalon sonuçları
    let allKeys: [String: Any]        // Tüm veriler (extra keyler için)
}



