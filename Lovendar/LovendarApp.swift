import SwiftUI

@main
struct LovendarApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var apiConfig = APIConfig.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                } else {
                    AuthView()
                }
            }
        }
    }
}
