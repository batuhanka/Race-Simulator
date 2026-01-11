import SwiftUI
import AVKit

struct VideoDetailView: View {
    let videoURL: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let url = URL(string: videoURL) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 400)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }
}