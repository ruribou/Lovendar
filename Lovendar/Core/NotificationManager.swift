import Foundation
import UserNotifications
import Combine

// 通知管理サービス
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // 通知権限をリクエスト
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                authorizationStatus = granted ? .authorized : .denied
            }
            print("✅ 通知権限: \(granted ? "許可" : "拒否")")
            return granted
        } catch {
            print("❌ 通知権限リクエストエラー: \(error)")
            return false
        }
    }
    
    // 現在の通知権限状態を確認
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                print("📱 通知権限状態: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
    // イベントの通知をスケジュール
    func scheduleNotification(for event: Event) {
        guard event.hasAlarm else {
            print("⏭️ イベント「\(event.title)」は通知がオフです")
            return
        }
        
        guard let minutesBefore = Int(event.notificationTiming) else {
            print("❌ 無効な通知タイミング: \(event.notificationTiming)")
            return
        }
        
        // 通知時刻を計算
        guard let notificationDate = Calendar.current.date(byAdding: .minute, value: -1 * minutesBefore, to: event.startTime) else {
            print("❌ 通知時刻の計算に失敗")
            return
        }
        
        // 過去の日時の場合は通知をスケジュールしない
        if notificationDate < Date() {
            print("⏭️ イベント「\(event.title)」の通知時刻が過去のためスキップ")
            return
        }
        
        // 通知コンテンツを作成
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = "\(minutesBefore)分後に開始します"
        content.sound = .default
        
        // イベントの説明がある場合は追加
        if !event.description.isEmpty {
            content.body = "\(minutesBefore)分後に開始します\n\(event.description)"
        }
        
        // カテゴリに応じたサブタイトルを設定
        content.subtitle = event.eventType.displayName
        
        // 通知IDを生成（イベントIDベース）
        let identifier = "event_\(event.serverId ?? 0)_\(event.id.uuidString)"
        
        // 日時コンポーネントを作成
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 通知リクエストを作成
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // 通知をスケジュール
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 通知のスケジュールに失敗: \(error)")
            } else {
                print("✅ 通知をスケジュール: \(event.title) - \(self.formatDate(notificationDate))")
            }
        }
    }
    
    // イベントの通知をキャンセル
    func cancelNotification(for event: Event) {
        let identifier = "event_\(event.serverId ?? 0)_\(event.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ 通知をキャンセル: \(event.title)")
    }
    
    // 複数イベントの通知をスケジュール
    func scheduleNotifications(for events: [Event]) {
        for event in events {
            scheduleNotification(for: event)
        }
    }
    
    // すべての通知をキャンセル
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ すべての通知をキャンセルしました")
    }
    
    // スケジュールされている通知一覧を取得
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // 日時フォーマット用のヘルパーメソッド
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// 通知タイミングの選択肢
enum NotificationTiming: String, CaseIterable, Identifiable {
    case sixtyMinutes = "60"
    case fortyFiveMinutes = "45"
    case thirtyMinutes = "30"
    case fifteenMinutes = "15"
    case tenMinutes = "10"
    case fiveMinutes = "5"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .sixtyMinutes:
            return "60分前"
        case .fortyFiveMinutes:
            return "45分前"
        case .thirtyMinutes:
            return "30分前"
        case .fifteenMinutes:
            return "15分前"
        case .tenMinutes:
            return "10分前"
        case .fiveMinutes:
            return "5分前"
        }
    }
}

