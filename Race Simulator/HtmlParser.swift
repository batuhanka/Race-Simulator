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
        print("🌐 [fetchHTML] URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("🌐 [fetchHTML] ❌ Geçersiz URL")
            throw HtmlParserError.invalidURL
        }
        
        print("🌐 [fetchHTML] URLSession başlatılıyor...")
        let (data, response) = try await URLSession.shared.data(from: url)
        print("🌐 [fetchHTML] ✅ Veri alındı - Boyut: \(data.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("🌐 [fetchHTML] ❌ HTTP Response değil")
            throw HtmlParserError.invalidResponse
        }
        
        print("🌐 [fetchHTML] HTTP Status Code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("🌐 [fetchHTML] ❌ Başarısız status code")
            throw HtmlParserError.invalidResponse
        }
        
        // Türkçe karakterler için encoding
        var html: String?
        
        // Önce UTF-8 dene
        if let utf8String = String(data: data, encoding: .utf8) {
            html = utf8String
            print("🌐 [fetchHTML] ✅ UTF-8 encoding kullanıldı")
        } else if let isoString = String(data: data, encoding: .isoLatin1) {
            html = isoString
            print("🌐 [fetchHTML] ✅ ISO Latin1 encoding kullanıldı")
        } else if let windowsString = String(data: data, encoding: .windowsCP1254) {
            html = windowsString
            print("🌐 [fetchHTML] ✅ Windows CP1254 encoding kullanıldı")
        } else {
            print("🌐 [fetchHTML] ❌ Hiçbir encoding çalışmadı")
            throw HtmlParserError.decodingFailed
        }
        
        guard let finalHtml = html else {
            print("🌐 [fetchHTML] ❌ HTML decode edilemedi")
            throw HtmlParserError.decodingFailed
        }
        
        print("🌐 [fetchHTML] ✅ HTML decode başarılı - Uzunluk: \(finalHtml.count) karakter")
        return finalHtml
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
        
        print("🐴 [DEBUG] Fetching URL: \(urlString)")
        
        let html = try await fetchHTML(from: urlString)
        print("🐴 [DEBUG] HTML uzunluğu: \(html.count) karakter")
        print("🐴 [DEBUG] İlk 500 karakter: \(String(html.prefix(500)))")
        
        // Künye container'ı bul
        guard let kunyeContainer = extractKunyeContainer(from: html) else {
            print("🐴 [DEBUG] ❌ Künye container bulunamadı!")
            print("🐴 [DEBUG] HTML'de 'kunye' araması: \(html.contains("kunye") ? "BULUNDU" : "BULUNAMADI")")
            print("🐴 [DEBUG] HTML'de 'künye' araması: \(html.contains("künye") ? "BULUNDU" : "BULUNAMADI")")
            
            // HTML'deki class isimlerini görelim
            let classPattern = "class=\"([^\"]+)\""
            if let regex = try? NSRegularExpression(pattern: classPattern, options: []) {
                let nsString = html as NSString
                let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
                let classes = matches.compactMap { match -> String? in
                    guard match.numberOfRanges > 1 else { return nil }
                    return nsString.substring(with: match.range(at: 1))
                }
                print("🐴 [DEBUG] Bulunan class'lar (ilk 20): \(Array(Set(classes)).prefix(20))")
            }
            
            throw HtmlParserError.parsingFailed("Künye container bulunamadı")
        }
        
        print("🐴 [DEBUG] ✅ Künye container bulundu! Uzunluk: \(kunyeContainer.count)")
        print("🐴 [DEBUG] Container içeriği (ilk 300 karakter): \(String(kunyeContainer.prefix(300)))")
        print("🐴 [DEBUG] Container içeriği (tam): \(kunyeContainer)")
        
        // Künye bilgilerini parse et
        let rawInfo = parseKunyeInfo(from: kunyeContainer)
        print("🐴 [DEBUG] Parse edilen bilgiler:")
        for (key, value) in rawInfo.sorted(by: { $0.key < $1.key }) {
            print("🐴 [DEBUG]   \(key): \(value)")
        }
        
        // Structured model'e dönüştür
        let result = HorseDetailInfo(
            isim: rawInfo["İsim"] ?? rawInfo["Isim"] ?? "",
            yas: rawInfo["Yaş"] ?? rawInfo["Yas"] ?? "",
            dogumTarihi: rawInfo["Doğ. Trh"] ?? rawInfo["Dog. Trh"] ?? "",
            handikap: rawInfo["Handikap P."] ?? rawInfo["Handikap"] ?? "",
            baba: rawInfo["Baba"] ?? "",
            anne: rawInfo["Anne"] ?? "",
            antrenor: rawInfo["Antrenör"] ?? rawInfo["Antrenor"] ?? "",
            gercekSahip: rawInfo["Gerçek Sahip"] ?? rawInfo["Gercek Sahip"] ?? "",
            uzerineKosanSahip: rawInfo["Üzerine Koşan Sahip"] ?? rawInfo["Uzerine Kosan Sahip"],
            yetistirici: rawInfo["Yetiştirici"] ?? rawInfo["Yetistirici"] ?? "",
            tercihAciklamasi: rawInfo["Tercih Açıklaması"] ?? rawInfo["Tercih Aciklamasi"],
            ikramiye: rawInfo["Ikramiye"] ?? "",
            atSahibiPrimi: rawInfo["At Sahibi Primi"] ?? "",
            yurtdisiIkramiye: rawInfo["Yurtdışı Ikramiye"] ?? rawInfo["Yurtdisi Ikramiye"] ?? "",
            kazanc: rawInfo["Kazanç"] ?? rawInfo["Kazanc"] ?? "",
            yetistiricilikPrimi: rawInfo["Yetiştiricilik Primi"] ?? rawInfo["Yetistiricilik Primi"] ?? "",
            sponsorlukGeliri: rawInfo["Sponsorluk Geliri"]
        )
        
        print("🐴 [DEBUG] ✅ Model oluşturuldu:")
        print("🐴 [DEBUG]   İsim: \(result.isim)")
        print("🐴 [DEBUG]   Yaş: \(result.yas)")
        print("🐴 [DEBUG]   Baba: \(result.baba)")
        
        return result
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
        
        print("🔍 [DEBUG] parseKunyeInfo çağrıldı, HTML uzunluğu: \(html.count)")
        
        // Tüm label-value çiftlerini bul
        let labelPattern = "<label[^>]*>(.*?)</label>"
        let labels = findAll(in: html, pattern: labelPattern, group: 1)
        print("🔍 [DEBUG] Bulunan label sayısı: \(labels.count)")
        print("🔍 [DEBUG] Label'lar: \(labels)")
        
        // Değerleri bul
        let rows = findTag("div", in: html, withClass: "row")
        print("🔍 [DEBUG] Bulunan row sayısı: \(rows.count)")
        
        for (index, row) in rows.enumerated() {
            print("🔍 [DEBUG] Row \(index) içeriği (ilk 200 karakter): \(String(row.prefix(200)))")
            
            let cols = findTag("div", in: row, withClass: "col")
            print("🔍 [DEBUG] Row \(index) col sayısı: \(cols.count)")
            
            if cols.count >= 2 {
                let label = stripHTMLTags(from: cols[0])
                let value = stripHTMLTags(from: cols[1])
                
                print("🔍 [DEBUG] Row \(index) - Label: '\(label)', Value: '\(value)'")
                
                if !label.isEmpty && !value.isEmpty {
                    // Label'dan : işaretini temizle
                    let cleanLabel = label.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                    info[cleanLabel] = value
                    print("🔍 [DEBUG] ✅ Eklendi: '\(cleanLabel)' = '\(value)'")
                }
            }
        }
        
        print("🔍 [DEBUG] Yöntem 1-2'den bulunan bilgi sayısı: \(info.count)")
        
        // Yöntem 2.5: Span key-value yapısı (TJK'nın kullandığı)
        if info.isEmpty {
            print("🔍 [DEBUG] ⚠️ Yöntem 2.5 deneniyor: Span key-value parsing...")
            
            // Manuel parsing - daha güvenilir
            var currentIndex = html.startIndex
            var spanCount = 0
            
            while currentIndex < html.endIndex {
                // <span class="key"> ara
                if let keyStartRange = html.range(of: "<span class=\"key\"", range: currentIndex..<html.endIndex) {
                    // Key'in sonunu bul
                    if let keyEndRange = html.range(of: "</span>", range: keyStartRange.upperBound..<html.endIndex) {
                        // Key içeriğini al
                        let keyContent = html[keyStartRange.upperBound..<keyEndRange.lowerBound]
                        
                        // > işaretinden sonrasını al (tag içeriği)
                        if let contentStart = keyContent.range(of: ">") {
                            let key = String(keyContent[contentStart.upperBound...])
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Şimdi value span'ını ara
                            if let valueStartRange = html.range(of: "<span class=\"value\"", range: keyEndRange.upperBound..<html.endIndex) {
                                // Value'nun sonunu bul - nested span'lar olabilir
                                var searchPos = valueStartRange.upperBound
                                var depth = 1
                                var valueEndPos: String.Index?
                                
                                // > işaretini atla
                                if let gtPos = html.range(of: ">", range: searchPos..<html.endIndex) {
                                    searchPos = gtPos.upperBound
                                    
                                    // Nested span'ları say
                                    while searchPos < html.endIndex && depth > 0 {
                                        if let nextSpan = html.range(of: "<span", range: searchPos..<html.endIndex),
                                           let nextClose = html.range(of: "</span>", range: searchPos..<html.endIndex) {
                                            if nextSpan.lowerBound < nextClose.lowerBound {
                                                depth += 1
                                                searchPos = nextSpan.upperBound
                                            } else {
                                                depth -= 1
                                                if depth == 0 {
                                                    valueEndPos = nextClose.lowerBound
                                                }
                                                searchPos = nextClose.upperBound
                                            }
                                        } else if let nextClose = html.range(of: "</span>", range: searchPos..<html.endIndex) {
                                            depth -= 1
                                            if depth == 0 {
                                                valueEndPos = nextClose.lowerBound
                                            }
                                            searchPos = nextClose.upperBound
                                        } else {
                                            break
                                        }
                                    }
                                    
                                    if let valueEnd = valueEndPos {
                                        let rawValue = String(html[gtPos.upperBound..<valueEnd])
                                        
                                        // HTML'i decode et
                                        let value = decodeHTMLEntities(stripHTMLTags(from: rawValue))
                                            .replacingOccurrences(of: "&nbsp;", with: " ")
                                            .replacingOccurrences(of: "  ", with: " ")
                                            .trimmingCharacters(in: .whitespacesAndNewlines)
                                        
                                        let cleanKey = decodeHTMLEntities(key)
                                        
                                        print("🔍 [DEBUG] Span \(spanCount) - Key: '\(cleanKey)', Value: '\(value)'")
                                        spanCount += 1
                                        
                                        if !cleanKey.isEmpty {
                                            info[cleanKey] = value
                                            print("🔍 [DEBUG] ✅ Span'dan eklendi: '\(cleanKey)' = '\(value)'")
                                        }
                                        
                                        currentIndex = searchPos
                                        continue
                                    }
                                }
                            }
                        }
                    }
                    currentIndex = html.index(after: keyStartRange.lowerBound)
                } else {
                    break
                }
            }
            
            print("🔍 [DEBUG] Toplam span çifti bulundu: \(spanCount)")
        }
        
        print("🔍 [DEBUG] Yöntem 2.5'ten sonra bilgi sayısı: \(info.count)")
        
        // Yöntem 3: Tablo yapısı (<table>, <tr>, <td>)
        if info.isEmpty {
            print("🔍 [DEBUG] ⚠️ Yöntem 3 deneniyor: Table parsing...")
            
            let tableRows = findTag("tr", in: html)
            print("🔍 [DEBUG] Bulunan table row sayısı: \(tableRows.count)")
            
            for (index, row) in tableRows.enumerated() {
                let cells = findTag("td", in: row)
                print("🔍 [DEBUG] TR \(index) cell sayısı: \(cells.count)")
                
                if cells.count >= 2 {
                    let label = stripHTMLTags(from: cells[0]).trimmingCharacters(in: .whitespaces)
                    let value = stripHTMLTags(from: cells[1]).trimmingCharacters(in: .whitespaces)
                    
                    print("🔍 [DEBUG] TR \(index) - Label: '\(label)', Value: '\(value)'")
                    
                    if !label.isEmpty && !value.isEmpty {
                        let cleanLabel = label.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                        info[cleanLabel] = value
                        print("🔍 [DEBUG] ✅ Table'dan eklendi: '\(cleanLabel)' = '\(value)'")
                    }
                }
            }
        }
        
        print("🔍 [DEBUG] Yöntem 3'ten sonra bilgi sayısı: \(info.count)")
        
        // Yöntem 4: <strong> veya <b> tag'lı label'lar
        if info.isEmpty {
            print("🔍 [DEBUG] ⚠️ Yöntem 4 deneniyor: Strong/B tag parsing...")
            
            let strongPattern = "<strong[^>]*>([^<]+)</strong>\\s*([^<]+)"
            if let regex = try? NSRegularExpression(pattern: strongPattern, options: []) {
                let nsString = html as NSString
                let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
                
                print("🔍 [DEBUG] Strong tag matches: \(matches.count)")
                
                for (index, match) in matches.enumerated() {
                    if match.numberOfRanges >= 3 {
                        let label = nsString.substring(with: match.range(at: 1))
                        let value = nsString.substring(with: match.range(at: 2))
                        
                        let cleanLabel = label.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        print("🔍 [DEBUG] Strong \(index) - Label: '\(cleanLabel)', Value: '\(cleanValue)'")
                        
                        if !cleanLabel.isEmpty && !cleanValue.isEmpty {
                            info[cleanLabel] = cleanValue
                            print("🔍 [DEBUG] ✅ Strong'dan eklendi: '\(cleanLabel)' = '\(cleanValue)'")
                        }
                    }
                }
            }
        }
        
        print("🔍 [DEBUG] Yöntem 4'ten sonra bilgi sayısı: \(info.count)")
        
        // Yöntem 5: Alternatif - tüm label tag'leri
        if info.isEmpty {
            print("🔍 [DEBUG] ⚠️ Yöntem 5 deneniyor: Tüm label'lar...")
            
            let allLabels = findTag("label", in: html)
            print("🔍 [DEBUG] Alternatif yöntem - bulunan label sayısı: \(allLabels.count)")
            
            for (index, label) in allLabels.enumerated() {
                let labelText = stripHTMLTags(from: label)
                print("🔍 [DEBUG] Alt. Label \(index): '\(labelText)'")
                
                if let labelRange = html.range(of: label) {
                    let afterLabel = String(html[labelRange.upperBound...])
                    if let valueMatch = findFirst(in: afterLabel, pattern: "^[^<]*(.*?)(?=<)", group: 0) {
                        let value = stripHTMLTags(from: valueMatch)
                        print("🔍 [DEBUG] Alt. Value \(index): '\(value)'")
                        
                        if !value.isEmpty {
                            let cleanLabel = labelText.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                            info[cleanLabel] = value
                            print("🔍 [DEBUG] ✅ Alternatif yöntemle eklendi: '\(cleanLabel)' = '\(value)'")
                        }
                    }
                }
            }
        }
        
        print("🔍 [DEBUG] Toplam parse edilen bilgi sayısı: \(info.count)")
        return info
    }
}

