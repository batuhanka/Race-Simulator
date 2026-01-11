//
//  VideoDetailView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 12.01.2026.
//


import SwiftUI
import AVKit

struct VideoDetailView: View {
    let videoURL: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                }

                Spacer()

                if let url = URL(string: videoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(maxWidth: 350, maxHeight: 450)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
