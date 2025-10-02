import Foundation
import Combine

// イベントAPI サービス
class EventService {
    static let shared = EventService()
    private let apiService = APIService.shared
    
    private init() {}
    
    // イベント一覧取得
    func fetchEventList() async throws -> [OshiWithEvents] {
        print("🔄 EventService: /me/events API呼び出し開始")
        
        let response: EventListResponse = try await apiService.request(
            endpoint: "/me/events",
            method: .get,
            requiresAuth: true
        )
        
        print("📊 EventService: API応答受信")
        print("📊 推しの数: \(response.oshis.count)")
        
        for (index, oshi) in response.oshis.enumerated() {
            print("👤 推し[\(index)]: ID=\(oshi.id), 名前=\(oshi.name), 色=\(oshi.color)")
            print("📅 イベント数: \(oshi.events.count)")
            
            for (eventIndex, event) in oshi.events.enumerated() {
                print("  📅 イベント[\(eventIndex)]: ID=\(event.id), タイトル=\(event.title)")
                print("    📅 開始日時: \(event.startsAt)")
                print("    📅 終了日時: \(event.endsAt ?? "なし")")
                print("    📅 説明: \(event.description ?? "なし")")
                print("    📅 URL: \(event.url ?? "なし")")
                print("    📅 アラーム: \(event.hasAlarm)")
                print("    📅 通知タイミング: \(event.notificationTiming)")
                if let category = event.category {
                    print("    📅 カテゴリ: \(category.name) (slug: \(category.slug))")
                } else {
                    print("    📅 カテゴリ: なし")
                }
                print("    ---")
            }
            print("  ===")
        }
        
        print("✅ EventService: レスポンス解析完了")
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
}

