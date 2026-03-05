import SwiftUI

// MARK: - API Response Models

struct BetChecksumResponse: Codable {
    let checksum: String
}

struct BetDataResponse: Codable {
    let success: Bool
    let data: BetInnerData
    let checksum: String
    let updatetime: Int?
}

struct BetInnerData: Codable {
    let yarislar: [BetRaceDay]
}

// MARK: - Domain Models

struct BetType: Codable, Identifiable, Hashable {
    var id: String { "\(TYPE)_\(kosular.first ?? 0)_\(kosular.count)" }
    let TYPE: String
    let BAHIS: String
    let POOLUNIT: Int
    let kosular: [Int]
}

struct BetRaceDay: Codable, Identifiable, Hashable {
    var id: String { KEY }
    let CARDID: String?
    let KOD: String
    let KEY: String
    let HIPODROM: String
    let YER: String
    let TARIH: String
    let GUN: String?
    let SIRA: String?
    let ACILIS: String?
    let KAPANIS: String?
    let GECE: Bool?
    let YABANCI: Bool?
    let hava: BetHavaData?
    let pist: BetPistData?
    let kosular: [BetRace]?
    let bahisler: [BetType]
}

struct BetHavaData: Codable, Hashable {
    let KOD: String?
    let DURUM: String?
    let DURUM_EN: String?
    let SICAKLIK: Int?
    let NEM: Int?
}

struct BetPistData: Codable, Hashable {
    let cim: BetPistDetail?
    let kum: BetPistDetail?
    let tapeta: BetPistDetail?
}

struct BetPistDetail: Codable, Hashable {
    let DURUM: String?
    let DURUM_EN: String?
    let AGIRLIK: Int?
}

struct BetRace: Codable, Identifiable, Hashable {
    var id: String { KOD }
    let KOD: String
    let NO: String
    let SAAT: String
    let MESAFE: String
    let PISTKODU: String?
    let PIST: String?
    let PIST_EN: String?
    let KISALTMA: String?
    let GRUP: String?
    let GRUP_EN: String?
    let GRUPKISA: String?
    let CINSDETAY: String?
    let CINSDETAY_EN: String?
    let CINSIYET: String?
    let ONEMLIADI: String?
    let ikramiyeler: [String]?
    let primler: [String]?
    let DOVIZ: String?
    let BILGI: String?
    let BILGI_EN: String?
    let atlar: [BetHorse]?

    enum CodingKeys: String, CodingKey {
        case KOD, NO, SAAT, MESAFE, PISTKODU, PIST, PIST_EN, KISALTMA, GRUP,
            GRUP_EN, GRUPKISA, CINSDETAY, CINSDETAY_EN, CINSIYET, ONEMLIADI,
            ikramiyeler, primler, DOVIZ, BILGI, BILGI_EN, atlar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let kodString = try? container.decode(String.self, forKey: .KOD) {
            KOD = kodString
        } else {
            KOD = String(try container.decode(Int.self, forKey: .KOD))
        }
        if let noString = try? container.decode(String.self, forKey: .NO) {
            NO = noString
        } else {
            NO = String(try container.decode(Int.self, forKey: .NO))
        }
        SAAT = try container.decode(String.self, forKey: .SAAT)
        MESAFE = try container.decode(String.self, forKey: .MESAFE)
        PISTKODU = try container.decodeIfPresent(String.self, forKey: .PISTKODU)
        PIST = try container.decodeIfPresent(String.self, forKey: .PIST)
        PIST_EN = try container.decodeIfPresent(String.self, forKey: .PIST_EN)
        KISALTMA = try container.decodeIfPresent(String.self, forKey: .KISALTMA)
        GRUP = try container.decodeIfPresent(String.self, forKey: .GRUP)
        GRUP_EN = try container.decodeIfPresent(String.self, forKey: .GRUP_EN)
        GRUPKISA = try container.decodeIfPresent(String.self, forKey: .GRUPKISA)
        CINSDETAY = try container.decodeIfPresent(String.self, forKey: .CINSDETAY)
        CINSDETAY_EN = try container.decodeIfPresent(String.self, forKey: .CINSDETAY_EN)
        CINSIYET = try container.decodeIfPresent(String.self, forKey: .CINSIYET)
        ONEMLIADI = try container.decodeIfPresent(String.self, forKey: .ONEMLIADI)
        ikramiyeler = try container.decodeIfPresent([String].self, forKey: .ikramiyeler)
        primler = try container.decodeIfPresent([String].self, forKey: .primler)
        DOVIZ = try container.decodeIfPresent(String.self, forKey: .DOVIZ)
        BILGI = try container.decodeIfPresent(String.self, forKey: .BILGI)
        BILGI_EN = try container.decodeIfPresent(String.self, forKey: .BILGI_EN)
        atlar = try container.decodeIfPresent([BetHorse].self, forKey: .atlar)
    }

