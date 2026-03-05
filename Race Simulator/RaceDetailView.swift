import SwiftUI
import AVKit

struct RaceDetailView: View {
    // MARK: - PROPERTIES
    @State var raceName: String
    @State var havaData: HavaData
    @State var kosular: [Race]
    @State var agf: [[String: Any]]
    @State private var currentRaceResult: RaceResult? = nil
    
    let allRaces: [String]
    let selectedDate: Date
    
    @State private var fetchTask: Task<Void, Never>? = nil
    @State private var isFetchingResults: Bool = false
    
    @State private var showVideoFullScreen = false
    @State private var showingPhotoURL: String? = nil
    @State private var videoPlayer: AVPlayer? = nil
    
    // MARK: Binding
    @Binding var selectedBottomTab: Int
    
    @State private var selectedIndex: Int = 0
    @State private var isRefreshing: Bool = false
    
    let parser = JsonParser()
    let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()

    private var weatherSFSymbol: String {
        switch havaData.havaDurumIcon {
        case "icon-w-1":  return "sun.max.fill"
        case "icon-w-2":  return "cloud.sun.fill"
        case "icon-w-3":  return "cloud.fill"
        case "icon-w-4":  return "cloud.rain.fill"
        case "icon-w-5":  return "cloud.snow.fill"
        case "icon-w-6":  return "cloud.fog.fill"
        case "icon-w-7":  return "cloud.bolt.fill"
        case "icon-w-8":  return "cloud.drizzle.fill"
        default:          return "cloud.fill"
        }
    }

