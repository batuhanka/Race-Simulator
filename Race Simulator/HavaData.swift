//
//  HavaData.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 20.03.2025.
//


struct HavaData {
    var aciklama: Int
    var cimPistagirligi: Int
    var cimEn: String
    var cimTr: String
    var gece: Int
    var havaDurumIcon: String
    var havaEn: String
    var havaTr: String
    var hipodromAdi: String
    var hipodromYeri: String
    var kumPistagirligi: Int
    var kumEn: String
    var kumTr: String
    var nem: Int
    var sicaklik: Int
    
    static let `default` = HavaData(
        aciklama: 0,
        cimPistagirligi: 0,
        cimEn: "",
        cimTr: "",
        gece: 1,
        havaDurumIcon: "default-icon",
        havaEn: "Unknown",
        havaTr: "Bilinmiyor",
        hipodromAdi: "Unknown Hipodrome",
        hipodromYeri: "Unknown Location",
        kumPistagirligi: 0,
        kumEn: "Unknown",
        kumTr: "Bilinmiyor",
        nem: 0,
        sicaklik: 0
    )
    
}

extension HavaData {
    init?(from dictionary: [String: Any]) {
        guard let aciklama = dictionary["ACIKLAMA"] as? Int,
              let cimPistagirligi = dictionary["CIMPISTAGIRLIGI"] as? Int,
              let cimEn = dictionary["CIM_EN"] as? String,
              let cimTr = dictionary["CIM_TR"] as? String,
              let gece = dictionary["GECE"] as? Int,
              let havaDurumIcon = dictionary["HAVADURUMICON"] as? String,
              let havaEn = dictionary["HAVA_EN"] as? String,
              let havaTr = dictionary["HAVA_TR"] as? String,
              let hipodromAdi = dictionary["HIPODROMADI"] as? String,
              let hipodromYeri = dictionary["HIPODROMYERI"] as? String,
              let kumPistagirligi = dictionary["KUMPISTAGIRLIGI"] as? Int,
              let kumEn = dictionary["KUM_EN"] as? String,
              let kumTr = dictionary["KUM_TR"] as? String,
              let nem = dictionary["NEM"] as? Int,
              let sicaklik = dictionary["SICAKLIK"] as? Int else { return nil }
        
        self.aciklama = aciklama
        self.cimPistagirligi = cimPistagirligi
        self.cimEn = cimEn
        self.cimTr = cimTr
        self.gece = gece
        self.havaDurumIcon = havaDurumIcon
        self.havaEn = havaEn
        self.havaTr = havaTr
        self.hipodromAdi = hipodromAdi
        self.hipodromYeri = hipodromYeri
        self.kumPistagirligi = kumPistagirligi
        self.kumEn = kumEn
        self.kumTr = kumTr
        self.nem = nem
        self.sicaklik = sicaklik
    }
}

