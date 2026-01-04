//
//  MainShellView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 28.12.2025.
//

import SwiftUI

struct MainShellView: View {

    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {

            MainView(selectedBottomTab: $selectedTab)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomBottomBar(selectedBottomTab: $selectedTab)
                .transition(.move(edge: .bottom))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
#Preview {
    MainShellView()
}