// MARK: - Models
struct HorseDetailInfo: Codable {
    let isim: String
    let yas: String
    let dogumTarihi: String
    let handikap: String
    let baba: String
    let anne: String
    let antrenor: String
    let gercekSahip: String
    let uzerineKosanSahip: String?
    let yetistirici: String
    let tercihAciklamasi: String?
    let ikramiye: String
    let atSahibiPrimi: String
    let yurtdisiIkramiye: String
    let kazanc: String
    let yetistiricilikPrimi: String
    let sponsorlukGeliri: String?
    
    init(
        isim: String = "",
        yas: String = "",
        dogumTarihi: String = "",
        handikap: String = "",
        baba: String = "",
        anne: String = "",
        antrenor: String = "",
        gercekSahip: String = "",
        uzerineKosanSahip: String? = nil,
        yetistirici: String = "",
        tercihAciklamasi: String? = nil,
        ikramiye: String = "",
        atSahibiPrimi: String = "",
        yurtdisiIkramiye: String = "",
        kazanc: String = "",
        yetistiricilikPrimi: String = "",
        sponsorlukGeliri: String? = nil
    ) {
        self.isim = isim
        self.yas = yas
        self.dogumTarihi = dogumTarihi
        self.handikap = handikap
        self.baba = baba
        self.anne = anne
        self.antrenor = antrenor
        self.gercekSahip = gercekSahip
        self.uzerineKosanSahip = uzerineKosanSahip
        self.yetistirici = yetistirici
        self.tercihAciklamasi = tercihAciklamasi
        self.ikramiye = ikramiye
        self.atSahibiPrimi = atSahibiPrimi
        self.yurtdisiIkramiye = yurtdisiIkramiye
        self.kazanc = kazanc
        self.yetistiricilikPrimi = yetistiricilikPrimi
        self.sponsorlukGeliri = sponsorlukGeliri
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
