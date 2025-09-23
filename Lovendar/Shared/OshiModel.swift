import Foundation
import SwiftUI

struct Oshi: Identifiable, Codable {
    let id: UUID
    var name: String
    var group: String
    var color: String
    var profileImage: String?
    var birthday: Date?
    var debutDate: Date?
    var description: String
    
    init(name: String, group: String = "", color: String = "#FF69B4", profileImage: String? = nil, birthday: Date? = nil, debutDate: Date? = nil, description: String = "") {
        self.id = UUID()
        self.name = name
        self.group = group
        self.color = color
        self.profileImage = profileImage
        self.birthday = birthday
        self.debutDate = debutDate
        self.description = description
    }
    
    var displayColor: Color {
        Color(hex: color) ?? Color.pink
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard hex.count == 6 else { return nil }
        
        let scanner = Scanner(string: hex)
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
}

extension Oshi {
    static let sampleOshi: [Oshi] = [
        Oshi(name: "推し1", group: "アイドルグループA", color: "#FF69B4", description: "最高の推し"),
        Oshi(name: "推し2", group: "VTuberグループB", color: "#87CEEB", description: "可愛い推し"),
        Oshi(name: "推し3", group: "声優グループC", color: "#98FB98", description: "歌声が素敵")
    ]
}
