import Foundation
import SwiftUI
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let eventService = EventService.shared
    private let authManager = AuthManager.shared
    private var loadingTask: Task<Void, Never>?
    
    static let shared = CalendarViewModel()
    
    init() {
        Task {
            await loadEvents()
        }
    }
    
    // イベントデータを読み込み
    func loadEvents() async {
        // 既存のタスクをキャンセル
        loadingTask?.cancel()
        
        loadingTask = Task {
            print("🔄 CalendarViewModel: loadEvents() 開始")
            
            guard !Task.isCancelled else {
                print("⏹️ CalendarViewModel: タスクがキャンセルされました")
                return
            }
            
            guard authManager.isAuthenticated else {
                // 認証されていない場合は空リストを表示
                print("❌ CalendarViewModel: 認証されていません")
                await MainActor.run {
                    events = []
                    isLoading = false
                }
                return
            }
            
            print("✅ CalendarViewModel: 認証済み、API呼び出し開始")
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                guard !Task.isCancelled else {
                    print("⏹️ CalendarViewModel: API呼び出し前にキャンセルされました")
                    return
                }
                
                let oshiWithEvents = try await eventService.fetchEventList()
                
                guard !Task.isCancelled else {
                    print("⏹️ CalendarViewModel: API応答後にキャンセルされました")
                    return
                }
                
                print("📊 CalendarViewModel: API応答受信 - \(oshiWithEvents.count)個の推しデータ")
                
                var allEvents: [Event] = []
                
                for oshiData in oshiWithEvents {
                    guard !Task.isCancelled else {
                        print("⏹️ CalendarViewModel: データ変換中にキャンセルされました")
                        return
                    }
                    
                    print("👤 推し: \(oshiData.name) - \(oshiData.events.count)個のイベント")
                    for apiEvent in oshiData.events {
                        if let event = convertAPIEventToEvent(apiEvent, oshiId: oshiData.id, oshiName: oshiData.name) {
                            allEvents.append(event)
                            print("📅 イベント変換成功: \(event.title)")
                        } else {
                            print("❌ イベント変換失敗: \(apiEvent.title)")
                        }
                    }
                }
                
                await MainActor.run {
                    events = allEvents
                    print("✅ CalendarViewModel: 合計\(allEvents.count)個のイベントを読み込み完了")
                    
                    // 通知をスケジュール
                    let notificationManager = NotificationManager.shared
                    notificationManager.scheduleNotifications(for: allEvents)
                    print("📱 通知スケジュール処理を実行")
                }
            } catch let error as NetworkError {
                print("❌ CalendarViewModel: NetworkError - \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = getDetailedErrorMessage(error)
                    events = []
                }
            } catch {
                print("❌ CalendarViewModel: 一般エラー - \(error)")
                await MainActor.run {
                    errorMessage = getDetailedErrorMessage(error)
                    events = []
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
        
        await loadingTask?.value
    }
    
    // APIイベントをローカルイベントに変換
    private func convertAPIEventToEvent(_ apiEvent: EventAPI, oshiId: Int, oshiName: String) -> Event? {
        print("🔄 変換開始: \(apiEvent.title), starts_at: \(apiEvent.startsAt)")
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let startDate = formatter.date(from: apiEvent.startsAt) else {
            print("❌ 日付変換失敗: \(apiEvent.startsAt)")
            
            // フォールバック: 別のフォーマットを試す
            let fallbackFormatter = ISO8601DateFormatter()
            fallbackFormatter.formatOptions = [.withInternetDateTime]
            
            guard let fallbackStartDate = fallbackFormatter.date(from: apiEvent.startsAt) else {
                print("❌ フォールバック日付変換も失敗")
                return nil
            }
            
            print("✅ フォールバック日付変換成功")
            let endDate = apiEvent.endsAt.flatMap { fallbackFormatter.date(from: $0) }
            let isAllDay = endDate == nil
            
            return Event(
                serverId: apiEvent.id,
                title: apiEvent.title,
                description: apiEvent.description ?? "",
                date: fallbackStartDate,
                startTime: fallbackStartDate,
                endTime: endDate,
                isAllDay: isAllDay,
                oshiId: oshiId,
                eventType: .general,
                hasAlarm: apiEvent.hasAlarm,
                notificationTiming: apiEvent.notificationTiming
            )
        }
        
        let endDate = apiEvent.endsAt.flatMap { formatter.date(from: $0) }
        let isAllDay = endDate == nil
        
        print("✅ 日付変換成功: \(startDate)")
        
        return Event(
            serverId: apiEvent.id,
            title: apiEvent.title,
            description: apiEvent.description ?? "",
            date: startDate,
            startTime: startDate,
            endTime: endDate,
            isAllDay: isAllDay,
            oshiId: oshiId,
            eventType: .general,
            hasAlarm: apiEvent.hasAlarm,
            notificationTiming: apiEvent.notificationTiming
        )
    }
    
    // 選択した日付のイベントを取得
    func eventsForSelectedDate() -> [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: selectedDate)
        }
    }
    
    // 指定した日付のイベントを取得
    func eventsForDate(_ date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }
    
    // 指定した日付にイベントがあるか
    func hasEventsForDate(_ date: Date) -> Bool {
        return !eventsForDate(date).isEmpty
    }
    
    // 月の年月表示文字列を取得
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 月の日付配列を生成（前月・翌月の日付も含む）
    func daysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    // 日付が現在の月に含まれるか
    func isDateInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    // 今日かどうか
    func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    // 選択されているか
    func isSelected(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    // データをリフレッシュ
    func refresh() async {
        await loadEvents()
    }
    
    // 簡略化されたエラーメッセージを生成
    private func getDetailedErrorMessage(_ error: Error) -> String {
        return "データの読み込みに失敗しました"
    }
}