    private var turkishDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM yyyy EEEE"
        return f.string(from: selectedDate)
    }

    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            citySelectionBar
            
            headerBilgiAlani
            
            kosuSekmeSecici
            
            if isRefreshing {
                loadingView
            } else {
                if kosular.indices.contains(selectedIndex) {
                    let seciliKosu = kosular[selectedIndex]
                    
                    if let results = currentRaceResult,
                       let finishers = results.SONUCLAR,
                       !finishers.isEmpty,
                       results.KOD == seciliKosu.KOD {
                        
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    HStack(spacing: 4) {
                                        if let fotoURL = results.FOTOFINISH, !fotoURL.isEmpty {
                                            Button {
                                                withAnimation { self.showingPhotoURL = fotoURL }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "photo.fill")
                                                    Text("Foto Finiş")
                                                        .font(.caption.bold())
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 28)
                                                .background(Color.blue.opacity(0.6))
                                                .cornerRadius(16)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Video button -> prepare AVPlayer and show inline
                                        if let videoURL = results.VIDEO, !videoURL.isEmpty {
                                            Button {
                                                if let url = URL(string: videoURL) {
                                                    let player = AVPlayer(url: url)
                                                    player.play()
                                                    self.videoPlayer = player
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "play.circle.fill")
                                                    Text("Yarışı İzle")
                                                        .font(.caption.bold())
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 28)
                                                .background(Color.orange.opacity(0.6))
                                                .cornerRadius(16)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(results.BAHISLER_TR ?? "")")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .lineLimit(15)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(2)
                                .padding(.bottom, 4)
                                
                                ForEach(finishers.sorted(by: { $0.rankInt < $1.rankInt })) { finisher in
                                    ResultRowView(finisher: finisher)
                                }
                                Color.clear.frame(height: 50)
                            }
                            .padding(.horizontal)
                        }
                        .id("Results_\(seciliKosu.KOD)")
                    } else if isFetchingResults {
                        loadingView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    Text("\(seciliKosu.BAHISLER_TR ?? "")")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .lineLimit(5)
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(2)
                                .padding(.bottom ,4)
                                .padding(.horizontal, 16)
                                
                                if let atlar = seciliKosu.atlar, !atlar.isEmpty {
                                    ForEach(atlar) { at in
                                        ListItemView(at: at)
                                            .padding(.horizontal)
                                    }
                                    
                                    Color.clear.frame(height: 50)
                                } else {
                                    ContentUnavailableView("At Bilgisi Yok", systemImage: "horse.fill")
                                }
                            }
                        }
                        .id("ProgramList_\(selectedIndex)")
                        .transition(.opacity)
                    }
                }
            }
        }
        .background(
            ZStack {
                Color.black.ignoresSafeArea()
                
                let pistRenkleri = getPistColors(for: selectedIndex)
                LinearGradient(
                    gradient: Gradient(colors: [
                        pistRenkleri.last?.opacity(0.6) ?? .black,
                        Color.black.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: selectedIndex)
                
                RadialGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1000
                ).ignoresSafeArea()
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onChange(of: raceName) { _, newValue in
            fetchNewCityData(cityName: newValue)
        }
        .onAppear() {
            if kosular.indices.contains(selectedIndex) {
                checkResults(for: kosular[selectedIndex])
            }
        }
        
        .overlay {
            Group {
                if let photo = showingPhotoURL, let url = URL(string: photo) {
                    modalOverlay(title: "") {
                        withAnimation { showingPhotoURL = nil }
                    } content: {
                        ZoomableRemoteImage(url: url)
                            .frame(maxWidth: 520, maxHeight: 360)
                    }
                } else if let player = videoPlayer {
                    modalOverlay(title: "") {
                        player.pause()
                        withAnimation { videoPlayer = nil }
                    } content: {
                        VideoPlayer(player: player)
                            .frame(maxWidth: 520, maxHeight: 320)
                            .cornerRadius(12)
                            .onTapGesture { showVideoFullScreen = true }
                            .onAppear { player.play() }
                    }
                    .fullScreenCover(isPresented: $showVideoFullScreen) {
                        ZStack {
                            Color.black.ignoresSafeArea()
                            VideoPlayer(player: player)
                                .ignoresSafeArea()
                                .onAppear { player.play() }
                        }
                    }
                }
            }
        }
    }
    
    private struct ZoomableRemoteImage: View {
        let url: URL
        @State private var scale: CGFloat = 1
        @State private var lastScale: CGFloat = 1
        @State private var isZoomed = false

        var body: some View {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut) {
                                isZoomed.toggle()
                                scale = isZoomed ? 2 : 1
                                lastScale = scale
                            }
                        }
                case .empty:
                    ProgressView().tint(.cyan)
                case .failure:
                    Image(systemName: "photo.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
    
    
}

// MARK: - SUBVIEWS
extension RaceDetailView {
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(.cyan)
                .scaleEffect(1.5)
            Text("Veriler Güncelleniyor...")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var headerBilgiAlani: some View {
        Group {
            if kosular.indices.contains(selectedIndex) {
                let kosu = kosular[selectedIndex]
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(kosu.RACENO ?? "0"). Koşu")
                            .font(.subheadline.bold())

                        Spacer()

                        Label(kosu.SAAT ?? "00:00", systemImage: "clock.fill")
                            .font(.subheadline.bold())
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(kosu.BILGI_TR ?? "")
                            .font(.subheadline.bold())
                            .lineLimit(1, reservesSpace: true)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                        if let kosuAdi = kosu.ONEMLIKOSUADI_TR {
                            Text(kosuAdi)
                                .font(.subheadline.bold())
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(height: 80, alignment: .top)
            }
        }
    }
    
    private var kosuSekmeSecici: some View {
        HStack(spacing: 6) {
            ForEach(kosular.indices, id: \.self) { index in
                let kosuNo = kosular[index].RACENO ?? "\(index + 1)"
                let buttonColors = getPistColors(for: index)
                Button {
                    selectedIndex = index
                    currentRaceResult = nil
                    checkResults(for: kosular[index])
                } label: {
                    Text(kosuNo)
                        .font(.system(size: 13, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            selectedIndex == index ?
                            LinearGradient(colors: buttonColors, startPoint: .top, endPoint: .bottom) :
                                LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundColor(selectedIndex == index ? .black : .white.opacity(0.7))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }
    
    private var citySelectionBar: some View {
        HStack {
            Menu {
                ForEach(Array(Set(allRaces)).sorted(), id: \.self) { city in
                    Button {
                        withAnimation { self.raceName = city }
                    } label: {
                        Label(
                            city.turkishCityUppercased,
                            systemImage: city == raceName ? "mappin.circle.fill" : "mappin.circle"
                        )
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.cyan)
                    Text(raceName.turkishCityUppercased)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(turkishDateString)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                HStack(spacing: 5) {
                    Image(systemName: weatherSFSymbol)
                        .foregroundColor(.yellow.opacity(0.85))
                    Text(havaData.havaTr)
                    Text("·")
                    Text("\(havaData.sicaklik)°C")
                    Text("·")
                    Text("%\(havaData.nem)")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.55))
            }
        }
        .padding(.horizontal)
        .frame(height: 65)
    }
}

// MARK: - LOGIC & HELPERS
extension RaceDetailView {
    
    private func getPistColors(for index: Int) -> [Color] {
        guard kosular.indices.contains(index) else { return [.black, .black] }
        let pist = (kosular[index].PIST ?? "").lowercased(with: Locale(identifier: "tr_TR"))
        if pist.contains("cim") || pist.contains("çim") {
            return [Color.green.opacity(0.3), Color.green.opacity(0.9)]
        } else if pist.contains("kum") {
            return [Color.brown.opacity(0.3), Color.brown.opacity(0.9)]
        } else if pist.contains("sentetik") {
            return [Color.gray.opacity(0.3), Color.gray.opacity(0.9)]
        } else {
            return [Color.gray.opacity(0.3), Color.black.opacity(0.9)]
        }
    }
    
    private func checkResults(for race: Race) {
        
        fetchTask?.cancel()
        
        isFetchingResults = true
        currentRaceResult = nil
        
        let dateStr = apiDateFormatter.string(from: selectedDate)
        
        fetchTask = Task {
            do {
                let result = try await parser.getRaceResult(raceDate: dateStr, cityName: raceName, targetKod: race.KOD)
                
                try Task.checkCancellation()
                
                await MainActor.run {
                    self.currentRaceResult = result
                    self.isFetchingResults = false // Yükleme bitti
                }
            } catch {
                await MainActor.run { self.isFetchingResults = false }
            }
        }
    }
    
    private func fetchNewCityData(cityName: String) {
        isRefreshing = true
        selectedIndex = 0
        currentRaceResult = nil
        Task {
            do {
                let dateStr = apiDateFormatter.string(from: selectedDate)
                let program = try await parser.getProgramData(raceDate: dateStr, cityName: cityName)
                
                var newHava: HavaData?
                if let havaDict = program["hava"] as? [String: Any] { newHava = HavaData(from: havaDict) }
                
                var newKosular: [Race] = []
                if let kosularArray = program["kosular"] as? [[String: Any]] {
                    let data = try JSONSerialization.data(withJSONObject: kosularArray)
                    newKosular = try JSONDecoder().decode([Race].self, from: data)
                }
                
                let newAgf = program["agf"] as? [[String: Any]] ?? []
                
                await MainActor.run {
                    if let safeHava = newHava { self.havaData = safeHava }
                    self.kosular = newKosular
                    self.agf = newAgf
                    withAnimation { isRefreshing = false }
                    // Trigger check for first race of new city
                    if !newKosular.isEmpty { checkResults(for: newKosular[0]) }
                }
            } catch {
                await MainActor.run { isRefreshing = false }
            }
        }
    }
    
    // Modal overlay helper
    private func modalOverlay<Content: View>(
        title: String,
        onClose: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(8)
                            .background(Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                    .tint(.primary)
                }
                
                content()
                    .frame(maxWidth: .infinity)
            }
            .padding(20)
            .frame(maxWidth: 600)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .shadow(radius: 18)
            .padding(.horizontal, 18)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
