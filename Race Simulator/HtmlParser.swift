//
//  HtmlParser.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 08.03.2026.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - HTML Parser
/// BeautifulSoup tarzı HTML parsing sınıfı
/// SwiftSoup kullanmadan, native Swift ile basit HTML parsing
class HtmlParser {
    
    // MARK: - Shared Instance
    static let shared = HtmlParser()
    
    private init() {}
    
    // MARK: - Fetch HTML
    /// URL'den HTML içeriğini çeker
    func fetchHTML(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw HtmlParserError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HtmlParserError.invalidResponse
        }
        
        // Türkçe karakterler için encoding
        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw HtmlParserError.decodingFailed
        }
        
        return html
    }
    
    // MARK: - Generic Parsing Functions
    
    /// HTML içinde belirtilen class'a sahip div'i bulur
    func findDiv(in html: String, withClass className: String) -> String? {
        let pattern = "<div[^>]*class=\"[^\"]*\(className)[^\"]*\"[^>]*>(.*?)</div>"
        return findFirst(in: html, pattern: pattern, group: 1)
    }
    
    /// HTML içinde belirtilen ID'ye sahip elementi bulur
    func findElement(in html: String, withId id: String) -> String? {
        let pattern = "<[^>]*id=\"\(id)\"[^>]*>(.*?)</[^>]*>"
        return findFirst(in: html, pattern: pattern, group: 1)
    }
    
    /// HTML içinde belirtilen tag'i bulur
    func findTag(_ tag: String, in html: String, withClass className: String? = nil) -> [String] {
        var pattern = "<\(tag)"
        if let cls = className {
            pattern += "[^>]*class=\"[^\"]*\(cls)[^\"]*\""
        }
        pattern += "[^>]*>(.*?)</\(tag)>"
        
        return findAll(in: html, pattern: pattern, group: 1)
    }
    
    /// İlk eşleşmeyi döndürür
    private func findFirst(in html: String, pattern: String, group: Int = 0) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
            return nil
        }
        
        let nsString = html as NSString
        let range = NSRange(location: 0, length: nsString.length)
        
        guard let match = regex.firstMatch(in: html, options: [], range: range) else {
            return nil
        }
        
        let matchRange = match.range(at: group)
        guard matchRange.location != NSNotFound else { return nil }
        
        return nsString.substring(with: matchRange)
    }
    
    /// Tüm eşleşmeleri döndürür
    private func findAll(in html: String, pattern: String, group: Int = 0) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
            return []
        }
        
        let nsString = html as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: html, options: [], range: range)
        
        return matches.compactMap { match in
            let matchRange = match.range(at: group)
            guard matchRange.location != NSNotFound else { return nil }
            return nsString.substring(with: matchRange)
        }
    }
    
    /// HTML etiketlerini temizler
    func stripHTMLTags(from html: String) -> String {
        var result = html
        
        // HTML etiketlerini kaldır
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // HTML entity'lerini decode et
        result = decodeHTMLEntities(result)
        
        // Fazla boşlukları temizle
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    /// HTML entity'lerini decode eder
    func decodeHTMLEntities(_ html: String) -> String {
        var result = html
        
        let entities: [String: String] = [
            "&nbsp;": " ",
            "&amp;": "&",
            "&quot;": "\"",
            "&apos;": "'",
            "&lt;": "<",
            "&gt;": ">",
            "&#39;": "'",
            "&#199;": "Ç",
            "&#231;": "ç",
            "&#286;": "Ğ",
            "&#287;": "ğ",
            "&#304;": "İ",
            "&#305;": "ı",
            "&#214;": "Ö",
            "&#246;": "ö",
            "&#350;": "Ş",
            "&#351;": "ş",
            "&#220;": "Ü",
            "&#252;": "ü"
        ]
        
        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        
        return result
    }
    
    /// Table'dan veri çeker (key-value pair olarak)
    func parseTable(in html: String) -> [String: String] {
        var result: [String: String] = [:]
        
        // Tüm table row'ları bul
        let rows = findTag("tr", in: html)
        
        for row in rows {
            // Her row'daki td'leri bul
            let cells = findTag("td", in: row)
            
            if cells.count >= 2 {
                let key = stripHTMLTags(from: cells[0])
                let value = stripHTMLTags(from: cells[1])
                result[key] = value
            } else if cells.count == 1 {
                // Tek hücreli satırlar (başlık olabilir)
                let text = stripHTMLTags(from: cells[0])
                if !text.isEmpty {
                    result["_header_\(result.count)"] = text
                }
            }
        }
        
        return result
    }
    
    /// Belirtilen class'a sahip tüm elementleri bulur
    func findElements(in html: String, withClass className: String) -> [String] {
        let pattern = "<[^>]*class=\"[^\"]*\(className)[^\"]*\"[^>]*>(.*?)</[^>]*>"
        return findAll(in: html, pattern: pattern, group: 1)
    }
}

// MARK: - TJK Specific Parser
extension HtmlParser {
    
    /// TJK'daki at bilgilerini parse eder
    func parseAtKosuBilgileri(atId: String) async throws -> HorseDetailInfo {
        let urlString = "https://www.tjk.org/TR/YarisSever/Query/ConnectedPage/AtKosuBilgileri?1=1&QueryParameter_AtId=\(atId)"
        
        let html = try await fetchHTML(from: urlString)
        
        // Künye container'ı bul
        guard let kunyeContainer = extractKunyeContainer(from: html) else {
            throw HtmlParserError.parsingFailed("Künye container bulunamadı")
        }
        
        // Künye bilgilerini parse et
        let kunyeInfo = parseKunyeInfo(from: kunyeContainer)
        
        // İstatistik bilgilerini parse et
        let istatistikInfo = parseIstatistikInfo(from: html)
        
        return HorseDetailInfo(
            kunyeBilgileri: kunyeInfo,
            istatistikBilgileri: istatistikInfo
        )
    }
    
