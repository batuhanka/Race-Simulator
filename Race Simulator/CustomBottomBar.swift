//
//  CustomBottomBar.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 28.12.2025.
//
import SwiftUI

// MARK: - CUSTOM BOTTOM BAR
struct CustomBottomBar: View {
    
    @Binding var selectedBottomTab: Int
    
    var body: some View {
        VStack(spacing: 0) {

            Spacer()
            
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.1)

            HStack(alignment: .firstTextBaseline, spacing: 0) {

                BottomTabItem(
                    icon: "house.fill",
                    title: "Anasayfa",
                    active: selectedBottomTab == 0,
                    action: { selectedBottomTab = 0 }
                ).id("tab_0")

                BottomTabItem(
                    icon: "newspaper.fill",
                    title: "Program",
                    active: selectedBottomTab == 1,
                    action: { selectedBottomTab = 1 }
                ).id("tab_1")

                BottomTabItem(
                    icon: "brain.fill",
                    title: "Tay Zeka",
                    active: selectedBottomTab == 2,
                    action: { selectedBottomTab = 2 }
                ).id("tab_2")
                
                BottomTabItem(
                    icon: "tablecells.fill",
                    title: "AGF",
                    active: selectedBottomTab == 3,
                    action: { selectedBottomTab = 3 }
                ).id("tab_3")
                
                BottomTabItem(
                    icon: "flag.fill",
                    title: "Sonuçlar",
                    active: selectedBottomTab == 4,
                    action: { selectedBottomTab = 4 }
                ).id("tab_4")
            }
            
            .padding(.vertical, 8)
            .padding(.horizontal, 2)
            .background(Color.black.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}


// MARK: - TAB ITEM
struct BottomTabItem: View {

    let icon: String
    let title: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(height: 22)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(active ? .cyan : .gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 2)
            .background(
                active ? Color.cyan.opacity(0.15) : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .transition(.scale.combined(with: .opacity))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CustomBottomBar(selectedBottomTab: .constant(3))
}
