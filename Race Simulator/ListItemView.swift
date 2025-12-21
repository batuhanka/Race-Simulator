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
        
        VStack {
            
            HStack(alignment: .center) {
                
                HStack(alignment: .center) {
                    
                    Text(at.NO ?? "")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    
                    AsyncImage(url: URL(string: at.FORMA ?? ""))
                    { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(1),lineWidth: 1))
                            
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                            
                        case .empty:
                            ProgressView()
                                .frame(width: 32, height: 32)
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text(at.AD ?? "At Adi")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    
                    Text(at.JOKEYADI ?? "Jokey")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("234293")
                        .font(.caption)
                        .foregroundColor(Color.green)
                }
            }
            
            VStack(alignment: .leading) {
                
                HStack(spacing: 4) {
                    Text(at.YAS ?? "Yok").font(.caption2)
                    Text(at.TAKI ?? "KG DB").font(.caption2)
                    Text("\(at.KILO ?? 0)kg").font(.caption2)
                }
                
                HStack {
                    
                    HStack {
                        Text("\(at.BABA ?? "Baba") / \(at.ANNE ?? "Anne")")
                            .font(.caption2)
                    }
                    
                    Spacer()
                    
                }
                
                HStack {
                    
                    Text("HP: \(at.HANDIKAP ?? "0")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("KGS: \(at.KGS ?? "0")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                   Text(at.ANTRENORADI ?? "Antrenor")
                        .font(.caption2)
                    
                }
                
                VStack{
                    HStack{
                        Text("\(at.AGFSIRA1 ?? 0) - \(at.AGF1 ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Sahip Bilgisi
                        HStack {
                            Text(at.SAHIPADI ?? "Sahip")
                                .font(.caption2)
                        }
                        
                    }
                }
                
                
                
                
            }
        }
        .overlay(
            VStack {
                Spacer()
            }
        )
        .background(Color(.systemBackground))
    }
}

#Preview {
    ListItemView(at: .example)
}