    /// Künye container'ı extract eder
    private func extractKunyeContainer(from html: String) -> String? {
        // Önce künye-container div'ini bul
        let pattern = "<div[^>]*class=\"[^\"]*kunye-container[^\"]*\"[^>]*>(.*?)</div>"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
            return nil
        }
        
        let nsString = html as NSString
        let range = NSRange(location: 0, length: nsString.length)
        
        // Nested div'ler olabileceği için daha gelişmiş bir yaklaşım
        var startIndex: String.Index?
        var openCount = 0
        var foundStart = false
        
        // künye-container'ı bul
        if let kunyeRange = html.range(of: "kunye-container") {
            // Geriye doğru div başlangıcını bul
            var searchIndex = kunyeRange.lowerBound
            while searchIndex > html.startIndex {
                searchIndex = html.index(before: searchIndex)
                if html[searchIndex] == "<" {
                    // Bu bir div mi kontrol et
                    let remainingString = String(html[searchIndex...])
                    if remainingString.hasPrefix("<div") {
                        startIndex = searchIndex
                        foundStart = true
                        break
                    }
                }
            }
            
            if foundStart, let start = startIndex {
                // İleri doğru matching closing div'i bul
                var currentIndex = start
                while currentIndex < html.endIndex {
                    if html[currentIndex...].hasPrefix("<div") {
                        openCount += 1
                    } else if html[currentIndex...].hasPrefix("</div>") {
                        openCount -= 1
                        if openCount == 0 {
                            // Matching closing tag bulundu
                            let endIndex = html.index(currentIndex, offsetBy: 6) // "</div>".count = 6
                            return String(html[start..<endIndex])
                        }
                    }
                    currentIndex = html.index(after: currentIndex)
                }
            }
        }
        
        return nil
    }
    
    /// Künye bilgilerini parse eder
    private func parseKunyeInfo(from html: String) -> [String: String] {
        var info: [String: String] = [:]
        
        // Tüm label-value çiftlerini bul
        let labelPattern = "<label[^>]*>(.*?)</label>"
        let labels = findAll(in: html, pattern: labelPattern, group: 1)
        
        // Değerleri bul
        let rows = findTag("div", in: html, withClass: "row")
        
        for row in rows {
            let cols = findTag("div", in: row, withClass: "col")
            
            if cols.count >= 2 {
                let label = stripHTMLTags(from: cols[0])
                let value = stripHTMLTags(from: cols[1])
                
                if !label.isEmpty && !value.isEmpty {
                    // Label'dan : işaretini temizle
                    let cleanLabel = label.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                    info[cleanLabel] = value
                }
            }
        }
        
        // Eğer row-col yapısı bulunamazsa, alternatif yöntem
        if info.isEmpty {
            let allLabels = findTag("label", in: html)
            for label in allLabels {
                let labelText = stripHTMLTags(from: label)
                // Label'dan sonraki içeriği bul
                if let labelRange = html.range(of: label) {
                    let afterLabel = String(html[labelRange.upperBound...])
                    // İlk closing tag'e kadar olan içeriği al
                    if let valueMatch = findFirst(in: afterLabel, pattern: "^[^<]*(.*?)(?=<)", group: 0) {
                        let value = stripHTMLTags(from: valueMatch)
                        if !value.isEmpty {
                            let cleanLabel = labelText.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                            info[cleanLabel] = value
                        }
                    }
                }
            }
        }
        
        return info
    }
    
    /// İstatistik bilgilerini parse eder
    private func parseIstatistikInfo(from html: String) -> [String: Any] {
        var info: [String: Any] = [:]
        
        // İstatistik tablosunu bul
        let tables = findTag("table", in: html)
        
        for table in tables {
            let tableData = parseTable(in: table)
            info.merge(tableData) { (_, new) in new }
        }
        
        return info
    }
}

// MARK: - Models
struct HorseDetailInfo: Codable {
    var kunyeBilgileri: [String: String]
    var istatistikBilgileri: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case kunyeBilgileri
        case istatistikBilgileri
    }
    
    init(kunyeBilgileri: [String: String], istatistikBilgileri: [String: Any]) {
        self.kunyeBilgileri = kunyeBilgileri
        self.istatistikBilgileri = istatistikBilgileri
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kunyeBilgileri = try container.decode([String: String].self, forKey: .kunyeBilgileri)
        
        // [String: Any] için özel decoding
        if let istatistikDict = try? container.decode([String: String].self, forKey: .istatistikBilgileri) {
            istatistikBilgileri = istatistikDict
        } else {
            istatistikBilgileri = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kunyeBilgileri, forKey: .kunyeBilgileri)
        
        // [String: Any] için basit bir encoding (sadece String değerler)
        let stringDict = istatistikBilgileri.compactMapValues { $0 as? String }
        try container.encode(stringDict, forKey: .istatistikBilgileri)
    }
}

// MARK: - Errors
enum HtmlParserError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case parsingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .invalidResponse:
            return "Geçersiz sunucu yanıtı"
        case .decodingFailed:
            return "HTML decode edilemedi"
        case .parsingFailed(let reason):
            return "Parse hatası: \(reason)"
        }
    }
}
