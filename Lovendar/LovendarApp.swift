import SwiftUI

@main
struct LovendarApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var apiConfig = APIConfig.shared
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView(isCompleted: $hasCompletedOnboarding)
                } else if authManager.isAuthenticated {
                    ContentView()
                } else {
                    AuthView()
                }
            }
        }
    }
}
