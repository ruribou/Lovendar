import Foundation
import SwiftUI
import Combine

enum WeekStart: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    
    var displayName: String {
        switch self {
        case .sunday:
            return "日曜日"
        case .monday:
            return "月曜日"
        }
    }
}

enum TimeFormat: String, CaseIterable {
    case twelveHour = "12h"
    case twentyFourHour = "24h"
    
    var displayName: String {
        switch self {
        case .twelveHour:
            return "12時間表示"
        case .twentyFourHour:
            return "24時間表示"
        }
    }
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = false
    @Published var reminderMinutes: Int = 15
    @Published var weekStart: WeekStart = .sunday
    @Published var timeFormat: TimeFormat = .twentyFourHour
    @Published var showingExportAlert = false
    @Published var showingDeleteAlert = false
    @Published var showingLogoutAlert = false
    
    // テーママネージャーへの参照
    let themeManager = ThemeManager.shared
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        observeChanges()
    }
    
    private func loadSettings() {
        notificationsEnabled = userDefaults.bool(forKey: "notificationsEnabled")
        reminderMinutes = userDefaults.integer(forKey: "reminderMinutes")
        if reminderMinutes == 0 { reminderMinutes = 15 }
        
        if let weekStartRaw = userDefaults.object(forKey: "weekStart") as? Int,
           let weekStartValue = WeekStart(rawValue: weekStartRaw) {
            weekStart = weekStartValue
        }
        
        if let timeFormatRaw = userDefaults.string(forKey: "timeFormat"),
           let timeFormatValue = TimeFormat(rawValue: timeFormatRaw) {
            timeFormat = timeFormatValue
        }
    }
    
    private func observeChanges() {
        $notificationsEnabled
            .sink { [weak self] value in
                self?.userDefaults.set(value, forKey: "notificationsEnabled")
            }
            .store(in: &cancellables)
        
        $reminderMinutes
            .sink { [weak self] value in
                self?.userDefaults.set(value, forKey: "reminderMinutes")
            }
            .store(in: &cancellables)
        
        $weekStart
            .sink { [weak self] value in
                self?.userDefaults.set(value.rawValue, forKey: "weekStart")
            }
            .store(in: &cancellables)
        
        $timeFormat
            .sink { [weak self] value in
                self?.userDefaults.set(value.rawValue, forKey: "timeFormat")
            }
            .store(in: &cancellables)
    }
    
    func exportData() {
        // TODO: 実際のデータエクスポート処理
        print("データをエクスポートしています...")
    }
    
    func deleteAllData() {
        // TODO: 実際のデータ削除処理
        print("すべてのデータを削除しています...")
    }
}