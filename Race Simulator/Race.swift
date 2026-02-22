//
//  Race.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 20.03.2025.
//

import Foundation

struct Race: Decodable, Identifiable {
    var id: String { KOD } 
    
    let NO: String?
    let KOD: String
    let TARIH: String?
    let SAAT: String?
    let MESAFE: String?
    let PIST: String?
    let PISTADI_TR: String?
    let PISTADI_EN: String?
    let ActiveClass: String?
    let RACENO: String?
    let KISALTMA: String?
    let GRUP_TR: String?
    let GRUP_EN: String?
    let GRUPKISA: String?
    let CINSDETAY_TR: String?
    let CINSDETAY_EN: String?
    let CINSIYET: String?
    let BILGI_TR: String?
    let BILGI_EN: String?
    let ENIYIDERECE: String?
    let ENIYIDERECEACIKLAMA: String?
    let ONEMLIKOSUADI_TR: Bool
    let ONEMLIKOSUADI_EN: Bool
    let OZELADI: Bool
    let APRANTI: Bool
    let SON800: String?
    let DOVIZ: String?
    let ikramiyeler: [String]?
    let primler: [String]?
    let BAHISLER_TR: String?
    let BAHISLER_EN: String?
    let emiParasalNeticeler_tr: String?
    let emiParasalNeticeler_en: String?
    let emiParasalNeticelerAgfResults: [String]?
    let FOTOFINISH: String?
    let VIDEO: String?
    let emiVideoFile: String?
    let emiVideoUrl: String?
    let emiPhotoFile: String?
    let emiFotoUrl: String?
    let emiRunDate: String?
    let hasSatisbedeli: Bool
    let hasNonRunner: Bool
    let atlar: [Horse]?
    
    enum CodingKeys: String, CodingKey {
        case NO, KOD, TARIH, SAAT, MESAFE, PIST, PISTADI_TR, PISTADI_EN, ActiveClass, RACENO, KISALTMA, GRUP_TR, GRUP_EN, GRUPKISA, CINSDETAY_TR, CINSDETAY_EN, CINSIYET, BILGI_TR, BILGI_EN, ENIYIDERECE, ENIYIDERECEACIKLAMA, ONEMLIKOSUADI_TR, ONEMLIKOSUADI_EN, OZELADI, APRANTI, SON800, DOVIZ, ikramiyeler, primler, BAHISLER_TR, BAHISLER_EN, emiParasalNeticeler_tr, emiParasalNeticeler_en, emiParasalNeticelerAgfResults, FOTOFINISH, VIDEO, emiVideoFile, emiVideoUrl, emiPhotoFile, emiFotoUrl, emiRunDate, hasSatisbedeli, hasNonRunner, atlar
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode basic fields safely
        NO = try? container.decodeIfPresent(String.self, forKey: .NO)
        KOD = (try? container.decode(String.self, forKey: .KOD)) ?? ""
        TARIH = try? container.decodeIfPresent(String.self, forKey: .TARIH)
        SAAT = try? container.decodeIfPresent(String.self, forKey: .SAAT)
        MESAFE = try? container.decodeIfPresent(String.self, forKey: .MESAFE)
        PIST = try? container.decodeIfPresent(String.self, forKey: .PIST)
        PISTADI_TR = try? container.decodeIfPresent(String.self, forKey: .PISTADI_TR)
        PISTADI_EN = try? container.decodeIfPresent(String.self, forKey: .PISTADI_EN)
        ActiveClass = try? container.decodeIfPresent(String.self, forKey: .ActiveClass)
        RACENO = try? container.decodeIfPresent(String.self, forKey: .RACENO)
        KISALTMA = try? container.decodeIfPresent(String.self, forKey: .KISALTMA)
        GRUP_TR = try? container.decodeIfPresent(String.self, forKey: .GRUP_TR)
        GRUP_EN = try? container.decodeIfPresent(String.self, forKey: .GRUP_EN)
        GRUPKISA = try? container.decodeIfPresent(String.self, forKey: .GRUPKISA)
        CINSDETAY_TR = try? container.decodeIfPresent(String.self, forKey: .CINSDETAY_TR)
        CINSDETAY_EN = try? container.decodeIfPresent(String.self, forKey: .CINSDETAY_EN)
        CINSIYET = try? container.decodeIfPresent(String.self, forKey: .CINSIYET)
        BILGI_TR = try? container.decodeIfPresent(String.self, forKey: .BILGI_TR)
        BILGI_EN = try? container.decodeIfPresent(String.self, forKey: .BILGI_EN)
        ENIYIDERECE = try? container.decodeIfPresent(String.self, forKey: .ENIYIDERECE)
        ENIYIDERECEACIKLAMA = try? container.decodeIfPresent(String.self, forKey: .ENIYIDERECEACIKLAMA)
        
