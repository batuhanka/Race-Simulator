//
//  ContentView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 13.03.2025.
//

import SwiftUI

struct ContentView: View {
    init() {
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray // inactive dots
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black // active dot
    }
    
    @State private var jsonText: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var textValue: String = ""
    @State private var errorMessage: String?
    @State private var cities: [String] = []
    @State private var races: [String] = []
    @State private var selectedRace: String? = nil
    @State private var showRaceDetails: Bool = false
    @State private var havaData: HavaData?
    @State private var kosular: [Race] = []
    @State private var agf: [[String: Any]] = []
    
    let parser = JsonParser()
    
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }
    
    var minDate: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    }
    
    var maxDate : Date {
        return Calendar.current.date(byAdding: .day, value: 3, to: Date())!
    }
    
    var body: some View {
        
        
        
        NavigationStack {
            VStack {
                
                DatePicker("", selection: $selectedDate, in: minDate...maxDate, displayedComponents: .date)
                    .labelsHidden()
                    .padding()
                    .datePickerStyle(.wheel)
                    .onChange(of: selectedDate) { oldValue, newValue in
                        
                        Task{
                            let result = try await parser.getRaceCities(raceDate: dateFormatter.string(from: newValue))
                            races = result
                            
                        }
                    }
                
                HStack{
                    ForEach($races, id: \.self) { $race in
                        Button(action: {
                            selectedRace = race
                            showRaceDetails = true
                            Task{
                                let program = try await parser.getProgramData(raceDate: dateFormatter.string(from: selectedDate), cityName: race)
                                
                                if let havaDictionary = program["hava"] as? [String: Any],
                                   let havaData = HavaData(from: havaDictionary) {
                                    self.havaData = havaData
                                }
                                
                                if let kosularArray = program["kosular"] as? [[String: Any]] {
                                    kosular = convertToRaces(from: kosularArray)
                                }
                                
                                if let agfArray = program["agf"] as? [[String: Any]] {
                                    self.agf = agfArray
                                }
                                
                            }
                        }) {
                            Text(race)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .cornerRadius(30)
                        }.background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(30)
                    }
                }.padding()
                
                
                
                .navigationDestination(isPresented: $showRaceDetails){
                    RaceDetailView(raceName: selectedRace ?? "", havaData: havaData ?? HavaData.default, kosular: kosular, agf: agf)
                }
                
            }.onAppear() {
                Task{
                    races = try await parser.getRaceCities(raceDate: dateFormatter.string(from: selectedDate))
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
        }
    }
    
    func convertToRaces(from kosular: [[String: Any]]) -> [Race] {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: kosular, options: [])
            let decoded = try JSONDecoder().decode([Race].self, from: jsonData)
            return decoded
        } catch {
            print("Conversion error: \(error)")
            return []
        }
    }
    
}


#Preview {
    ContentView()
}
