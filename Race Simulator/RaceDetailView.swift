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
    
    var body: some View {
        VStack{
            TabView(selection: $selectedIndex){
                ForEach(kosular.indices, id: \.self) { index in
                    VStack {
                        List {
                            ForEach(kosular[index].atlar!, id: \.id) { at in
                                ListItemView(at: at)
                            }
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: .infinity)
        }
        .navigationTitle(kosular.indices.contains(selectedIndex) ? kosular[selectedIndex].RACENO!+". Kosu" : "")
        .animation(.default, value: selectedIndex)
    }
}


//#Preview {
    //RaceDetailView(raceName: "Test", havaData: HavaData.default, kosular: kosularMock, agf: [])
//}
