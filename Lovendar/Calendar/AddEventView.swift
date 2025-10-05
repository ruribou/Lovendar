import SwiftUI

struct AddEventView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var oshiViewModel = OshiViewModel.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedOshi: Oshi?
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // 1時間後
    @State private var isAllDay = false
    @State private var hasAlarm = false
    @State private var notificationTiming: NotificationTiming = .fifteenMinutes
    @State private var selectedEventType: EventType = .general
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: themeManager.currentTheme.backgroundGradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    basicInfoSection
                    dateTimeSection
                    notificationSection
                    oshiSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("イベントを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty || selectedOshi == nil || isSaving)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            .alert("エラー", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section(header: Text("基本情報")) {
            TextField("タイトル", text: $title)
            
            TextField("説明（任意）", text: $description, axis: .vertical)
                .lineLimit(3...6)
            
            Picker("イベント種類", selection: $selectedEventType) {
                ForEach(EventType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.systemIcon)
                        Text(type.displayName)
                    }
                    .tag(type)
                }
            }
        }
    }
    
    private var dateTimeSection: some View {
        Section(header: Text("日時")) {
            Toggle("終日", isOn: $isAllDay)
            
            DatePicker("開始", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                .onChange(of: startDate) { oldValue, newValue in
                    // 終了日時が開始日時より前の場合は調整
                    if endDate <= newValue {
                        endDate = newValue.addingTimeInterval(3600)
                    }
                }
            
            if !isAllDay {
                DatePicker("終了", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
    
    private var notificationSection: some View {
        Section(header: Text("通知")) {
            Toggle("通知を有効にする", isOn: $hasAlarm)
                .onChange(of: hasAlarm) { oldValue, newValue in
                    if newValue {
                        // 通知がONになったら権限を確認
                        checkNotificationPermission()
                    }
                }
            
            if hasAlarm {
                Picker("通知タイミング", selection: $notificationTiming) {
                    ForEach(NotificationTiming.allCases) { timing in
                        Text(timing.displayName).tag(timing)
                    }
                }
                .pickerStyle(.menu)
                
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("イベント開始の\(notificationTiming.displayName)に通知します")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 通知許可がない場合の警告
            if hasAlarm && notificationManager.authorizationStatus != .authorized {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("設定から通知を許可してください")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func checkNotificationPermission() {
        if notificationManager.authorizationStatus == .notDetermined {
            Task {
                await notificationManager.requestAuthorization()
            }
        } else if notificationManager.authorizationStatus != .authorized {
            // 通知許可がない場合は警告を表示
            errorMessage = "通知を送信するには、設定から通知を許可してください"
            showError = true
            hasAlarm = false
        }
    }
    
    private var oshiSection: some View {
        Section(header: Text("推し")) {
            if oshiViewModel.oshiList.isEmpty {
                Text("推しが登録されていません")
                    .foregroundColor(.secondary)
            } else {
                Picker("推しを選択", selection: $selectedOshi) {
                    Text("選択してください").tag(nil as Oshi?)
                    ForEach(oshiViewModel.oshiList) { oshi in
                        HStack {
                            Circle()
                                .fill(oshi.displayColor)
                                .frame(width: 12, height: 12)
                            Text(oshi.name)
                        }
                        .tag(oshi as Oshi?)
                    }
                }
            }
        }
    }
    
    private func saveEvent() {
        guard !title.isEmpty else {
            errorMessage = "タイトルを入力してください"
            showError = true
            return
        }
        
        guard let oshi = selectedOshi else {
            errorMessage = "推しを選択してください"
            showError = true
            return
        }
        
        isSaving = true
        
        // TODO: APIへのイベント作成リクエストを実装
        // 現時点ではローカルでイベントを作成
        let event = Event(
            title: title,
            description: description,
            date: startDate,
            startTime: startDate,
            endTime: isAllDay ? nil : endDate,
            isAllDay: isAllDay,
            oshiId: oshi.serverId,
            eventType: selectedEventType,
            hasAlarm: hasAlarm,
            notificationTiming: notificationTiming.rawValue
        )
        
        // 通知をスケジュール（権限がある場合のみ）
        if hasAlarm && notificationManager.authorizationStatus == .authorized {
            NotificationManager.shared.scheduleNotification(for: event)
        }
        
        print("✅ イベント作成: \(event.title)")
        
        isSaving = false
        dismiss()
    }
}

#Preview {
    AddEventView()
}

