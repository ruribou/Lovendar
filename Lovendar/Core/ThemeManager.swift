import Foundation
import SwiftUI
import Combine

// テーマの種類
enum AppTheme: String, CaseIterable {
    case pink = "pink"
    case skyBlue = "skyBlue"
    
    var displayName: String {
        switch self {
        case .pink:
            return "ピンク"
        case .skyBlue:
            return "水色"
        }
    }
    
    var icon: String {
        switch self {
        case .pink:
            return "heart.fill"
        case .skyBlue:
            return "cloud.fill"
        }
    }
    
    // メインカラー
    var primaryColor: Color {
        switch self {
        case .pink:
            return Color(hex: "#FF69B4") ?? .pink
        case .skyBlue:
            return Color(hex: "#87CEEB") ?? .blue
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .pink:
            return Color(hex: "#FF1493") ?? .pink
        case .skyBlue:
            return Color(hex: "#00BFFF") ?? .blue
        }
    }
    
    // 背景グラデーション
    var backgroundGradientColors: [Color] {
        switch self {
        case .pink:
            return [
                Color(hex: "#FFF0F5") ?? .white,
                Color(hex: "#FFE4E1") ?? .white
            ]
        case .skyBlue:
            return [
                Color(hex: "#E0F6FF") ?? .white,
                Color(hex: "#B0E0E6") ?? .white
            ]
        }
    }
    
    // グラデーション
    var gradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// テーママネージャー
@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .pink
    
    static let shared = ThemeManager()
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "appTheme"
    
    private init() {
        loadTheme()
    }
    
    func loadTheme() {
        if let themeRaw = userDefaults.string(forKey: themeKey),
           let theme = AppTheme(rawValue: themeRaw) {
            currentTheme = theme
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        userDefaults.set(theme.rawValue, forKey: themeKey)
    }
}
