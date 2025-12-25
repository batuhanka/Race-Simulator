import SwiftUI

struct RootView: View {
    // Kullanıcının giriş yapıp yapmadığını tutan ana durum
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        if isLoggedIn {
            // Giriş başarılıysa senin mevcut ContentView'un açılır
            ContentView()
        } else {
            // Giriş yapılmadıysa hazırladığımız LoginView açılır
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

#Preview {
    RootView()
}
