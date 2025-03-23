//
//  Horse.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//


import Foundation

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
    let KILO: Int?
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
    let EKURI: Bool?
    let TAKI: String?
    let ENIYIDERECE: String?
    let ENIYIDERECEACIKLAMA: String?
    let YETISTIRICI: String?
    let YETISTIRICIADI: String?
    let SATISBEDELI: String?
    let SON6: String?
    let SON6HTML: String?
    let SON6_ARR: [Son6Item]?
    let TAKI_ARR: [TakiItem]?
    
    struct Son6Item: Codable {
        let text: String?
    }
    
    struct TakiItem: Codable {
        let key: String?
        let description: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case KOD, KEY, NO, SONUC, AD, ADKUCUK, START, YAS, YAS_EN, KILO, FAZLAKILO, APRANTIKILOINDIRIMI, FARK, GECCIKIS_BOY, DERECE, GANYAN, BABA, ANNE, ANNEBABA, JOKEYADI, SAHIPADI, ANTRENORADI, BABAKODU, ANNEKODU, JOKEYKODU, SAHIPKODU, ANTRENORKODU, HANDIKAP, KGS, FORMA, SON20, KOSMAZ, EKURI, TAKI, ENIYIDERECE, ENIYIDERECEACIKLAMA, YETISTIRICI, YETISTIRICIADI, SATISBEDELI, SON6, SON6HTML, SON6_ARR, TAKI_ARR
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
        KILO = try? container.decode(Int.self, forKey: .KILO)
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
        FORMA = try? container.decode(String.self, forKey: .FORMA)
        SON20 = try? container.decode(String.self, forKey: .SON20)
        KOSMAZ = try? container.decode(Bool.self, forKey: .KOSMAZ)
        EKURI = try? container.decode(Bool.self, forKey: .EKURI)
        TAKI = try? container.decode(String.self, forKey: .TAKI)
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
}
