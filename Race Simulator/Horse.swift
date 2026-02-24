//
//  Horse.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//


import Foundation
import SwiftUI

struct Horse: Identifiable, Codable {
    var id: String { KOD! }
    
    let KOD: String?
    let KEY: String?
    let NO: String?
    let SONUC: String?
    let AD: String?
    let ADKUCUK: String?
    let START: String?
    let YAS: String?
    let YAS_EN: String?
    let KILO: Double?
    let FAZLAKILO: Int?
    let APRANTIKILOINDIRIMI: Int?
    let FARK: String?
    let GECCIKIS_BOY: String?
    let DERECE: String?
    let GANYAN: String?
    let BABA: String?
    let ANNE: String?
    let ANNEBABA: String?
    let JOKEYADI: String?
    let SAHIPADI: String?
    let ANTRENORADI: String?
    let BABAKODU: String?
    let ANNEKODU: String?
    let JOKEYKODU: String?
    let SAHIPKODU: String?
    let ANTRENORKODU: String?
    let HANDIKAP: String?
    let KGS: String?
    let FORMA: String?
    let SON20: String?
    let KOSMAZ: Bool?
    let APRANTIFLG: Bool?
    let EKURI: String?
    let TAKI: String?
    let AGF1: String?
    let AGFSIRA1: Int?
    let AGF2: String?
    let AGFSIRA2: Int?
    let ENIYIDERECE: String?
    let ENIYIDERECEACIKLAMA: String?
    let YETISTIRICI: String?
    let YETISTIRICIADI: String?
    let SATISBEDELI: String?
    let SON6: String?
    let SON6HTML: String?
    let SON6_ARR: [Son6Item]?
    let TAKI_ARR: [TakiItem]?
    
    var DON: String {
        guard let yas = YAS else { return "" }
        let lowerYas = yas.lowercased()
        let parts = lowerYas.split(separator: " ")
        
        if parts.count >= 2 {
            return String(parts[1])
        } else {
            if lowerYas.contains(" k ") { return "k" }
            else if lowerYas.contains(" a ") { return "a" }
            else if lowerYas.contains(" d ") { return "d" }
            else if lowerYas.contains(" y ") { return "y" }
        }
        return ""
    }
    
    var coatTheme: (bg: Color, fg: Color) {
        let donRengi = self.DON
        
        var age = 3
        if let yasStr = self.YAS {
            let parts = yasStr.lowercased().split(separator: " ")
            if let firstPart = parts.first {
                let ageNumStr = firstPart.replacingOccurrences(of: "y", with: "")
                age = Int(ageNumStr) ?? 3
            }
        }
        
        let clampedAge = min(max(Double(age), 2.0), 10.0)
        let fadeFactor = donRengi == "k" ? 0.05 : 0.04
        let calculatedOpacity = max(0.60, 0.95 - ((clampedAge - 2.0) * fadeFactor))
        
        switch donRengi {
        case "k": return (Color.gray.opacity(calculatedOpacity), .white)         // Kır
        case "a": return (Color.orange.opacity(calculatedOpacity), .white)       // Al
        case "d": return (Color.brown.opacity(calculatedOpacity), .white)        // Doru
        case "y": return (Color.black.opacity(calculatedOpacity), .white)        // Yağız
        default: return (.clear, .secondary)
        }
    }
    
    struct Son6Item: Codable {
        let text: String?
    }
    
