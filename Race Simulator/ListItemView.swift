//
//  ListItemView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//

import SwiftUI

struct ListItemView: View {
    let at: Horse
    
    var body: some View {
        // Ana Kapsayıcı
        VStack(spacing: 0) {
            
            // Üst Bilgi Satırı (Numara, At Adı, Jokey Adı)
            HStack(alignment: .top) {
                
                // Sol Üst Köşe: Numara ve At Adı Badge'i
                HStack(spacing: 0) {
                    // Koşu Numarası (Arka Plan: Mavi)
                    Text(at.NO ?? "")
                        .font(.caption) // Daha küçük font
                        .fontWeight(.bold)
                        .padding(.horizontal, 5) // Padding minimalize edildi
                        .padding(.vertical, 2)
                        .foregroundColor(Color.teal)
                    
                    Text(at.AD ?? "")
                        .font(.caption) // Daha küçük font
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
                
                // Sağ Üst Köşe: Jokey Adı
                VStack(alignment: .trailing) {
                    Text(at.JOKEYADI ?? "")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
            }
            .padding(.bottom, 6) // Alt boşluk azaltıldı
            
            
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
                        Text(at.YAS ?? "") // Yaş ve Cinsiyet
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
                    
                    // Sahip Bilgisi
                    VStack(alignment: .trailing) {
                        Text("\(at.SAHIPADI ?? "")")
                            .font(.system(size: 8)) // En küçük font
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                    }

                    // Antrenör Bilgisi - Kırmızı Çerçeveli Badge
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
        .padding(8) // Dış padding son kez küçültüldü
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1) // Gölge yumuşatıldı
    }
}
