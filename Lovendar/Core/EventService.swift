import Foundation
import Combine

// イベントAPI サービス
class EventService {
    static let shared = EventService()
    private let apiService = APIService.shared
    
    private init() {}
    
    // イベント一覧取得
    func fetchEventList() async throws -> [OshiWithEvents] {
        let response: EventListResponse = try await apiService.request(
            endpoint: "/me/events",
            method: .get,
            requiresAuth: true
        )
        return response.oshis
    }
    
    // イベント詳細取得
    func fetchEventDetail(id: Int) async throws -> EventDetailAPI {
        let response: EventDetailResponse = try await apiService.request(
            endpoint: "/me/events/\(id)",
            method: .get,
            requiresAuth: true
        )
        return response.event
    }
    
    // イベント新規作成
    func createEvent(
        oshiId: Int,
        title: String,
        description: String?,
        url: String?,
        startsAt: String,
        endsAt: String?,
        hasAlarm: Bool,
        notificationTiming: String,
        categoryId: Int?
    ) async throws -> EventDetailAPI {
        let eventData = CreateEventData(
            oshiId: oshiId,
            title: title,
            description: description,
            url: url,
            startsAt: startsAt,
            endsAt: endsAt,
            hasAlarm: hasAlarm,
            notificationTiming: notificationTiming,
            categoryId: categoryId
        )
        let request = CreateEventRequest(event: eventData)
        let response: EventCreateResponse = try await apiService.request(
            endpoint: "/me/events/new",
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.event
    }
    
    // イベント更新
    func updateEvent(
        id: Int,
        title: String,
        description: String?,
        url: String?,
        startsAt: String,
        endsAt: String?,
        hasAlarm: Bool,
        notificationTiming: String,
        categoryId: Int?
    ) async throws -> EventAPI {
        let eventData = UpdateEventData(
            title: title,
            description: description,
            url: url,
            startsAt: startsAt,
            endsAt: endsAt,
            hasAlarm: hasAlarm,
            notificationTiming: notificationTiming,
            categoryId: categoryId
        )
        let request = UpdateEventRequest(event: eventData)
        let response: EventUpdateResponse = try await apiService.request(
            endpoint: "/me/events/\(id)",
            method: .put,
            body: request,
            requiresAuth: true
        )
        return response.event
    }
}

