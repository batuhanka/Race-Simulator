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
            
            HStack(alignment: .center, spacing: 0) {

                BottomTabItem(
                    icon: "house.fill",
                    title: "Anasayfa",
                    active: selectedBottomTab == 0,
                    action: { selectedBottomTab = 0 }
                )

                BottomTabItem(
                    icon: "newspaper.fill",
                    title: "Program",
                    active: selectedBottomTab == 1,
                    action: { selectedBottomTab = 1 }
                )

                BottomTabItem(
                    icon: "brain.fill",
                    title: "Tay Zeka",
                    active: selectedBottomTab == 2,
                    action: { selectedBottomTab = 2 }
                )
                
                BottomTabItem(
                    icon: "tablecells.fill",
                    title: "AGF",
                    active: selectedBottomTab == 3,
                    action: { selectedBottomTab = 3 }
                )
                
                BottomTabItem(
                    icon: "ticket.fill",
                    title: "Kupon",
                    active: selectedBottomTab == 4,
                    action: { selectedBottomTab = 4 }
                )
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.black.opacity(0.95))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.6), radius: 15, x: 0, y: 16)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
        .ignoresSafeArea(edges: .bottom)
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                
                ZStack {
                    Circle()
                        .fill(active ? Color.cyan.opacity(0.18) : Color.clear)
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: active ? .bold : .regular))
                        .foregroundColor(active ? .cyan : .gray)
                        .scaleEffect(active ? 1.5 : 1.0)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: active ? .bold : .medium))
                    .foregroundColor(active ? .cyan : .gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        CustomBottomBar(selectedBottomTab: .constant(2))
    }
}

