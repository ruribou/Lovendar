import Foundation

// MARK: - 共通情報

struct CommonResponse: Codable {
    let categories: [Category]
}

struct Category: Codable, Identifiable {
    let id: Int
    let slug: String
    let name: String
    let description: String?
}

// MARK: - 推し関連

struct OshiListResponse: Codable {
    let oshis: [OshiAPI]
}

struct OshiResponse: Codable {
    let oshi: OshiAPI
}

struct OshiAPI: Codable, Identifiable {
    let id: Int
    let name: String
    let color: String
    let urls: [String]?
    let categories: [String]?
}

struct CreateOshiRequest: Codable {
    let name: String
    let color: String
    let urls: [String]?
    let categories: [String]?
}

struct UpdateOshiRequest: Codable {
    let name: String
    let color: String
    let urls: [String]?
    let categories: [String]?
}

// MARK: - イベント関連

struct EventListResponse: Codable {
    let oshis: [OshiWithEvents]
}

struct OshiWithEvents: Codable, Identifiable {
    let id: Int
    let name: String
    let color: String
    let events: [EventAPI]
}

struct EventDetailResponse: Codable {
    let event: EventDetailAPI
}

struct EventDetailAPI: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let url: String?
    let startsAt: String
    let endsAt: String?
    let hasAlarm: Bool
    let notificationTiming: String
    let hasNotificationSent: Bool
    let oshi: OshiBasic
    let category: Category?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, url
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case hasAlarm = "has_alarm"
        case notificationTiming = "notification_timing"
        case hasNotificationSent = "has_notification_sent"
        case oshi, category
    }
}

struct OshiBasic: Codable, Identifiable {
    let id: Int
    let name: String
    let color: String
}

struct EventAPI: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let url: String?
    let startsAt: String
    let endsAt: String?
    let hasAlarm: Bool
    let notificationTiming: String
    let hasNotificationSent: Bool
    let category: Category?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, url
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case hasAlarm = "has_alarm"
        case notificationTiming = "notification_timing"
        case hasNotificationSent = "has_notification_sent"
        case category
    }
}

struct CreateEventRequest: Codable {
    let event: CreateEventData
}

struct CreateEventData: Codable {
    let oshiId: Int
    let title: String
    let description: String?
    let url: String?
    let startsAt: String
    let endsAt: String?
    let hasAlarm: Bool
    let notificationTiming: String
    let categoryId: Int?
    
    enum CodingKeys: String, CodingKey {
        case oshiId = "oshi_id"
        case title, description, url
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case hasAlarm = "has_alarm"
        case notificationTiming = "notification_timing"
        case categoryId = "category_id"
    }
}

struct UpdateEventRequest: Codable {
    let event: UpdateEventData
}

struct UpdateEventData: Codable {
    let title: String
    let description: String?
    let url: String?
    let startsAt: String
    let endsAt: String?
    let hasAlarm: Bool
    let notificationTiming: String
    let categoryId: Int?
    
    enum CodingKeys: String, CodingKey {
        case title, description, url
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case hasAlarm = "has_alarm"
        case notificationTiming = "notification_timing"
        case categoryId = "category_id"
    }
}

struct EventCreateResponse: Codable {
    let event: EventDetailAPI
}

struct EventUpdateResponse: Codable {
    let event: EventAPI
}

