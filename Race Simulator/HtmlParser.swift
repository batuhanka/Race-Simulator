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

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HtmlParserError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw HtmlParserError.invalidResponse
        }

        // Türkçe karakterler için encoding
        if let utf8String = String(data: data, encoding: .utf8) {
            return utf8String
        } else if let isoString = String(data: data, encoding: .isoLatin1) {
            return isoString
        } else if let windowsString = String(data: data, encoding: .windowsCP1254) {
            return windowsString
        } else {
            throw HtmlParserError.decodingFailed
        }
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
        let rawInfo = parseKunyeInfo(from: kunyeContainer)
        let stats = parseOzetIstatistikleri(from: kunyeContainer)

        return HorseDetailInfo(
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
            sponsorlukGeliri: rawInfo["Sponsorluk Geliri"],
            ozetIstatistikleri: stats
        )
    }

    private func parseOzetIstatistikleri(from html: String) -> [HorseStatRow] {
        // tablesorter tablosunu bul
        guard let tableStart = html.range(of: "tablesorter") else { return [] }

        // Geriye doğru <table açılışını bul
        var tableOpenIdx: String.Index?
        var searchIdx = tableStart.lowerBound
        while searchIdx > html.startIndex {
            searchIdx = html.index(before: searchIdx)
            if html[searchIdx...].hasPrefix("<table") {
                tableOpenIdx = searchIdx
                break
            }
        }

        guard let openIdx = tableOpenIdx,
              let tableCloseRange = html.range(of: "</table>", range: openIdx..<html.endIndex) else {
            return []
        }

        let tableHTML = String(html[openIdx..<tableCloseRange.upperBound])

        // <tbody> içeriğini al
        guard let bodyContent = findFirst(in: tableHTML, pattern: "<tbody>(.*?)</tbody>", group: 1) else {
            return []
        }

        // Her <tr> satırını parse et
        var rows: [HorseStatRow] = []
        let trMatches = findAll(in: bodyContent, pattern: "<tr[^>]*>(.*?)</tr>", group: 1)

        for tr in trMatches {
            let cells = findTag("td", in: tr)
            guard cells.count >= 8 else { continue }

            let row = HorseStatRow(
                kategori: stripHTMLTags(from: cells[0]).trimmingCharacters(in: .whitespaces),
                kosu:     stripHTMLTags(from: cells[1]).trimmingCharacters(in: .whitespaces),
                birinci:  stripHTMLTags(from: cells[2]).trimmingCharacters(in: .whitespaces),
                ikinci:   stripHTMLTags(from: cells[3]).trimmingCharacters(in: .whitespaces),
                ucuncu:   stripHTMLTags(from: cells[4]).trimmingCharacters(in: .whitespaces),
                dorduncu: stripHTMLTags(from: cells[5]).trimmingCharacters(in: .whitespaces),
                besinci:  stripHTMLTags(from: cells[6]).trimmingCharacters(in: .whitespaces),
                kazanc:   stripHTMLTags(from: cells[7])
                              .replacingOccurrences(of: "t", with: " ₺")
                              .trimmingCharacters(in: .whitespaces)
            )
            if !row.kategori.isEmpty {
                rows.append(row)
            }
        }

        return rows
    }

    private func extractKunyeContainer(from html: String) -> String? {
        let pattern = "<div[^>]*class=\"[^\"]*kunye-container[^\"]*\"[^>]*>(.*?)</div>"

        guard (try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive])) != nil else {
            return nil
        }

        let nsString = html as NSString
        _ = NSRange(location: 0, length: nsString.length)

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

        // Yöntem 1: div row/col yapısı
        let rows = findTag("div", in: html, withClass: "row")
        for row in rows {
            let cols = findTag("div", in: row, withClass: "col")
            if cols.count >= 2 {
                let label = stripHTMLTags(from: cols[0])
                let value = stripHTMLTags(from: cols[1])
                if !label.isEmpty && !value.isEmpty {
                    let cleanLabel = label.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                    info[cleanLabel] = value
                }
            }
        }

        // Yöntem 2: Span key-value yapısı (TJK'nın kullandığı)
        if info.isEmpty {
            var currentIndex = html.startIndex

            while currentIndex < html.endIndex {
                if let keyStartRange = html.range(of: "<span class=\"key\"", range: currentIndex..<html.endIndex) {
                    if let keyEndRange = html.range(of: "</span>", range: keyStartRange.upperBound..<html.endIndex) {
                        let keyContent = html[keyStartRange.upperBound..<keyEndRange.lowerBound]

                        if let contentStart = keyContent.range(of: ">") {
                            let key = String(keyContent[contentStart.upperBound...])
                                .trimmingCharacters(in: .whitespacesAndNewlines)

                            if let valueStartRange = html.range(of: "<span class=\"value\"", range: keyEndRange.upperBound..<html.endIndex) {
                                var searchPos = valueStartRange.upperBound
                                var depth = 1
                                var valueEndPos: String.Index?

                                if let gtPos = html.range(of: ">", range: searchPos..<html.endIndex) {
                                    searchPos = gtPos.upperBound

                                    while searchPos < html.endIndex && depth > 0 {
                                        if let nextSpan = html.range(of: "<span", range: searchPos..<html.endIndex),
                                           let nextClose = html.range(of: "</span>", range: searchPos..<html.endIndex) {
                                            if nextSpan.lowerBound < nextClose.lowerBound {
                                                depth += 1
                                                searchPos = nextSpan.upperBound
                                            } else {
                                                depth -= 1
                                                if depth == 0 { valueEndPos = nextClose.lowerBound }
                                                searchPos = nextClose.upperBound
                                            }
                                        } else if let nextClose = html.range(of: "</span>", range: searchPos..<html.endIndex) {
                                            depth -= 1
                                            if depth == 0 { valueEndPos = nextClose.lowerBound }
                                            searchPos = nextClose.upperBound
                                        } else {
                                            break
                                        }
                                    }

                                    if let valueEnd = valueEndPos {
                                        let rawValue = String(html[gtPos.upperBound..<valueEnd])
                                        let value = decodeHTMLEntities(stripHTMLTags(from: rawValue))
                                            .replacingOccurrences(of: "&nbsp;", with: " ")
                                            .replacingOccurrences(of: "  ", with: " ")
                                            .trimmingCharacters(in: .whitespacesAndNewlines)
                                        let cleanKey = decodeHTMLEntities(key)
                                        if !cleanKey.isEmpty {
                                            info[cleanKey] = value
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
        }

        // Yöntem 3: Tablo yapısı (<table>, <tr>, <td>)
        if info.isEmpty {
            let tableRows = findTag("tr", in: html)
            for row in tableRows {
                let cells = findTag("td", in: row)
                if cells.count >= 2 {
                    let label = stripHTMLTags(from: cells[0]).trimmingCharacters(in: .whitespaces)
                    let value = stripHTMLTags(from: cells[1]).trimmingCharacters(in: .whitespaces)
                    if !label.isEmpty && !value.isEmpty {
                        let cleanLabel = label.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                        info[cleanLabel] = value
                    }
                }
            }
        }

        // Yöntem 4: <strong> tag'lı label'lar
        if info.isEmpty {
            let strongPattern = "<strong[^>]*>([^<]+)</strong>\\s*([^<]+)"
            if let regex = try? NSRegularExpression(pattern: strongPattern, options: []) {
                let nsString = html as NSString
                let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
                for match in matches where match.numberOfRanges >= 3 {
                    let label = nsString.substring(with: match.range(at: 1))
                    let value = nsString.substring(with: match.range(at: 2))
                    let cleanLabel = label.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                    let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !cleanLabel.isEmpty && !cleanValue.isEmpty {
                        info[cleanLabel] = cleanValue
                    }
                }
            }
        }

        // Yöntem 5: Tüm label tag'leri
        if info.isEmpty {
            let allLabels = findTag("label", in: html)
            for label in allLabels {
                let labelText = stripHTMLTags(from: label)
                if let labelRange = html.range(of: label) {
                    let afterLabel = String(html[labelRange.upperBound...])
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

    // MARK: - Koşu Geçmişi Parser
    public func parseAtKosuGecmisi(atId: String) async throws -> [HorseRaceHistoryRow] {
        let urlString = "https://www.tjk.org/TR/YarisSever/Query/ConnectedPage/AtKosuBilgileri?QueryParameter_Yil=-1&QueryParameter_SehirId=-1&QueryParameter_PistKodu=-1&QueryParameter_MesafeStart=-1&QueryParameter_MesafeEnd=-1&QueryParameter_Kosmaz=on&Sort=&OldQueryParameter_AtId=\(atId)"
        let html = try await fetchHTML(from: urlString)
        return parseQueryTable(from: html)
    }

    private func parseQueryTable(from html: String) -> [HorseRaceHistoryRow] {
        // id="queryTable" olan tabloyu bul
        guard let qtRange = html.range(of: "id=\"queryTable\"") else { return [] }

        // Geriye doğru <table açılışını bul
        var tableStart: String.Index?
        var searchIdx = qtRange.lowerBound
        while searchIdx > html.startIndex {
            searchIdx = html.index(before: searchIdx)
            if html[searchIdx...].hasPrefix("<table") { tableStart = searchIdx; break }
        }
        guard let tStart = tableStart,
              let tableEnd = html.range(of: "</table>", range: tStart..<html.endIndex) else { return [] }

        let tableHTML = String(html[tStart..<tableEnd.upperBound])

        // tbody içeriğini al
        guard let tbodyContent = findFirst(in: tableHTML, pattern: "<tbody[^>]*>(.*?)</tbody>", group: 1) else { return [] }

        // Her tr satırını parse et
        let trMatches = findAll(in: tbodyContent, pattern: "<tr[^>]*>(.*?)</tr>", group: 1)
        var rows: [HorseRaceHistoryRow] = []

        for tr in trMatches {
            let cells = findTag("td", in: tr)
            guard cells.count >= 19 else { continue }  // colspan footer satırını atla

            let tarih    = stripHTMLTags(from: cells[0]).trimmingCharacters(in: .whitespacesAndNewlines)
            let sehir    = stripHTMLTags(from: cells[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            let mesafe   = stripHTMLTags(from: cells[2]).trimmingCharacters(in: .whitespacesAndNewlines)
            let pist     = stripHTMLTags(from: cells[3]).trimmingCharacters(in: .whitespacesAndNewlines)
            let sira     = stripHTMLTags(from: cells[4]).trimmingCharacters(in: .whitespacesAndNewlines)
            let derece   = stripHTMLTags(from: cells[5]).trimmingCharacters(in: .whitespacesAndNewlines)
            let siklet   = stripHTMLTags(from: cells[6]).trimmingCharacters(in: .whitespacesAndNewlines)
            let taki     = stripHTMLTags(from: cells[7]).trimmingCharacters(in: .whitespacesAndNewlines)
            let jokey    = stripHTMLTags(from: cells[8]).trimmingCharacters(in: .whitespacesAndNewlines)
            let startNo  = stripHTMLTags(from: cells[9]).trimmingCharacters(in: .whitespacesAndNewlines)
            let ganyan   = stripHTMLTags(from: cells[10]).trimmingCharacters(in: .whitespacesAndNewlines)
            let grup     = stripHTMLTags(from: cells[11]).trimmingCharacters(in: .whitespacesAndNewlines)
            let kosuNo   = stripHTMLTags(from: cells[12]).trimmingCharacters(in: .whitespacesAndNewlines)
            let kosuCins = stripHTMLTags(from: cells[13]).trimmingCharacters(in: .whitespacesAndNewlines)
            let antrenor = stripHTMLTags(from: cells[14]).trimmingCharacters(in: .whitespacesAndNewlines)
            let sahip    = stripHTMLTags(from: cells[15]).trimmingCharacters(in: .whitespacesAndNewlines)
            let hp       = stripHTMLTags(from: cells[16]).trimmingCharacters(in: .whitespacesAndNewlines)
            let ikramiye = stripHTMLTags(from: cells[17]).trimmingCharacters(in: .whitespacesAndNewlines)
            let s20      = cells.count > 18 ? stripHTMLTags(from: cells[18]).trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let videoUrl = cells.count > 19 ? extractHref(from: cells[19]).map { url in
                url.hasPrefix("http") ? url : "https://www.tjk.org\(url)"
            } : nil
            let fotoUrl  = cells.count > 20 ? extractHref(from: cells[20]) : nil

            let kosmazMi = jokey.contains("Koşmaz") || jokey.contains("Kosmaz")

            guard !tarih.isEmpty else { continue }

            rows.append(HorseRaceHistoryRow(
                tarih: tarih, sehir: sehir, mesafe: mesafe,
                pist: pist, sira: sira, derece: derece,
                siklet: siklet, taki: taki, jokey: jokey,
                startNo: startNo, ganyan: ganyan, grup: grup,
                kosuNo: kosuNo, kosuCins: kosuCins,
                antrenor: antrenor, sahip: sahip,
                ikramiye: ikramiye, hp: hp, s20: s20,
                videoUrl: videoUrl, fotoUrl: fotoUrl,
                kosmazMi: kosmazMi
            ))
        }
        return rows
    }

    /// Video sayfasından CDN mp4 URL'ini çeker
    /// Örnek: var _yrRace = "26021643.mp4" → "https://video-cdn.tjk.org/videoftp/2026/2/26021643.mp4"
    public func fetchVideoUrl(from pageUrl: String) async -> String? {
        guard let html = try? await fetchHTML(from: pageUrl) else { return nil }
        // "_yrRace" bulunduktan sonra ilk tırnak çifti alınır (boşluk farklılıklarına dayanıklı)
        guard let keyRange = html.range(of: "_yrRace") else { return nil }
        let afterKey = html[keyRange.upperBound...]
        guard let q1 = afterKey.firstIndex(of: "\"") else { return nil }
        let afterQ1 = afterKey[afterKey.index(after: q1)...]
        guard let q2 = afterQ1.firstIndex(of: "\"") else { return nil }
        let filename = String(afterQ1[..<q2])
        guard filename.hasSuffix(".mp4"), filename.count >= 6 else { return nil }
        let yearStr = "20" + filename.prefix(2)
        let month   = Int(filename.dropFirst(2).prefix(2)) ?? 0
        guard month > 0 else { return nil }
        return "https://video-cdn.tjk.org/videoftp/\(yearStr)/\(month)/\(filename)"
    }

    private func extractHref(from html: String) -> String? {
        guard let hrefRange = html.range(of: "href=\"") else { return nil }
        let afterHref = html[hrefRange.upperBound...]
        guard let closeQuote = afterHref.firstIndex(of: "\"") else { return nil }
        let href = String(afterHref[..<closeQuote])
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#38;", with: "&")
        return href.isEmpty ? nil : href
    }
}

// MARK: - Models
public struct HorseStatRow: Codable {
    public let kategori: String
    public let kosu: String
    public let birinci: String
    public let ikinci: String
    public let ucuncu: String
    public let dorduncu: String
    public let besinci: String
    public let kazanc: String
    
    public init(kategori: String, kosu: String, birinci: String, ikinci: String, ucuncu: String, dorduncu: String, besinci: String, kazanc: String) {
        self.kategori = kategori
        self.kosu = kosu
        self.birinci = birinci
        self.ikinci = ikinci
        self.ucuncu = ucuncu
        self.dorduncu = dorduncu
        self.besinci = besinci
        self.kazanc = kazanc
    }
}

public struct HorseDetailInfo: Codable {
    public let isim: String
    public let yas: String
    public let dogumTarihi: String
    public let handikap: String
    public let baba: String
    public let anne: String
    public let antrenor: String
    public let gercekSahip: String
    public let uzerineKosanSahip: String?
    public let yetistirici: String
    public let tercihAciklamasi: String?
    public let ikramiye: String
    public let atSahibiPrimi: String
    public let yurtdisiIkramiye: String
    public let kazanc: String
    public let yetistiricilikPrimi: String
    public let sponsorlukGeliri: String?
    public let ozetIstatistikleri: [HorseStatRow]

    public init(
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
        sponsorlukGeliri: String? = nil,
        ozetIstatistikleri: [HorseStatRow] = []
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
        self.ozetIstatistikleri = ozetIstatistikleri
    }
}

public struct HorseRaceHistoryRow: Codable {
    public let tarih: String       // "09.03.2026"
    public let sehir: String       // "Bursa"
    public let mesafe: String      // "1300"
    public let pist: String        // "K:Normal", "S:Nemli", "C:Normal"
    public let sira: String        // "7", "" = koşmaz
    public let derece: String      // "1.34.01"
    public let siklet: String      // "58"
    public let taki: String        // "1 2" (shoe numbers)
    public let jokey: String       // "R.KETME"
    public let startNo: String     // "6" (start position)
    public let ganyan: String      // "4,1"
    public let grup: String        // "A", "B", ""
    public let kosuNo: String      // "3"
    public let kosuCins: String    // "Maiden", "Handikap 15"
    public let antrenor: String    // "M.KAYALI"
    public let sahip: String       // "ÖRNEK AT AHİRİ"
    public let ikramiye: String    // "109.000"
    public let hp: String          // "31"
    public let s20: String         // "16"
    public let videoUrl: String?   // TJK video page URL
    public let fotoUrl: String?    // Finish photo URL
    public let kosmazMi: Bool
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
