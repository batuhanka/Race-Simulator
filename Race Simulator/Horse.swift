import Foundation

struct Horse: Identifiable, Codable {
    var id: String { KOD }

    let KOD: String
    let KEY: String
    let NO: String
    let SONUC: String
    let AD: String
    let ADKUCUK: String
    let START: String
    let YAS: String
    let YAS_EN: String
    let KILO: Int
    let FAZLAKILO: Int
    let APRANTIKILOINDIRIMI: Int
    let FARK: String
    let GECCIKIS_BOY: String
    let DERECE: String
    let GANYAN: String
    let BABA: String
    let ANNE: String
    let ANNEBABA: String
    let JOKEYADI: String
    let SAHIPADI: String
    let ANTRENORADI: String
    let BABAKODU: String
    let ANNEKODU: String
    let JOKEYKODU: String
    let SAHIPKODU: String
    let ANTRENORKODU: String
    let HANDIKAP: String
    let KGS: String
    let FORMA: String
    let SON20: String
    let KOSMAZ: Bool
    let EKURI: Bool
    let TAKI: String
    let ENIYIDERECE: String
    let ENIYIDERECEACIKLAMA: String
    let YETISTIRICI: String
    let YETISTIRICIADI: String
    let SATISBEDELI: String
    let SON6: String
    let SON6HTML: String
    let SON6_ARR: [Son6Item]
    let TAKI_ARR: [TakiItem]

    struct Son6Item: Codable {
        let text: String
    }

    struct TakiItem: Codable {
        let key: String
        let description: String
    }

    enum CodingKeys: String, CodingKey {
        case KOD, KEY, NO, SONUC, AD, ADKUCUK, START, YAS, YAS_EN, KILO, FAZLAKILO, APRANTIKILOINDIRIMI, FARK, GECCIKIS_BOY, DERECE, GANYAN, BABA, ANNE, ANNEBABA, JOKEYADI, SAHIPADI, ANTRENORADI, BABAKODU, ANNEKODU, JOKEYKODU, SAHIPKODU, ANTRENORKODU, HANDIKAP, KGS, FORMA, SON20, KOSMAZ, EKURI, TAKI, ENIYIDERECE, ENIYIDERECEACIKLAMA, YETISTIRICI, YETISTIRICIADI, SATISBEDELI, SON6, SON6HTML, SON6_ARR, TAKI_ARR
    }
}

