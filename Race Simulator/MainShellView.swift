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
            
            if selectedTab == 3 {
                NavigationStack {
                    OddsView(selectedDate: Date(), initialTab: 1)
                }
            } else if selectedTab == 4 {
                TicketSetupView()
            }
            else {
                NavigationStack {
                    MainView(selectedBottomTab: $selectedTab)
                }
            }
            
            CustomBottomBar(selectedBottomTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    MainShellView()
}
