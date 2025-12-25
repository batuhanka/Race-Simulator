import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
}

struct ExplosionView: View {
    @State private var particles: [Particle] = []
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(String("01".randomElement()!))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(particle.color)
                    .position(x: particle.x, y: particle.y)
                    .opacity(opacity)
            }
        }
        .scaleEffect(scale)
        .onAppear {
            createExplosion()
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 3.0
                opacity = 0
            }
        }
    }

    func createExplosion() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        for _ in 0..<100 {
            let p = Particle(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                color: .cyan
            )
            particles.append(p)
        }
    }
}

struct Theme {
    static let matrixCyan = Color.cyan
    static let terminalFont = "Menlo-Bold"
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
                withAnimation(
                    Animation.linear(duration: duration).repeatForever(
                        autoreverses: false
                    ).delay(delay)
                ) {
                    offset = 800
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var showExplosion = false

    @FocusState private var focusedField: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            MatrixBackground()
                .ignoresSafeArea()
                .drawingGroup()
                .id("matrix-background-fixed")

            VStack {

                Spacer()

                VStack(spacing: 5) {
                    Image("tayzekatransparent")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 400, height: 400)
                        .foregroundColor(Theme.matrixCyan)
                        .shadow(
                            color: Theme.matrixCyan.opacity(0.5),
                            radius: 20
                        )

                }

                VStack(spacing: 10) {
                    customInputField(
                        icon: "terminal",
                        placeholder: "Kullanıcı",
                        text: $email,
                        fieldID: "email"
                    )
                    customInputField(
                        icon: "key.fill",
                        placeholder: "Şifre",
                        text: $password,
                        isSecure: true,
                        fieldID: "password"
                    )

                    Button(action: {
                        authenticate()
                    }) {
                        Text("GİRİŞ")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(Theme.matrixCyan)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .cornerRadius(4)
                            .shadow(
                                color: Theme.matrixCyan.opacity(0.4),
                                radius: 15
                            )
                    }
                    .padding(.top, 10)
                }
                .opacity(showExplosion ? 0 : 1)
                .padding(.horizontal, 40)
                .ignoresSafeArea(.container, edges: .bottom)

                if showExplosion {
                    ExplosionView().transition(.opacity)
                }

                Spacer()

                // Alt Bilgi
                Text("STATUS: SECURE_CONNECTION_ACTIVE")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Theme.matrixCyan.opacity(0.5))
                    .padding(.bottom, 20)
            }
        }

        .onAppear {
            AppDelegate.orientationLock = .portrait

            UIDevice.current.setValue(
                UIInterfaceOrientation.portrait.rawValue,
                forKey: "orientation"
            )

            if let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene
            {
                windowScene.requestGeometryUpdate(
                    .iOS(interfaceOrientations: .portrait)
                )
            }
        }
        .onDisappear {
            AppDelegate.orientationLock = .all
        }

        .alert("Erişim Reddedildi", isPresented: $showAlert) {
            Button("TEKRAR DENE", role: .cancel) {}
        } message: {
            Text(
                "Girdiğiniz protokol bilgileri sistem kayıtlarıyla eşleşmiyor."
            )
        }
    }

    private func authenticate() {
        if email == "admin" && password == "1234" {
            withAnimation {
                showExplosion = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isLoggedIn = true
                }
            }
        } else {
            showAlert = true
        }

    }

    @ViewBuilder
    func customInputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        fieldID: String
    ) -> some View {
        let isFocused = focusedField == fieldID

        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(
                    isFocused ? Theme.matrixCyan : .white.opacity(0.5)
                )
                .font(.system(size: 16))
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(
                        "",
                        text: text,
                        prompt: Text(placeholder).foregroundColor(
                            .white.opacity(0.2)
                        )
                    )
                } else {
                    TextField(
                        "",
                        text: text,
                        prompt: Text(placeholder).foregroundColor(
                            .white.opacity(0.2)
                        )
                    )
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
                }
            }
            .focused($focusedField, equals: fieldID)
            .foregroundColor(.white)
            .font(.system(size: 15, design: .monospaced))
        }
        .padding(18)
        .background(Color.white.opacity(isFocused ? 0.08 : 0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    isFocused
                        ? Theme.matrixCyan : Theme.matrixCyan.opacity(0.2),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isFocused)
    }
}
#Preview {
    LoginView(isLoggedIn: .constant(false))
}