    struct TakiItem: Codable {
        let key: String?
        let description: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case KOD, KEY, NO, SONUC, AD, ADKUCUK, START, YAS, YAS_EN, KILO, FAZLAKILO, APRANTIKILOINDIRIMI, FARK, GECCIKIS_BOY, DERECE, GANYAN, BABA, ANNE, ANNEBABA, JOKEYADI, SAHIPADI, ANTRENORADI, BABAKODU, ANNEKODU, JOKEYKODU, SAHIPKODU, ANTRENORKODU, HANDIKAP, KGS, FORMA, SON20, KOSMAZ, APRANTIFLG, EKURI, TAKI, AGF1, AGFSIRA1, AGF2, AGFSIRA2, ENIYIDERECE, ENIYIDERECEACIKLAMA, YETISTIRICI, YETISTIRICIADI, SATISBEDELI, SON6, SON6HTML, SON6_ARR, TAKI_ARR
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        KOD = try? container.decode(String.self, forKey: .KOD)
        KEY = try? container.decode(String.self, forKey: .KEY)
        NO = try? container.decode(String.self, forKey: .NO)
        SONUC = try? container.decode(String.self, forKey: .SONUC)
        AD = try? container.decode(String.self, forKey: .AD)
        ADKUCUK = try? container.decode(String.self, forKey: .ADKUCUK)
        START = try? container.decode(String.self, forKey: .START)
        YAS = try? container.decode(String.self, forKey: .YAS)
        YAS_EN = try? container.decode(String.self, forKey: .YAS_EN)
        KILO = try? container.decode(Double.self, forKey: .KILO)
        FAZLAKILO = try? container.decode(Int.self, forKey: .FAZLAKILO)
        APRANTIKILOINDIRIMI = try? container.decode(Int.self, forKey: .APRANTIKILOINDIRIMI)
        FARK = try? container.decode(String.self, forKey: .FARK)
        GECCIKIS_BOY = try? container.decode(String.self, forKey: .GECCIKIS_BOY)
        DERECE = try? container.decode(String.self, forKey: .DERECE)
        GANYAN = try? container.decode(String.self, forKey: .GANYAN)
        BABA = try? container.decode(String.self, forKey: .BABA)
        ANNE = try? container.decode(String.self, forKey: .ANNE)
        ANNEBABA = try? container.decode(String.self, forKey: .ANNEBABA)
        JOKEYADI = try? container.decode(String.self, forKey: .JOKEYADI)
        SAHIPADI = try? container.decode(String.self, forKey: .SAHIPADI)
        ANTRENORADI = try? container.decode(String.self, forKey: .ANTRENORADI)
        BABAKODU = try? container.decode(String.self, forKey: .BABAKODU)
        ANNEKODU = try? container.decode(String.self, forKey: .ANNEKODU)
        JOKEYKODU = try? container.decode(String.self, forKey: .JOKEYKODU)
        SAHIPKODU = try? container.decode(String.self, forKey: .SAHIPKODU)
        ANTRENORKODU = try? container.decode(String.self, forKey: .ANTRENORKODU)
        HANDIKAP = try? container.decode(String.self, forKey: .HANDIKAP)
        KGS = try? container.decode(String.self, forKey: .KGS)
        let rawForma = try? container.decode(String.self, forKey: .FORMA)
        self.FORMA = rawForma?.replacingOccurrences(of: "http://medya.tjk.org", with: "https://medya-cdn.tjk.org")
        SON20 = try? container.decode(String.self, forKey: .SON20)
        KOSMAZ = try? container.decode(Bool.self, forKey: .KOSMAZ)
        APRANTIFLG = try? container.decode(Bool.self, forKey: .APRANTIFLG)
        if let boolValue = try? container.decode(Bool.self, forKey: .EKURI) {
            EKURI = boolValue ? nil : "false"
        } else if let stringValue = try? container.decode(String.self, forKey: .EKURI) {
            EKURI = stringValue
        } else {
            EKURI = nil
        }
        TAKI = try? container.decode(String.self, forKey: .TAKI)
        AGF1 = try? container.decode(String.self, forKey: .AGF1)
        AGFSIRA1 = try? container.decode(Int.self, forKey: .AGFSIRA1)
        AGF2 = try? container.decode(String.self, forKey: .AGF2)
        AGFSIRA2 = try? container.decode(Int.self, forKey: .AGFSIRA2)
        ENIYIDERECE = try? container.decode(String.self, forKey: .ENIYIDERECE)
        ENIYIDERECEACIKLAMA = try? container.decode(String.self, forKey: .ENIYIDERECEACIKLAMA)
        YETISTIRICI = try? container.decode(String.self, forKey: .YETISTIRICI)
        YETISTIRICIADI = try? container.decode(String.self, forKey: .YETISTIRICIADI)
        SATISBEDELI = try? container.decode(String.self, forKey: .SATISBEDELI)
        SON6 = try? container.decode(String.self, forKey: .SON6)
        SON6HTML = try? container.decode(String.self, forKey: .SON6HTML)
        SON6_ARR = try? container.decode([Son6Item].self, forKey: .SON6_ARR)
        TAKI_ARR = try? container.decode([TakiItem].self, forKey: .TAKI_ARR)
    }
    
