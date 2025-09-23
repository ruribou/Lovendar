//
//  CalendarViewModel.swift
//  Lovendar
//
//  Created by AI Assistant on 2025/09/23.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedDate = Date()
    @Published var currentMonth = Date()
    
    private let calendar = Calendar.current
    
    init() {
        loadEvents()
    }
    
    func loadEvents() {
        events = Event.sampleEvents
    }
    
    func addEvent(_ event: Event) {
        events.append(event)
        saveEvents()
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    func eventsForDate(_ date: Date) -> [Event] {
        return events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasEventsForDate(_ date: Date) -> Bool {
        return !eventsForDate(date).isEmpty
    }
    
    private func saveEvents() {
        // TODO: データ保存処理
    }
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    func daysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1) else {
            return []
        }
        
        var days: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return days
    }
    
    func isDateInCurrentMonth(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    func isSelected(_ date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
}