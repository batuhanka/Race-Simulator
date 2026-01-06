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
    
}


