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
    
}


