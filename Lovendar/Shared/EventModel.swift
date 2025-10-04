import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    var serverId: Int? // APIのID
    var title: String
    var description: String
    var date: Date
    var startTime: Date
    var endTime: Date?
    var isAllDay: Bool
    var oshiId: Int?
    var eventType: EventType
    var hasAlarm: Bool
    var notificationTiming: String // "5", "10", "15", "30", "45", "60"
    
    init(serverId: Int? = nil, title: String, description: String = "", date: Date, startTime: Date? = nil, endTime: Date? = nil, isAllDay: Bool = false, oshiId: Int? = nil, eventType: EventType = .general, hasAlarm: Bool = false, notificationTiming: String = "15") {
        self.id = UUID()
        self.serverId = serverId
        self.title = title
        self.description = description
        self.date = date
        self.isAllDay = isAllDay
        self.oshiId = oshiId
        self.eventType = eventType
        self.hasAlarm = hasAlarm
        self.notificationTiming = notificationTiming
        
        if isAllDay {
            self.startTime = Calendar.current.startOfDay(for: date)
            self.endTime = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)) ?? date
        } else {
            self.startTime = startTime ?? date
            self.endTime = endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: startTime ?? date) ?? date
        }
    }
}

enum EventType: String, CaseIterable, Codable {
    case general = "general"
    case birthday = "birthday"
    case debut = "debut"
    case live = "live"
    case release = "release"
    case broadcast = "broadcast"
    case collaboration = "collaboration"
    case anniversary = "anniversary"
    
    var displayName: String {
        switch self {
        case .general:
            return "一般"
        case .birthday:
            return "誕生日"
        case .debut:
            return "デビュー"
        case .live:
            return "ライブ・イベント"
        case .release:
            return "リリース"
        case .broadcast:
            return "配信・放送"
        case .collaboration:
            return "コラボ"
        case .anniversary:
            return "記念日"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .general:
            return "calendar"
        case .birthday:
            return "gift"
        case .debut:
            return "star"
        case .live:
            return "music.note"
        case .release:
            return "opticaldisc"
        case .broadcast:
            return "tv"
        case .collaboration:
            return "person.2"
        case .anniversary:
            return "heart"
        }
    }
}