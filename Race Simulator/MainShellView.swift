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
            
            // selectedTab değerine göre hangi ana görünümün gösterileceğini belirler.
            // Her sekme kendi NavigationStack'i içinde yönetilir.
            if selectedTab == 3 {
                NavigationStack {
                    OddsView(selectedDate: Date())
                }
            } else if selectedTab == 4 {
                NavigationStack {
                    TicketView()
                }
            }
            else {
                // Diğer tüm sekmeler için (0, 1, 2) MainView'ı gösterir.
                NavigationStack {
                    MainView(selectedBottomTab: $selectedTab)
                }
            }
            
            // Tüm görünümlerin üzerinde altta duran özel tab bar.
            CustomBottomBar(selectedBottomTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
#Preview {
    MainShellView()
}
