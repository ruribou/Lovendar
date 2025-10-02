import Foundation
import SwiftUI
import Combine

// Color拡張 - HEXカラーコードのサポート
extension Color {
    init?(hex: String) {
        // #記号があれば削除
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        // 3桁のHEXカラーコードを6桁に変換（例：#F00 → #FF0000）
        if hexSanitized.count == 3 {
            var expandedHex = ""
            for char in hexSanitized {
                expandedHex.append(String(repeating: char, count: 2))
            }
            hexSanitized = expandedHex
        }
        
        // 6桁のHEXカラーコードかどうか確認
        guard hexSanitized.count == 6 else { return nil }
        
        let scanner = Scanner(string: hexSanitized)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xff0000) >> 16) / 255
            let g = Double((hexNumber & 0x00ff00) >> 8) / 255
            let b = Double(hexNumber & 0x0000ff) / 255
            
            self.init(.sRGB, red: r, green: g, blue: b)
            return
        }
        
        return nil
    }
    
    // HEXカラーコードを文字列として取得（#付き）
    var hexString: String? {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
}

// テーマの種類
enum AppTheme: String, CaseIterable {
    case pink = "pink"
    case skyBlue = "skyBlue"
    case green = "green"
    case yellow = "yellow"
    
    var displayName: String {
        switch self {
        case .pink:
            return "ピンク"
        case .skyBlue:
            return "スカイブルー"
        case .green:
            return "グリーン"
        case .yellow:
            return "イエロー"
        }
    }
    
    var icon: String {
        switch self {
        case .pink:
            return "heart.fill"
        case .skyBlue:
            return "cloud.fill"
        case .green:
            return "leaf.fill"
        case .yellow:
            return "sun.max.fill"
        }
    }
    
    // メインカラー
    var primaryColor: Color {
        switch self {
        case .pink:
            return Color(hex: "#FF69B4") ?? .pink
        case .skyBlue:
            return Color(hex: "#87CEEB") ?? .blue
        case .green:
            return Color(hex: "#4CAF50") ?? .green
        case .yellow:
            return Color(hex: "#FFD700") ?? .yellow
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .pink:
            return Color(hex: "#FF1493") ?? .pink
        case .skyBlue:
            return Color(hex: "#00BFFF") ?? .blue
        case .green:
            return Color(hex: "#2E7D32") ?? .green
        case .yellow:
            return Color(hex: "#FFA500") ?? .orange
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
        case .green:
            return [
                Color(hex: "#E8F5E9") ?? .white,
                Color(hex: "#C8E6C9") ?? .white
            ]
        case .yellow:
            return [
                Color(hex: "#FFFDE7") ?? .white,
                Color(hex: "#FFF9C4") ?? .white
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