    init(KOD: String, NO: String, SAAT: String, MESAFE: String, PISTKODU: String? = nil, PIST: String? = nil, PIST_EN: String? = nil, KISALTMA: String? = nil, GRUP: String? = nil, GRUP_EN: String? = nil, GRUPKISA: String? = nil, CINSDETAY: String? = nil, CINSDETAY_EN: String? = nil, CINSIYET: String? = nil, ONEMLIADI: String? = nil, ikramiyeler: [String]? = nil, primler: [String]? = nil, DOVIZ: String? = nil, BILGI: String? = nil, BILGI_EN: String? = nil, atlar: [BetHorse]? = nil) {
        self.KOD = KOD; self.NO = NO; self.SAAT = SAAT; self.MESAFE = MESAFE
        self.PISTKODU = PISTKODU; self.PIST = PIST; self.PIST_EN = PIST_EN
        self.KISALTMA = KISALTMA; self.GRUP = GRUP; self.GRUP_EN = GRUP_EN
        self.GRUPKISA = GRUPKISA; self.CINSDETAY = CINSDETAY; self.CINSDETAY_EN = CINSDETAY_EN
        self.CINSIYET = CINSIYET; self.ONEMLIADI = ONEMLIADI
        self.ikramiyeler = ikramiyeler; self.primler = primler; self.DOVIZ = DOVIZ
        self.BILGI = BILGI; self.BILGI_EN = BILGI_EN; self.atlar = atlar
    }
}

struct BetHorse: Codable, Identifiable, Hashable {
    var id: String { KOD }
    let KOD: String
    let NO: String
    let AD: String
    let JOKEYADI: String?
    let FORMA: String?
    let KOSMAZ: Bool?
    let AGF1: Double?
    let AGF2: Double?
    let EKURI: String?

    enum CodingKeys: String, CodingKey {
        case KOD, NO, AD, JOKEYADI, FORMA, KOSMAZ, AGF1, AGF2, EKURI
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let kodString = try? container.decode(String.self, forKey: .KOD) {
            KOD = kodString
        } else {
            KOD = String(try container.decode(Int.self, forKey: .KOD))
        }
        if let noString = try? container.decode(String.self, forKey: .NO) {
            NO = noString
        } else {
            NO = String(try container.decode(Int.self, forKey: .NO))
        }
        AD = try container.decode(String.self, forKey: .AD)
        JOKEYADI = try container.decodeIfPresent(String.self, forKey: .JOKEYADI)
        FORMA = try container.decodeIfPresent(String.self, forKey: .FORMA)
        KOSMAZ = try container.decodeIfPresent(Bool.self, forKey: .KOSMAZ)
        AGF1 = try container.decodeIfPresent(Double.self, forKey: .AGF1)
        AGF2 = try container.decodeIfPresent(Double.self, forKey: .AGF2)
        if let stringValue = try? container.decode(String.self, forKey: .EKURI) {
            EKURI = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .EKURI) {
            EKURI = String(intValue)
        } else {
            EKURI = nil
        }
    }

    init(KOD: String, NO: String, AD: String, JOKEYADI: String?, FORMA: String?, KOSMAZ: Bool?, AGF1: Double?, AGF2: Double?, EKURI: String?) {
        self.KOD = KOD; self.NO = NO; self.AD = AD; self.JOKEYADI = JOKEYADI
        self.FORMA = FORMA; self.KOSMAZ = KOSMAZ; self.AGF1 = AGF1
        self.AGF2 = AGF2; self.EKURI = EKURI
    }
}
