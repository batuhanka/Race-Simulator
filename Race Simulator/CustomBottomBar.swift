//
//  CustomBottomBar.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 28.12.2025.
//

import SwiftUI

// MARK: - TAB CONFIGURATION
enum BottomTab: Int, CaseIterable {
    case home = 0
    case schedule = 1
    case aiInsights = 2
    case agf = 3
    case coupon = 4
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .schedule: return "newspaper.fill"
        case .aiInsights: return "brain.fill"
        case .agf: return "tablecells.fill"
        case .coupon: return "ticket.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Anasayfa"
        case .schedule: return "Program"
        case .aiInsights: return "Tay Zeka"
        case .agf: return "AGF"
        case .coupon: return "Kupon"
        }
    }
}

// MARK: - CUSTOM BOTTOM BAR
struct CustomBottomBar: View {
    
    @Binding var selectedBottomTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            // Top separator line
            Divider()
                .background(Color.white.opacity(0.1))
            
            ZStack {
                // Background - extends to bottom
                Color.black.opacity(0.95)
                
                // Glass morphism indicator
                GeometryReader { geometry in
                    let totalWidth = geometry.size.width
                    let itemSpacing: CGFloat = 8 // Spacing between tabs
                    let horizontalPadding: CGFloat = 16 // Side padding
                    let tabCount = CGFloat(BottomTab.allCases.count)
                    
                    // Calculate tab width including spacing
                    let totalSpacing = itemSpacing * (tabCount - 1)
                    let availableWidth = totalWidth - (horizontalPadding * 2) - totalSpacing
                    let tabWidth = availableWidth / tabCount
                    
                    // Calculate x position for active tab
                    let xOffset = (tabWidth + itemSpacing) * CGFloat(selectedBottomTab)
                    
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan.opacity(0.25),
                                    Color.cyan.opacity(0.12)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: tabWidth + 8, height: 68)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.cyan.opacity(0.6),
                                            Color.cyan.opacity(0.2)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color.cyan.opacity(0.5), radius: 15, x: 0, y: 0)
                        .drawingGroup() // GPU acceleration
                        .offset(x: horizontalPadding + xOffset - 4, y: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedBottomTab)
                }
                
                // Tab items with spacing
                HStack(alignment: .center, spacing: 8) {
                    ForEach(BottomTab.allCases, id: \.rawValue) { tab in
                        BottomTabItem(
                            icon: tab.icon,
                            title: tab.title,
                            active: selectedBottomTab == tab.rawValue,
                            action: { selectedBottomTab = tab.rawValue }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 80)
        }
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
            // Haptic feedback for better UX
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            // Direct state change without animation wrapper
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: active ? .semibold : .regular))
                    .foregroundColor(active ? .white : .gray)
                
                Text(title)
                    .font(.system(size: 10, weight: active ? .semibold : .regular))
                    .foregroundColor(active ? .white : .gray.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(active ? [.isSelected] : [])
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        CustomBottomBar(selectedBottomTab: .constant(2))
    }
}