    // Horse.swift içindeki init(from decoder:) metodunun hemen altına bunu yapıştır:
    init(
        KOD: String? = nil, KEY: String? = nil, NO: String? = nil, SONUC: String? = nil,
        AD: String? = nil, ADKUCUK: String? = nil, START: String? = nil, YAS: String? = nil,
        YAS_EN: String? = nil, KILO: Double? = nil, FAZLAKILO: Int? = nil,
        APRANTIKILOINDIRIMI: Int? = nil, FARK: String? = nil, GECCIKIS_BOY: String? = nil,
        DERECE: String? = nil, GANYAN: String? = nil, BABA: String? = nil,
        ANNE: String? = nil, ANNEBABA: String? = nil, JOKEYADI: String? = nil,
        SAHIPADI: String? = nil, ANTRENORADI: String? = nil, BABAKODU: String? = nil,
        ANNEKODU: String? = nil, JOKEYKODU: String? = nil, SAHIPKODU: String? = nil,
        ANTRENORKODU: String? = nil, HANDIKAP: String? = nil, KGS: String? = nil,
        FORMA: String? = nil, SON20: String? = nil, KOSMAZ: Bool? = nil, APRANTIFLG: Bool? = nil,
        EKURI: String? = nil, TAKI: String? = nil, AGF1: String? = nil, AGFSIRA1: Int? = nil, AGF2: String? = nil, AGFSIRA2: Int? = nil,
        ENIYIDERECE: String? = nil,
        ENIYIDERECEACIKLAMA: String? = nil, YETISTIRICI: String? = nil,
        YETISTIRICIADI: String? = nil, SATISBEDELI: String? = nil, SON6: String? = nil,
        SON6HTML: String? = nil, SON6_ARR: [Son6Item]? = nil, TAKI_ARR: [TakiItem]? = nil
    ) {
        self.KOD = KOD; self.KEY = KEY; self.NO = NO; self.SONUC = SONUC
        self.AD = AD; self.ADKUCUK = ADKUCUK; self.START = START; self.YAS = YAS
        self.YAS_EN = YAS_EN; self.KILO = KILO; self.FAZLAKILO = FAZLAKILO
        self.APRANTIKILOINDIRIMI = APRANTIKILOINDIRIMI; self.FARK = FARK
        self.GECCIKIS_BOY = GECCIKIS_BOY; self.DERECE = DERECE; self.GANYAN = GANYAN
        self.BABA = BABA; self.ANNE = ANNE; self.ANNEBABA = ANNEBABA
        self.JOKEYADI = JOKEYADI; self.SAHIPADI = SAHIPADI; self.ANTRENORADI = ANTRENORADI
        self.BABAKODU = BABAKODU; self.ANNEKODU = ANNEKODU; self.JOKEYKODU = JOKEYKODU
        self.SAHIPKODU = SAHIPKODU; self.ANTRENORKODU = ANTRENORKODU
        self.HANDIKAP = HANDIKAP; self.KGS = KGS;
        self.FORMA = FORMA;
        self.SON20 = SON20;
        self.KOSMAZ = KOSMAZ;
        self.APRANTIFLG = APRANTIFLG;
        self.EKURI = EKURI; self.TAKI = TAKI;
        self.AGF1 = AGF1; self.AGFSIRA1 = AGFSIRA1; self.AGF2 = AGF2; self.AGFSIRA2 = AGFSIRA2;
        self.ENIYIDERECE = ENIYIDERECE; self.ENIYIDERECEACIKLAMA = ENIYIDERECEACIKLAMA
        self.YETISTIRICI = YETISTIRICI; self.YETISTIRICIADI = YETISTIRICIADI
        self.SATISBEDELI = SATISBEDELI; self.SON6 = SON6; self.SON6HTML = SON6HTML
        self.SON6_ARR = SON6_ARR; self.TAKI_ARR = TAKI_ARR
    }
    
}


extension Horse {
    static let example = Horse(
        KOD: "123",
        NO: "1",
        AD: "ATEŞ GALİBİ",
        YAS: "4y k a",
        KILO: 58.5,
        JOKEYADI: "ÖMER FARUK ÖZEN",
        FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg",
        KOSMAZ: true,
        APRANTIFLG: true, 
        EKURI: "1"
    )
}
