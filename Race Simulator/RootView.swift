import SwiftUI
import UIKit

// MARK: - APP DELEGATE
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

// MARK: - PARTICLE MODEL
struct Particle: Identifiable {
    let id = UUID()
    let vx: CGFloat
    let vy: CGFloat
    let color: Color
}

// MARK: - EXPLOSION VIEW
struct ExplosionView: View {
    @State private var particles: [Particle] = []
    @State private var opacity: Double = 1.0
    @State private var animationProgress: CGFloat = 0.0
    @State private var isVisible: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isVisible {
                    ForEach(particles) { particle in
                        Text(String("01".randomElement()!))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(particle.color)
                            .position(
                                x: (geo.size.width / 2) + (particle.vx * animationProgress),
                                y: (geo.size.height / 2) + (particle.vy * animationProgress)
                            )
                            .opacity(opacity)
                    }
                }
            }
            .onAppear {
                createExplosion()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    isVisible = true
                    withAnimation(.easeOut(duration: 1.2)) {
                        animationProgress = 1.0
                        opacity = 0
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func createExplosion() {
        var tempParticles: [Particle] = []
        for _ in 0..<200 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 100...500)
            let p = Particle(
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                color: .cyan
            )
            tempParticles.append(p)
        }
        self.particles = tempParticles
    }
}

// MARK: - MATRIX EFFECTS
struct Theme {
    static let matrixCyan = Color.cyan
}

struct MatrixBackground: View {
    let columnCount = 20
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { _ in
            HStack(spacing: 12) {
                ForEach(0..<columnCount, id: \.self) { index in
                    MatrixColumn(columnId: index)
                }
            }
        }
        .mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .black, .clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .opacity(0.3)
    }
}

struct MatrixColumn: View {
    let columnId: Int
    @State private var offset: CGFloat = 0
    private let duration: Double = Double.random(in: 6...12)
    private let delay: Double = Double.random(in: 0...2)
    private let initialRandomOffset: CGFloat = CGFloat.random(in: -800...(-400))
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<50, id: \.self) { _ in
                Text(String("01".randomElement()!))
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
        }
        .offset(y: offset)
        .onAppear {
            if offset == 0 {
                offset = initialRandomOffset
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false).delay(delay)) {
                    offset = 800
                }
            }
        }
    }
}

// MARK: - ROOT VIEW
struct RootView: View {
    @State private var isAppReady = false
    @State private var showExplosion = false
    @State private var logoOpacity: Double = 1.0
    @State private var logoScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            if isAppReady {
                MainShellView()
                    .transition(.opacity)
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    MatrixBackground()
                        .ignoresSafeArea()
                        .drawingGroup()
                    
                    VStack {
                        Spacer()
                        Image("tayzekatransparent")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 400, height: 400)
                            .foregroundColor(Theme.matrixCyan)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                            .shadow(color: Theme.matrixCyan.opacity(0.6), radius: 25)
                        Spacer()
                    }
                    
                    if showExplosion {
                        ExplosionView()
                    }
                }
                .onAppear {
                    setupOrientation()
                    startAutomaticProcess()
                }
            }
        }
    }
    
    private func startAutomaticProcess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 0.4)) {
                logoScale = 2.0
                logoOpacity = 0
            }
            
            showExplosion = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isAppReady = true
                    showExplosion = false 
                }
            }
        }
    }
    
    private func setupOrientation() {
        AppDelegate.orientationLock = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }
}

// MARK: - PREVIEW
#Preview {
    RootView()
}
