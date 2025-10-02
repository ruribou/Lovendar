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