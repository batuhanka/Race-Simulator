//
//  MainShellView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 28.12.2025.
//

import SwiftUI

struct MainShellView: View {

    var body: some View {
        ZStack(alignment: .bottom) {

            // ANA İÇERİK
            MainView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // SABİT BOTTOM BAR
            CustomBottomBar()
                .transition(.move(edge: .bottom))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
#Preview {
    MainShellView()
}
