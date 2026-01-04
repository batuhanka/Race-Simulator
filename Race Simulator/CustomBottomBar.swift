//
//  CustomBottomBar.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 28.12.2025.
//
import SwiftUI

// MARK: - CUSTOM BOTTOM BAR
struct CustomBottomBar: View {
    var body: some View {
        VStack(spacing: 0) {

            Rectangle()
                .fill(Color.cyan.opacity(0.2))
                .frame(height: 0.5)

            HStack(alignment: .bottom) {

                BottomTabItem(
                    icon: "house.fill",
                    title: "Anasayfa",
                    active: true
                )

                BottomTabItem(
                    icon: "list.bullet.rectangle",
                    title: "Program",
                    active: false
                )

                VStack(spacing: 4) {
                    Image("tayzekatransparent")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.cyan.opacity(0.8), radius: 6)

                    Text("Tay Zeka Kuponu")
                        .font(.system(size: 10, weight: .black))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .offset(y: 0)

                BottomTabItem(
                    icon: "flag.fill",
                    title: "Sonuçlar",
                    active: false
                )

                BottomTabItem(
                    icon: "ticket.fill",
                    title: "Muhtemeller",
                    active: false
                )
            }
            .padding(.top, -30)
            .padding(.bottom, 10)
            .background(Color.black)
        }
    }
}

// MARK: - TAB ITEM
struct BottomTabItem: View {

    let icon: String
    let title: String
    let active: Bool

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))

                Text(title)
                    .font(.system(size: 10, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(active ? .cyan : .gray)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CustomBottomBar()
}