        // Safely decode Bool values (custom handling of String/empty/null cases)
        ONEMLIKOSUADI_TR = Self.decodeSafeBool(from: container, forKey: .ONEMLIKOSUADI_TR)
        ONEMLIKOSUADI_EN = Self.decodeSafeBool(from: container, forKey: .ONEMLIKOSUADI_EN)
        OZELADI = Self.decodeSafeBool(from: container, forKey: .OZELADI)
        APRANTI = Self.decodeSafeBool(from: container, forKey: .APRANTI)
        
        SON800 = try? container.decodeIfPresent(String.self, forKey: .SON800)
        DOVIZ = try? container.decodeIfPresent(String.self, forKey: .DOVIZ)
        ikramiyeler = try? container.decodeIfPresent([String].self, forKey: .ikramiyeler)
        primler = try? container.decodeIfPresent([String].self, forKey: .primler)
        BAHISLER_TR = try? container.decodeIfPresent(String.self, forKey: .BAHISLER_TR)
        BAHISLER_EN = try? container.decodeIfPresent(String.self, forKey: .BAHISLER_EN)
        emiParasalNeticeler_tr = try? container.decodeIfPresent(String.self, forKey: .emiParasalNeticeler_tr)
        emiParasalNeticeler_en = try? container.decodeIfPresent(String.self, forKey: .emiParasalNeticeler_en)
        emiParasalNeticelerAgfResults = try? container.decodeIfPresent([String].self, forKey: .emiParasalNeticelerAgfResults)
        FOTOFINISH = try? container.decodeIfPresent(String.self, forKey: .FOTOFINISH)
        VIDEO = try? container.decodeIfPresent(String.self, forKey: .VIDEO)
        emiVideoFile = try? container.decodeIfPresent(String.self, forKey: .emiVideoFile)
        emiVideoUrl = try? container.decodeIfPresent(String.self, forKey: .emiVideoUrl)
        emiPhotoFile = try? container.decodeIfPresent(String.self, forKey: .emiPhotoFile)
        emiFotoUrl = try? container.decodeIfPresent(String.self, forKey: .emiFotoUrl)
        emiRunDate = try? container.decodeIfPresent(String.self, forKey: .emiRunDate)
        hasSatisbedeli = Self.decodeSafeBool(from: container, forKey: .hasSatisbedeli)
        hasNonRunner = Self.decodeSafeBool(from: container, forKey: .hasNonRunner)
        atlar = try? container.decodeIfPresent([Horse].self, forKey: .atlar)
    }
    
    static func decodeSafeBool(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Bool {
        if let value = try? container.decodeIfPresent(Bool.self, forKey: key) {
            return value
        }
        if let str = try? container.decodeIfPresent(String.self, forKey: key) {
            return str.lowercased() == "true" || str == "1"
        }
        return false
    }
    
    
    // Race.swift içine eklenecek manuel başlatıcı
    init(
        KOD: String,
        RACENO: String? = nil,
        SAAT: String? = nil,
        BILGI_TR: String? = nil,
        PIST: String? = nil,
        MESAFE: String? = nil,
        atlar: [Horse]? = nil
    ) {
        self.KOD = KOD
        self.RACENO = RACENO
        self.SAAT = SAAT
        self.BILGI_TR = BILGI_TR
        self.PIST = PIST
        self.MESAFE = MESAFE
        self.atlar = atlar
        
        // Zorunlu Bool alanları varsayılan değerlerle dolduruyoruz
        self.ONEMLIKOSUADI_TR = false
        self.ONEMLIKOSUADI_EN = false
        self.OZELADI = false
        self.APRANTI = false
        self.hasSatisbedeli = false
        self.hasNonRunner = false
        
        // Diğer opsiyonelleri nil bırakıyoruz
        self.NO = nil; self.TARIH = nil; self.PISTADI_TR = nil; self.PISTADI_EN = nil
        self.ActiveClass = nil; self.KISALTMA = nil; self.GRUP_TR = nil; self.GRUP_EN = nil
        self.GRUPKISA = nil; self.CINSDETAY_TR = nil; self.CINSDETAY_EN = nil; self.CINSIYET = nil
        self.BILGI_EN = nil; self.ENIYIDERECE = nil; self.ENIYIDERECEACIKLAMA = nil
        self.SON800 = nil; self.DOVIZ = nil; self.ikramiyeler = nil; self.primler = nil
        self.BAHISLER_TR = nil; self.BAHISLER_EN = nil; self.emiParasalNeticeler_tr = nil
        self.emiParasalNeticeler_en = nil; self.emiParasalNeticelerAgfResults = nil
        self.FOTOFINISH = nil; self.VIDEO = nil; self.emiVideoFile = nil; self.emiVideoUrl = nil
        self.emiPhotoFile = nil; self.emiFotoUrl = nil; self.emiRunDate = nil
    }
    
    
}
