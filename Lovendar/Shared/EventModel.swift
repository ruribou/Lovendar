import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var isAllDay: Bool
    var oshiId: UUID?
    var eventType: EventType
    
    init(title: String, description: String = "", date: Date, startTime: Date? = nil, endTime: Date? = nil, isAllDay: Bool = false, oshiId: UUID? = nil, eventType: EventType = .general) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.date = date
        self.isAllDay = isAllDay
        self.oshiId = oshiId
        self.eventType = eventType
        
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

extension Event {
    static let sampleEvents: [Event] = [
        Event(title: "推しのライブ", description: "ソロライブコンサート", date: Date(), startTime: Date(), endTime: Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date(), eventType: .live),
        Event(title: "推しの誕生日", description: "お祝いの日♪", date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), isAllDay: true, eventType: .birthday),
        Event(title: "新曲リリース", description: "待望の新曲発売日", date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(), eventType: .release)
    ]
}