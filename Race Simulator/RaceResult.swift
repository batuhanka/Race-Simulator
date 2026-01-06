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
    let AD: String?             // At Adı
    let NO: String?             // Kapı Numarası
    let JOKEYADI: String?       // Jokey
    let SONUC: String?          // Derece (1, 2, 3...)
    let DERECE: String?         // Bitiriş Süresi
    let GANYAN: String?         // Ganyan Oranı
    let FARK: String?           // Bitiriş Farkı
    let KILO: Double?              // Kilo (Double veya Int olabilir, JSON'da sayı ise Int güvenlidir)
    let START: String?          // Start No
    let ANTRENORADI: String?    // Antrenör
    let SAHIPADI: String?       // Sahibi
    let FORMA: String?          // Forma Görsel URL (Hatanın sebebi buydu)
    let TAKI: String?           // Takıları (KG, DB vb.)

    var rankInt: Int {
        Int(SONUC ?? "999") ?? 999
    }
}
