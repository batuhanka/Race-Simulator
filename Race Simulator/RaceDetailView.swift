//
//  RaceDetailView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 19.03.2025.
//

import SwiftUI

struct RaceDetailView: View {
    
    var raceName: String
    var havaData: HavaData
    var kosular: [Race]
    var agf: [[String: Any]]
    @State private var selectedIndex = 0
    
    private func getPistColors(for index: Int) -> [Color] {
        guard kosular.indices.contains(index) else { return [Color.gray, Color.black] }
        
        let pist = kosular[index].PIST ?? ""
        
        if pist.contains("cim") {
            return [Color.green.opacity(0.4), Color.green.opacity(1)] // Çim için yeşil tonlar
        } else if pist.contains("kum") {
            return [Color.orange.opacity(0.3), Color.brown.opacity(1)] // Kum için kahve/turuncu tonlar
        } else if pist.contains("sentetik") {
            return [Color.blue.opacity(0.3), Color.gray.opacity(0.5)] // Sentetik için mavi tonlar
        } else {
            return [Color.gray.opacity(0.2), Color.black.opacity(0.1)] // Varsayılan
        }
    }
    
    var body: some View {
        
        ZStack{
            
            LinearGradient(
                gradient: Gradient(colors: getPistColors(for: selectedIndex)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: selectedIndex)
            
            VStack{
                Picker("Koşu", selection: $selectedIndex) {
                    ForEach(kosular.indices, id: \.self) { index in
                        Text("\(kosular[index].RACENO ?? "0")").tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if kosular.indices.contains(selectedIndex) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(kosular[selectedIndex].SAAT ?? "00:00")
                                .font(.footnote)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        HStack{
                            Text(kosular[selectedIndex].BILGI_TR ?? "")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(.gray.opacity(0.3)),
                        alignment: .bottom
                    )
                }
                
                TabView(selection: $selectedIndex){
                    ForEach(kosular.indices, id: \.self) { index in
                        VStack {
                            List {
                                ForEach(kosular[index].atlar!, id: \.id) { at in
                                    ListItemView(at: at)
                                        .contextMenu {
                                            Button { print("Favori") } label: { Label("Favori", systemImage: "star") }
                                            Button { print("Not") } label: { Label("Not", systemImage: "pencil") }
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
            }
            .navigationTitle(havaData.hipodromAdi)
            .navigationBarTitleDisplayMode(.inline)
            
            .animation(.snappy, value: selectedIndex)
        }
    }
    
}

    

