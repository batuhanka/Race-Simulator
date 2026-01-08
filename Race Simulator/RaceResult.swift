import Foundation

struct RaceResult: Codable {
    let KOD: String?
    let RACENO: String?
    let BILGI_TR: String?
    let TARIH: String?
    let SAAT: String?
    let PIST: String?
    let MESAFE: String?
    let BAHISLER_TR: String?
    
    // The JSON uses "atlar" instead of "SONUCLAR"
    let atlar: [HorseResult]?
    
    // Alias for your UI logic if you prefer using .sonuclar elsewhere
    var SONUCLAR: [HorseResult]? { atlar }
}

struct HorseResult: Codable, Identifiable {
    var id: String { KEY ?? UUID().uuidString }
    
    let KEY: String?
    let AD: String?
    let NO: String?
    let JOKEYADI: String?
    let SONUC: String?
    let DERECE: String?
    let GANYAN: String?
    let FARK: String?
    let KILO: Double?
    let START: String?
    let ANTRENORADI: String?
    let SAHIPADI: String?
    let FORMA: String?   // will be stored with replaced host
    let TAKI: String?
    let KOSMAZ: Bool?

    var rankInt: Int {
        Int(SONUC ?? "999") ?? 999
    }

    enum CodingKeys: String, CodingKey {
        case KEY, AD, NO, JOKEYADI, SONUC, DERECE, GANYAN, FARK, KILO, START, ANTRENORADI, SAHIPADI, FORMA, TAKI, KOSMAZ
    }

    init(
        KEY: String?,
        AD: String?,
        NO: String?,
        JOKEYADI: String?,
        SONUC: String?,
        DERECE: String?,
        GANYAN: String?,
        FARK: String?,
        KILO: Double?,
        START: String?,
        ANTRENORADI: String?,
        SAHIPADI: String?,
        FORMA: String?,
        TAKI: String?,
        KOSMAZ: Bool?
    ) {
        self.KEY = KEY
        self.AD = AD
        self.NO = NO
        self.JOKEYADI = JOKEYADI
        self.SONUC = SONUC
        self.DERECE = DERECE
        self.GANYAN = GANYAN
        self.FARK = FARK
        self.KILO = KILO
        self.START = START
        self.ANTRENORADI = ANTRENORADI
        self.SAHIPADI = SAHIPADI
        self.FORMA = FORMA
        self.TAKI = TAKI
        self.KOSMAZ = KOSMAZ
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        KEY = try container.decodeIfPresent(String.self, forKey: .KEY)
        AD = try container.decodeIfPresent(String.self, forKey: .AD)
        NO = try container.decodeIfPresent(String.self, forKey: .NO)
        JOKEYADI = try container.decodeIfPresent(String.self, forKey: .JOKEYADI)
        SONUC = try container.decodeIfPresent(String.self, forKey: .SONUC)
        DERECE = try container.decodeIfPresent(String.self, forKey: .DERECE)
        GANYAN = try container.decodeIfPresent(String.self, forKey: .GANYAN)
        FARK = try container.decodeIfPresent(String.self, forKey: .FARK)
        KILO = try container.decodeIfPresent(Double.self, forKey: .KILO)
        START = try container.decodeIfPresent(String.self, forKey: .START)
        ANTRENORADI = try container.decodeIfPresent(String.self, forKey: .ANTRENORADI)
        SAHIPADI = try container.decodeIfPresent(String.self, forKey: .SAHIPADI)
        TAKI = try container.decodeIfPresent(String.self, forKey: .TAKI)
        KOSMAZ = try container.decodeIfPresent(Bool.self, forKey: .KOSMAZ)

        // Replace host in FORMA during decoding
        if let rawForma = try container.decodeIfPresent(String.self, forKey: .FORMA) {
            FORMA = rawForma.replacingOccurrences(of: "http://medya.tjk.org", with: "https://medya-cdn.tjk.org")
        } else {
            FORMA = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(KEY, forKey: .KEY)
        try container.encodeIfPresent(AD, forKey: .AD)
        try container.encodeIfPresent(NO, forKey: .NO)
        try container.encodeIfPresent(JOKEYADI, forKey: .JOKEYADI)
        try container.encodeIfPresent(SONUC, forKey: .SONUC)
        try container.encodeIfPresent(DERECE, forKey: .DERECE)
        try container.encodeIfPresent(GANYAN, forKey: .GANYAN)
        try container.encodeIfPresent(FARK, forKey: .FARK)
        try container.encodeIfPresent(KILO, forKey: .KILO)
        try container.encodeIfPresent(START, forKey: .START)
        try container.encodeIfPresent(ANTRENORADI, forKey: .ANTRENORADI)
        try container.encodeIfPresent(SAHIPADI, forKey: .SAHIPADI)
        try container.encodeIfPresent(FORMA, forKey: .FORMA)
        try container.encodeIfPresent(TAKI, forKey: .TAKI)
        try container.encodeIfPresent(KOSMAZ, forKey: .KOSMAZ)
    }

}
