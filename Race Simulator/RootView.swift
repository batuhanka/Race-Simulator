import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            // Arka plan rengi veya görseli
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image(systemName: "figure.horseracing")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.teal)
                
                Text("Yarış Takip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    TextField("E-posta", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.none)
                    
                    SecureField("Şifre", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    // Buraya gerçek giriş kontrolü (API vb.) gelebilir
                    // Şimdilik direkt geçiş yapıyoruz:
                    withAnimation(.spring()) {
                        isLoggedIn = true
                    }
                }) {
                    Text("Giriş Yap")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    // isLoggedIn için sabit bir false değeri gönderiyoruz
    LoginView(isLoggedIn: .constant(false))
}
