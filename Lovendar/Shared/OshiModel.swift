import Foundation
import SwiftUI

struct Oshi: Identifiable, Codable {
    let id: UUID
    var serverId: Int? // APIのID
    var name: String
    var group: String
    var color: String
    var urls: [String]
    var categories: [String]
    var profileImage: String?
    var birthday: Date?
    var debutDate: Date?
    var description: String
    
    // ローカル用の初期化
    init(name: String, group: String = "", color: String = "#FF69B4", urls: [String] = [], categories: [String] = [], profileImage: String? = nil, birthday: Date? = nil, debutDate: Date? = nil, description: String = "") {
        self.id = UUID()
        self.serverId = nil
        self.name = name
        self.group = group
        self.color = color
        self.urls = urls
        self.categories = categories
        self.profileImage = profileImage
        self.birthday = birthday
        self.debutDate = debutDate
        self.description = description
    }
    
    // API用の初期化
    init(id: Int, name: String, color: String, urls: [String], categories: [String]) {
        self.id = UUID()
        self.serverId = id
        self.name = name
        self.group = ""
        self.color = color
        self.urls = urls
        self.categories = categories
        self.profileImage = nil
        self.birthday = nil
        self.debutDate = nil
        self.description = ""
    }
    
    var displayColor: Color {
        Color(hex: color) ?? Color.pink
    }
}

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