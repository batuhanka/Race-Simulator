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
    @State private var isStartButtonPulsing = false
    @State private var visibleHorseCount: Int = 0
    @State private var revealTask: Task<Void, Never>? = nil
    
    let parser = JsonParser()
    private let apiFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
    
    
    
    // MARK: - TOP BAR
    private var topNavigationBar: some View {
        HStack {
            
            
            HStack(spacing: 2) {
                Text("TAY")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white.opacity(0.4))
                Text("ZEKA")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.cyan.opacity(0.9))
            }
            
            Spacer()
            
            Image("tayzekatransparent")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
        }
        .padding(.horizontal)
        .frame(height: 60)
        .background(Color.black)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {

                
                if isFetching {
                    ProgressView().tint(.cyan).scaleEffect(1.5)
                        .padding(.vertical, 20)
                    Text("Program Yükleniyor...").foregroundColor(.gray).font(.caption)
                } else if kosular.isEmpty {
                    Text("Bu şehre ait yarış programı bulunamadı.")
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
                } else {
                    cityPickerSection
                    racePickerSection
                    horsesPreviewSection
                    startSimulationButton
                        .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 2) {
                    Text("TAY")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white.opacity(0.4))
                    Text("ZEKA")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.cyan.opacity(0.9))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Image("tayzekatransparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if let city = initialCity ?? availableCities.first {
                selectedCity = city
                fetchProgram(for: city)
            }
        }
        .fullScreenCover(isPresented: $showActualSimulation) {
            if kosular.indices.contains(selectedKosuIndex) {
                SimulationViewHorse3D(
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
    
    
    private var cityPickerSection: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
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
                    .frame(minWidth: geometry.size.width)
                }
            }
            .frame(height: 40)
        }
    }
    
    private var racePickerSection: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
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
                                    Text("\(kosular[index].MESAFE ?? "")m \(kosular[index].PISTADI_TR ?? "")")
                                        .font(.system(size: 10))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedKosuIndex == index ? Color.orange : Color.white.opacity(0.1))
                                .foregroundColor(selectedKosuIndex == index ? .black : .white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(minWidth: geometry.size.width)
                }
            }
            .frame(height: 45)
        }
    }
    
    private var horsesPreviewSection: some View {
        VStack(spacing: 10) {
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
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 1).id("TopMarker")
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            if kosular.indices.contains(selectedKosuIndex), let atlar = kosular[selectedKosuIndex].atlar {
                                ForEach(Array(atlar.enumerated()), id: \.element.id) { index, at in
                                    let uniqueID = "horse_\(selectedKosuIndex)_\(index)"
                                    
                                    AnimatedHorseCard(at: at, isVisible: index < visibleHorseCount)
                                        .id(uniqueID)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                }
                .onChange(of: visibleHorseCount) { _, newCount in
                    if newCount > 0 {
                        withAnimation {
                            let targetID = "horse_\(selectedKosuIndex)_\(newCount - 1)"
                            proxy.scrollTo(targetID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: selectedKosuIndex) { _, _ in
                    withAnimation {
                        proxy.scrollTo("TopMarker", anchor: .top)
                    }
                    startRevealTask()
                }
            }
        }
        .frame(maxHeight: 600)
    }
    
    private var startSimulationButton: some View {
        Button {
            showActualSimulation = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("BAŞLAT")
                    .font(.headline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .foregroundColor(Color.cyan.opacity(0.8))
            .cornerRadius(15)
            .padding(.horizontal)
            .shadow(color: .cyan.opacity(isStartButtonPulsing ? 0.8 : 0.6), radius: isStartButtonPulsing ? 15 : 5)
            .scaleEffect(isStartButtonPulsing ? 1.05 : 1.0)
        }
        .padding(.bottom, 50)
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: isStartButtonPulsing
        )
        .onAppear {
            isStartButtonPulsing = true
        }
        .onDisappear {
            isStartButtonPulsing = false
        }
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
                    self.startRevealTask()
                }
            } catch {
                await MainActor.run {
                    self.kosular = []
                    self.isFetching = false
                }
            }
        }
    }
    
    private func startRevealTask() {
        revealTask?.cancel()
        visibleHorseCount = 0
        
        guard kosular.indices.contains(selectedKosuIndex),
              let atlar = kosular[selectedKosuIndex].atlar,
              !atlar.isEmpty else { return }
        
        let totalHorses = atlar.count
        
        revealTask = Task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            if Task.isCancelled { return }
            
            for i in 0..<totalHorses {
                await MainActor.run {
                    if !Task.isCancelled {
                        visibleHorseCount = i + 1
                    }
                }
                
                try? await Task.sleep(nanoseconds: 500_000_000)
                if Task.isCancelled { break }
            }
        }
    }
}

