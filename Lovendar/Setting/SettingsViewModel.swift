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
    @Published var weekStart: WeekStart = .sunday
    @Published var timeFormat: TimeFormat = .twentyFourHour
    @Published var showingExportAlert = false
    @Published var showingDeleteAlert = false
    @Published var showingLogoutAlert = false
    @Published var isRefreshingUserInfo = false
    @Published var userInfoErrorMessage: String?
    
    // テーママネージャーへの参照
    let themeManager = ThemeManager.shared
    private let authManager = AuthManager.shared
    private let apiService = APIService.shared
    private let notificationManager = NotificationManager.shared
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        observeChanges()
        syncNotificationStatus()
    }
    
    private func loadSettings() {
        notificationsEnabled = userDefaults.bool(forKey: "notificationsEnabled")
        
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
            .dropFirst() // 初回ロード時はスキップ
            .sink { [weak self] value in
                guard let self = self else { return }
                self.userDefaults.set(value, forKey: "notificationsEnabled")
                
                // 通知をONにした場合は権限をリクエスト
                if value {
                    Task {
                        await self.requestNotificationPermission()
                    }
                }
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
    
    // 通知権限の状態を同期
    private func syncNotificationStatus() {
        notificationManager.$authorizationStatus
            .sink { [weak self] status in
                guard let self = self else { return }
                // 権限が拒否された場合は設定をOFFに
                if status == .denied {
                    self.notificationsEnabled = false
                }
            }
            .store(in: &cancellables)
    }
    
    // 通知権限をリクエスト
    func requestNotificationPermission() async {
        let granted = await notificationManager.requestAuthorization()
        if !granted {
            // 権限が拒否された場合は設定をOFFに戻す
            notificationsEnabled = false
        }
    }
    
    func exportData() {
        // TODO: 実際のデータエクスポート処理
        print("データをエクスポートしています...")
    }
    
    func deleteAllData() {
        // TODO: 実際のデータ削除処理
        print("すべてのデータを削除しています...")
    }
    
    // ユーザー情報を更新
    func refreshUserInfo() async {
        guard authManager.isAuthenticated else { return }
        
        isRefreshingUserInfo = true
        userInfoErrorMessage = nil
        
        do {
            let userInfo = try await apiService.getUserInfo()
            let updatedUser = User(id: authManager.currentUser?.id, name: userInfo.name, email: userInfo.email)
            
            // AuthManagerのユーザー情報を更新
            authManager.login(token: authManager.getAuthToken() ?? "", user: updatedUser)
            
        } catch let error as NetworkError {
            userInfoErrorMessage = error.localizedDescription
        } catch {
            userInfoErrorMessage = "ユーザー情報の更新に失敗しました"
        }
        
        isRefreshingUserInfo = false
    }
}