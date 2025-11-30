//
//  ListItemView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//

import SwiftUI

/*
struct ListItemView: View {
    let at: Horse
    
    var body: some View {
       
        VStack(spacing: 0) {
            
            HStack(alignment: .top) {
                
                HStack(spacing: 0) {
                    Text(at.NO ?? "")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .foregroundColor(Color.teal)
                    
                    Text(at.AD ?? "")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .foregroundColor(Color.teal)
                    

                    Text(at.TAKI ?? "")
                        .font(.system(size: 8))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .foregroundColor(Color.gray)
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(at.JOKEYADI ?? "")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
            }
            .padding(.bottom, 6)
            
            
            HStack(alignment: .top, spacing: 10) {
                
                
                AsyncImage(url: URL(string: at.FORMA?.replacingOccurrences(of: "medya.tjk.org", with: "medya-cdn.tjk.org") ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack(spacing: 6) {
                        Text(at.YAS ?? "")
                            .font(.caption2)
                        Text("\(at.KILO ?? 0)kg") // Kilo
                            .font(.caption2)
                    }
                    .fontWeight(.medium)
                    
                    Text("HP:\(at.HANDIKAP ?? "0") KGS:\(at.KGS ?? "0")") 
                        .font(.caption2) // Daha küçük font
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                
                VStack(alignment: .trailing, spacing: 4) {
                    

                    VStack(alignment: .trailing) {
                        Text("\(at.SAHIPADI ?? "")")
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                    }

                    Text("\(at.ANTRENORADI ?? "")")
                        .font(.system(size: 8))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            HStack(spacing: 8) {
                
                Text("\(at.BABA ?? "") / \(at.ANNE ?? "")")
                    .font(.system(size: 8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .foregroundColor(Color.black)
                    .cornerRadius(4)
                
                Spacer()
            }
            
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}
*/

struct ListItemView: View {
    let at: Horse // Model tipiniz
    
    var body: some View {
        // Liste satırı gibi davranması için dışarıdan padding ve arka planı kaldırdık
        VStack(spacing: 8) { // Dikey boşluk minimalize edildi
            
            // --- 1. ANA SATIR (Numara, At Adı, Yaş/Kilo, Jokey Adı, Lisans) ---
            HStack(alignment: .top) {
                
                // Sol Bölüm: At Numarası (Kilo/Jokey Fotoğrafı yerine) ve At Adı
                HStack(alignment: .top, spacing: 6) {
                    
                    // A. At Numarası (Örn: 1)
                    Text(at.NO ?? "")
                        .font(.title3)
                        .fontWeight(.heavy) // Daha kalın
                        .foregroundColor(.primary)
                    
                    // B. Atın Görseli (Eğer varsa) - Bu kısım resmin sol üstündeki
                    // koşu numarasının hemen altında küçük bir ikon olabilir.
                    // Şimdilik listeyi sade tutmak için önceki görselleri kaldırdık.
                    
                    // C. At Adı ve Yaş/Kilo Bilgisi
                    VStack(alignment: .leading, spacing: 2) {
                        
                        // At Adı (Ana Başlık)
                        Text(at.AD ?? "Bilinmeyen At")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        // Yaş/Cinsiyet, Kilo, Takı Bilgisi (Tek Satır)
                        HStack(spacing: 4) {
                            Text(at.YAS ?? "Yok")
                            Text(at.TAKI ?? "") // Takı bilgisi (KG SK)
                                .fontWeight(.medium)
                                .foregroundColor(.red) // Takıları kırmızı yaptık
                            Text("\(at.KILO ?? 0)kg")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Sağ Bölüm: Jokey Adı ve Lisans Numarası
                VStack(alignment: .trailing, spacing: 2) {
                    
                    // Jokey Adı (Üstte)
                    Text(at.JOKEYADI ?? "Jokey Yok")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    // Lisans/Sıralama Numarası (Sağ Altta)
                    Text("234293") // Bu veri modelinizde yoksa, sabit bir mock değer kullandık.
                        .font(.caption)
                        .foregroundColor(Color.green) // Yeşil Lisans Numarası
                }
            }
            
            // --- 2. ALT BİLGİ SATIRI (AGF, Baba/Anne, Sahip, HP/KGS, EID) ---
            VStack(alignment: .leading, spacing: 4) {
                
                // A. Baba/Anne ve Sahip Bilgisi
                HStack(spacing: 12) {
                    
                    // Baba Bilgisi
                    HStack(spacing: 4) {
                        Text("Baba:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(at.BABA ?? "Yok")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    // Anne Bilgisi
                    HStack(spacing: 4) {
                        Text("Anne:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        // Anne ve Anneanne (Eğer varsa)
                        Text("\(at.ANNE ?? "Yok") / Gobekbey") // Modelde sadece ANNE var, diğerini mockladık
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Sahip Bilgisi
                    HStack(spacing: 4) {
                        Text("Sahip:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(at.SAHIPADI ?? "Yok")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                // B. AGF, S20, HP, KGS, EID (Aynı Satırda)
                HStack(spacing: 12) {
                    
                    // AGF Bilgisi
                    Text("AGF: #5 - %11.11") // Bu veri modelinizde yoksa, sabit mock kullandık
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // S20 Bilgisi
                    Text("S20: 16") // Bu veri modelinizde yoksa, sabit mock kullandık
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // HP Bilgisi
                    Text("HP: \(at.HANDIKAP ?? "0")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // KGS Bilgisi
                    Text("KGS: \(at.KGS ?? "0")")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // EID Bilgisi
                    Text("EID: 2.35.36") // Bu veri modelinizde yoksa, sabit mock kullandık
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer() // Tüm bilgileri sola yaslar
                }
            }
        }
        .padding(.vertical, 10) // Dikey boşluk eklendi
        .padding(.horizontal, 16) // Yatay boşluk eklendi
        // Listedeki satırların ayrılması için ince bir çizgi ekleyebiliriz
        .overlay(
            VStack {
                Spacer()
                Divider() // Altına ince ayırıcı çizgi
            }
        )
        .background(Color(.systemBackground))
        // Köşe yuvarlama ve gölgeyi tamamen kaldırdık
    }
}

