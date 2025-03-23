import SwiftUI

struct RaceDetailView: View {
    var raceName: String
    
    var body: some View {
        VStack {
            Text("Details for \(raceName)")
                .font(.title)
                .padding()
            // You can pass and display more data here later
        }
        .navigationTitle(raceName)
    }
}