// MARK: - YENİ: Premium TV/Oyun Tarzı Formalı At Kartı
struct AnimatedHorseCard: View {
    let at: Horse
    let isVisible: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 1. ARKA PLAN: Forma Görseli (Tüm kartı kaplar)
            if let formaLink = at.FORMA, let url = URL(string: formaLink) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        Color(at.horseColor).opacity(0.5) // Yüklenemezse atın rengini koy
                    @unknown default:
                        Color.black
                    }
                }
                .frame(height: 65)
                .clipped() // Kart dışına taşmayı engeller
            } else {
                Color(at.horseColor).opacity(0.5)
                    .frame(height: 65)
            }
            
            // 2. GÖLGE KATMANI: Yazıların okunmasını sağlayan soldan sağa gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.95), Color.black.opacity(0.7), Color.clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 65)
            
            // 3. İÇERİK: Numara, At ve Jokey Adı
            HStack(spacing: 8) {
                // Numara çok daha agresif, italik ve büyük
                Text(at.NO ?? "0")
                    .font(.system(size: 28, weight: .heavy))
                    .italic()
                    .foregroundColor(.white)
                    // DÜZELTME BURADA: Genişliği 45 yaptık ve sığmazsa küçül komutu verdik
                    .frame(width: 45, alignment: .center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(at.AD ?? "-")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(at.JOKEYADI ?? "-")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 65)
        .cornerRadius(12)
        // Premium hissiyat için çok ince beyaz bir dış çerçeve
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
        .animation(.easeOut(duration: 0.8), value: isVisible)
    }
}

// MARK: - PREVIEW
#Preview {
    // 1. Mock Atlar (Gerçek TJK forma linki ile)
    let h1 = Horse(
        KOD: "1001",
        NO: "1",
        AD: "GÜLŞAH SULTAN",
        START: "1",
        JOKEYADI: "H. KARATAŞ",
        FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg"
    )
    
    let h2 = Horse(
        KOD: "1002",
        NO: "2",
        AD: "RÜZGAR GİBİ",
        START: "2",
        JOKEYADI: "S. KAYA",
        FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg"
    )
    
    let h3 = Horse(
        KOD: "1003",
        NO: "3",
        AD: "ŞAMPİYON TAY",
        START: "3",
        JOKEYADI: "A. KURŞUN",
        FORMA: "https://medya-cdn.tjk.org/formaftp/7485.jpg"
    )
    
    // 2. Mock Koşular
    let mockRace1 = Race(
        KOD: "901",
        RACENO: "1",
        SAAT: "14:00",
        BILGI_TR: "3 Yaşlı İngilizler",
        MESAFE: "1400",
        atlar: [h1, h2, h3]
    )
    
    let mockRace2 = Race(
        KOD: "902",
        RACENO: "2",
        SAAT: "14:30",
        BILGI_TR: "4 Yaşlı Araplar",
        MESAFE: "1600",
        atlar: [h1, h2]
    )
    
    let today = Date()
    
    NavigationStack {
        SimulationSetupView(
            selectedDate: today,
            availableCities: ["ADANA", "ANTALYA"],
            initialCity: "ADANA"
        )
    }
    .preferredColorScheme(.dark)
}
