//
//  SimulationSetupView.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 23.02.2026.
//


import SwiftUI

struct SimulationSetupView: View {
    // MARK: - INCOMING PROPERTIES
    let selectedDate: Date
    let availableCities: [String]
    let initialCity: String?
    
    // MARK: - STATE
    @State private var selectedCity: String = ""
    @State private var havaData: HavaData = HavaData.default
    @State private var kosular: [Race] = []
    @State private var selectedKosuIndex: Int = 0
    
    @State private var isFetching: Bool = false
    @State private var showActualSimulation: Bool = false
    
    let parser = JsonParser()
    private let apiFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerSection
                
                if isFetching {
                    Spacer()
                    ProgressView().tint(.cyan).scaleEffect(1.5)
                    Text("Program Yükleniyor...").foregroundColor(.gray).font(.caption)
                    Spacer()
                } else if kosular.isEmpty {
                    Spacer()
                    Text("Bu şehre ait yarış programı bulunamadı.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    cityPickerSection
                    racePickerSection
                    horsesPreviewSection
                    
                    Spacer()
                    startSimulationButton
                }
            }
            .padding(.top)
        }
        .navigationTitle("Simülasyon Ayarları")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let city = initialCity ?? availableCities.first {
                selectedCity = city
                fetchProgram(for: city)
            }
        }
        .fullScreenCover(isPresented: $showActualSimulation) {
            if kosular.indices.contains(selectedKosuIndex) {
                SimulationView(
                    raceCity: selectedCity,
                    havaData: havaData,
                    kosu: kosular[selectedKosuIndex]
                )
            }
        }
    }
}

// MARK: - COMPONENTS
extension SimulationSetupView {
    
    private var headerSection: some View {
        VStack(spacing: 5) {
            Image(systemName: "sparkles.tv.fill")
                .font(.system(size: 40))
                .foregroundColor(.cyan)
            Text("YAPAY ZEKA SİMÜLATÖRÜ")
                .font(.headline.bold())
                .foregroundColor(.white)
        }
    }
    
    private var cityPickerSection: some View {
        VStack(alignment: .leading) {
            Text("ŞEHİR SEÇİMİ").font(.caption.bold()).foregroundColor(.gray).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableCities, id: \.self) { city in
                        Button {
                            if selectedCity != city {
                                selectedCity = city
                                fetchProgram(for: city)
                            }
                        } label: {
                            Text(city)
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(selectedCity == city ? Color.cyan : Color.white.opacity(0.1))
                                .foregroundColor(selectedCity == city ? .black : .white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var racePickerSection: some View {
        VStack(alignment: .leading) {
            Text("KOŞU SEÇİMİ").font(.caption.bold()).foregroundColor(.gray).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(kosular.indices, id: \.self) { index in
                        let kosuNo = kosular[index].RACENO ?? "\(index + 1)"
                        Button {
                            withAnimation { selectedKosuIndex = index }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(kosuNo). Koşu")
                                    .font(.system(size: 14, weight: .bold))
                                Text(kosular[index].MESAFE ?? "")
                                    .font(.system(size: 10))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedKosuIndex == index ? Color.orange : Color.white.opacity(0.1))
                            .foregroundColor(selectedKosuIndex == index ? .black : .white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var horsesPreviewSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("KATILACAK SAFKANLAR").font(.caption.bold()).foregroundColor(.gray)
                Spacer()
                if kosular.indices.contains(selectedKosuIndex) {
                    Text("\(kosular[selectedKosuIndex].atlar?.count ?? 0) At")
                        .font(.caption2.bold())
                        .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    if kosular.indices.contains(selectedKosuIndex), let atlar = kosular[selectedKosuIndex].atlar {
                        ForEach(atlar) { at in
                            HStack(spacing: 8) {
                                // Renkli At İkonu
                                ZStack {
                                    Circle().fill(at.horseColor).frame(width: 30, height: 30)
                                    Text(at.NO ?? "0").font(.system(size: 12, weight: .black)).foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(at.AD ?? "-")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(at.JOKEYADI ?? "-")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxHeight: 300) // Ekranı çok kaplamaması için sınır
    }
    
    private var startSimulationButton: some View {
        Button {
            showActualSimulation = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("SİMÜLASYONU BAŞLAT")
                    .font(.headline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.cyan)
            .foregroundColor(.black)
            .cornerRadius(15)
            .padding(.horizontal)
            .shadow(color: .cyan.opacity(0.4), radius: 10)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - DATA FETCHING
    private func fetchProgram(for city: String) {
        isFetching = true
        selectedKosuIndex = 0
        
        Task {
            do {
                let dateStr = apiFormatter.string(from: selectedDate)
                let program = try await parser.getProgramData(raceDate: dateStr, cityName: city)
                
                var newHava = HavaData.default
                if let havaDict = program["hava"] as? [String: Any], let parsedHava = HavaData(from: havaDict) {
                    newHava = parsedHava
                }
                
                var newKosular: [Race] = []
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let data = try JSONSerialization.data(withJSONObject: kosularArray)
                    newKosular = try JSONDecoder().decode([Race].self, from: data)
                }
                
                await MainActor.run {
                    self.havaData = newHava
                    self.kosular = newKosular
                    self.isFetching = false
                }
            } catch {
                await MainActor.run {
                    self.kosular = []
                    self.isFetching = false
                }
            }
        }
    }
}
