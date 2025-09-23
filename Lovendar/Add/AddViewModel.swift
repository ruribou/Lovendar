//
//  AddViewModel.swift
//  Lovendar
//
//  Created by AI Assistant on 2025/09/23.
//

import Foundation
import SwiftUI
import Combine

enum ReminderOption: String, CaseIterable {
    case fiveMinutes = "5m"
    case fifteenMinutes = "15m"
    case thirtyMinutes = "30m"
    case oneHour = "1h"
    case oneDay = "1d"
    
    var displayName: String {
        switch self {
        case .fiveMinutes:
            return "5分前"
        case .fifteenMinutes:
            return "15分前"
        case .thirtyMinutes:
            return "30分前"
        case .oneHour:
            return "1時間前"
        case .oneDay:
            return "1日前"
        }
    }
}

enum EventCategory: String, CaseIterable {
    case work = "work"
    case personal = "personal"
    case health = "health"
    case social = "social"
    case travel = "travel"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .work:
            return "仕事"
        case .personal:
            return "プライベート"
        case .health:
            return "健康"
        case .social:
            return "社交"
        case .travel:
            return "旅行"
        case .other:
            return "その他"
        }
    }
    
    var color: Color {
        switch self {
        case .work:
            return .blue
        case .personal:
            return .green
        case .health:
            return .red
        case .social:
            return .orange
        case .travel:
            return .purple
        case .other:
            return .gray
        }
    }
}

@MainActor
class AddViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedDate = Date()
    @Published var startTime = Date()
    @Published var endTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @Published var isAllDay = false
    @Published var hasReminder = false
    @Published var reminderOption: ReminderOption = .fifteenMinutes
    @Published var selectedCategory: EventCategory = .personal
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isEndTimeValid
    }
    
    var isEndTimeValid: Bool {
        isAllDay || endTime > startTime
    }
    
    func saveEvent() {
        guard isFormValid else {
            showAlert(message: "必要な情報を入力してください。")
            return
        }
        
        let finalStartTime = isAllDay ? Calendar.current.startOfDay(for: selectedDate) : 
                           Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: startTime),
                                               minute: Calendar.current.component(.minute, from: startTime),
                                               second: 0,
                                               of: selectedDate) ?? selectedDate
        
        let finalEndTime = isAllDay ? Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: selectedDate)) ?? selectedDate :
                         Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: endTime),
                                             minute: Calendar.current.component(.minute, from: endTime),
                                             second: 0,
                                             of: selectedDate) ?? selectedDate
        
        let newEvent = Event(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            date: selectedDate,
            startTime: finalStartTime,
            endTime: finalEndTime,
            isAllDay: isAllDay
        )
        
        // TODO: 実際にイベントを保存する処理
        print("新しい予定を保存: \(newEvent.title)")
        
        if hasReminder {
            scheduleNotification(for: newEvent)
        }
        
        clearForm()
    }
    
    func clearForm() {
        title = ""
        description = ""
        selectedDate = Date()
        startTime = Date()
        endTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        isAllDay = false
        hasReminder = false
        reminderOption = .fifteenMinutes
        selectedCategory = .personal
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    private func scheduleNotification(for event: Event) {
        // TODO: 実際の通知設定処理
        print("通知をスケジュール: \(event.title) - \(reminderOption.displayName)")
    }
}