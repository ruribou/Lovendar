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
    
    static let shared = CalendarViewModel()
    
    init() {
        Task {
            await loadEvents()
        }
    }
    
    // イベントデータを読み込み
    func loadEvents() async {
        guard authManager.isAuthenticated else {
            // 認証されていない場合は空リストを表示
            events = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let oshiWithEvents = try await eventService.fetchEventList()
            var allEvents: [Event] = []
            
            for oshiData in oshiWithEvents {
                for apiEvent in oshiData.events {
                    if let event = convertAPIEventToEvent(apiEvent, oshiId: oshiData.id, oshiName: oshiData.name) {
                        allEvents.append(event)
                    }
                }
            }
            
            events = allEvents
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            events = []
        } catch {
            errorMessage = "エラーが発生しました"
            events = []
        }
        
        isLoading = false
    }
    
    // APIイベントをローカルイベントに変換
    private func convertAPIEventToEvent(_ apiEvent: EventAPI, oshiId: Int, oshiName: String) -> Event? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let startDate = formatter.date(from: apiEvent.startsAt) else {
            return nil
        }
        
        let endDate = apiEvent.endsAt.flatMap { formatter.date(from: $0) }
        let isAllDay = endDate == nil
        
        return Event(
            serverId: apiEvent.id,
            title: apiEvent.title,
            description: apiEvent.description ?? "",
            date: startDate,
            startTime: startDate,
            endTime: endDate,
            isAllDay: isAllDay,
            oshiId: nil,
            eventType: .general
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
}
