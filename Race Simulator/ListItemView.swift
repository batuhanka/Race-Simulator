//
//  ListItemView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.03.2025.
//

import Foundation
import SwiftUICore
import SwiftUI

struct ListItemView: View {
    let at: Horse // Replace with your actual model type
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            let fixedURLString = at.FORMA!.replacingOccurrences(of: "medya.tjk.org", with: "medya-cdn.tjk.org")
            AsyncImage(url: URL(string: fixedURLString)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 36, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        
        VStack(alignment: .leading) {
            
            Text(at.AD!) // Assuming 'at' has a 'name' property
                .font(.headline)
            Text("Age: \(at.YAS!)") // Assuming 'at' has an 'age' property
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
