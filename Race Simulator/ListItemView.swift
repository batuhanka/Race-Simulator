//
//  ListItemView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//

import SwiftUI

private func parseSonYaris(_ veri: String) -> some View {
    let pistChar = veri.first ?? " "
    let derece = String(veri.dropFirst())
    
    var color: Color = .secondary
    
    switch pistChar {
    case "K": color = .brown   // Kum
    case "C": color = .green   // Çim
    case "S": color = .gray    // Sentetik
    default:  color = .secondary
    }
    
    return Text(derece)
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(color)
}

struct ListItemView: View {
    let at: Horse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 4) {
                
                Text(at.NO ?? "")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.primary)
                
                jerseyImage
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(at.AD ?? "")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(at.JOKEYADI ?? "")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    
                    HStack(spacing: 0) {
                        if let son6 = at.SON6, son6.count >= 2 {
                            
                            let yarislarda = stride(from: 0, to: son6.count, by: 2).compactMap { i -> String? in
                                let startIndex = son6.index(son6.startIndex, offsetBy: i)
                                guard let endIndex = son6.index(startIndex, offsetBy: 2, limitedBy: son6.endIndex) else { return nil }
                                return String(son6[startIndex..<endIndex])
                            }
                            
                            ForEach(yarislarda, id: \.self) { yaris in
                                parseSonYaris(yaris)
                            }
                        } else {
                            Text(at.SON6 ?? "")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                
                HStack(spacing: 4) {
                    Text(at.YAS ?? "")
                    Text("\(at.KILO ?? 0)kg")
                    Text(at.TAKI ?? "")
                    
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                
                
                Text("\(at.BABA ?? "") / \(at.ANNE ?? "")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("HP: \(at.HANDIKAP ?? "")")
                    Text("KGS: \(at.KGS ?? "")")
                    Spacer()
                    Text(at.ANTRENORADI ?? "")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                
                HStack {
                    Text("\(at.AGFSIRA1 ?? 0) - \(at.AGF1 ?? "")")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(at.SAHIPADI ?? "")
                        .font(.caption2)
                    
                }
            }
        }
        .padding(.vertical, 2)
        .background(Color(.systemBackground))
    }
    
    private var jerseyImage: some View {
        AsyncImage(url: URL(string: at.FORMA ?? "")) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
            case .empty:
                ProgressView().frame(width: 30, height: 30)
            @unknown default:
                EmptyView()
            }
        }
    }
}
#Preview {
    ListItemView(at: .example)
}
