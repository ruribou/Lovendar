import SwiftUI
import Foundation

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var apiConfig = APIConfig.shared
    @State private var viewMode: CalendarViewMode = .month
    @State private var showCalendarPicker = false
    @State private var selectedEventForDetail: Event?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    private let hourHeight: CGFloat = 60
    private let hours = Array(0...23)
    
    // 年月テキストの色を計算するプロパティ
    private var monthYearTextColor: LinearGradient {
        switch themeManager.currentTheme {
        case .skyBlue:
            // 青色テーマの場合、より濃い青色を使用してコントラストを高める
            return LinearGradient(
                colors: [Color(red: 0.1, green: 0.2, blue: 0.6), Color(red: 0.0, green: 0.3, blue: 0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            // 緑色テーマの場合、より濃い緑色を使用してコントラストを高める
            return LinearGradient(
                colors: [Color(red: 0.1, green: 0.5, blue: 0.2), Color(red: 0.0, green: 0.4, blue: 0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .yellow:
            // 黄色テーマの場合、濃いオレンジ色を使用してコントラストを高める
            return LinearGradient(
                colors: [Color(red: 0.9, green: 0.5, blue: 0.0), Color(red: 0.8, green: 0.4, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pink:
            // ピンクテーマの場合は従来のグラデーションを使用
            return themeManager.currentTheme.gradient
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // ポップな背景グラデーション（テーマに応じて変化）
                LinearGradient(
                    gradient: Gradient(colors: themeManager.currentTheme.backgroundGradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                // メインコンテンツ
                if viewMode == .month {
                    // 月表示モード - 全体をScrollViewで囲む
                    ScrollView {
                        VStack(spacing: 0) {
                            // カレンダーヘッダー
                            calendarHeader
                            
                            // 曜日ヘッダー
                            weekdayHeader
                            
                            // カレンダーグリッド
                            calendarGrid
                            
                            // 選択された日の予定リスト（ScrollViewを削除してVStackに変更）
                            selectedDateEventsForMonthView
                        }
                    }
                    .refreshable {
                        await refreshData()
                    }
                } else {
                    // タイムライン表示モード（既存のスワイプ更新機能を維持）
                    VStack(spacing: 0) {
                        // カレンダーヘッダー
                        calendarHeader
                        
                        timelineView
                    }
                }
                
                // カレンダーピッカーオーバーレイ（最前面に表示）
                if showCalendarPicker {
                    VStack {
                        Spacer()
                            .frame(height: 100) // ヘッダー分のスペース
                        
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        showCalendarPicker = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                .padding(8)
                            }
                            
                            DatePicker("日付選択", selection: $viewModel.selectedDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .frame(height: 300)
                                .padding(.horizontal)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.2), radius: 10)
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .transition(.opacity)
                    .zIndex(1) // 最前面に表示
                    .background(
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showCalendarPicker = false
                                }
                            }
                    )
                }
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedEventForDetail) { event in
            EventDetailView(event: event)
        }
        .onAppear {
            Task {
                await refreshData()
            }
        }
    }
    
    // データ更新用の共通関数
    private func refreshData() async {
        // API接続テストを先に実行
        await apiConfig.testConnection()
        // その後イベントを読み込み
        await viewModel.refresh()
    }
    
    private var calendarHeader: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .symbolRenderingMode(.hierarchical)
                }
                
                Spacer()
                
                Text(viewModel.monthYearString(from: viewModel.currentMonth))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(monthYearTextColor)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showCalendarPicker.toggle()
                        }
                    }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            
            HStack {
                Spacer()
                
                // 表示モード切り替えアイコンボタン
                HStack(spacing: 20) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                        Button(action: {
                            withAnimation {
                                viewMode = mode
                                // カレンダーピッカーが表示されている場合は閉じる
                                if showCalendarPicker {
                                    showCalendarPicker = false
                                }
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: mode.systemIcon)
                                    .font(.system(size: 22))
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(
                                        viewMode == mode ? 
                                        themeManager.currentTheme.gradient :
                                        LinearGradient(
                                            colors: [.gray],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .scaleEffect(viewMode == mode ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewMode)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        viewMode == mode ? 
                                        themeManager.currentTheme.gradient :
                                        LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .frame(width: 20, height: 3)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.daysInMonth(for: viewModel.currentMonth), id: \.self) { date in
                CalendarDayView(
                    date: date,
                    isInCurrentMonth: viewModel.isDateInCurrentMonth(date),
                    isToday: viewModel.isToday(date),
                    isSelected: viewModel.isSelected(date),
                    hasEvents: viewModel.hasEventsForDate(date)
                ) {
                    viewModel.selectedDate = date
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var selectedDateEvents: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: viewModel.selectedDate))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            let events = viewModel.eventsForDate(viewModel.selectedDate)
            
            // ローディング状態の表示
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("イベントを読み込み中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            // エラーメッセージの表示
            else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("再試行") {
                        Task {
                            await refreshData()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            // イベントが空の場合
            else if events.isEmpty {
                Text("予定はありません")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            // イベント一覧表示
            else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(events) { event in
                            EventRowView(event: event)
                                .onTapGesture {
                                    selectedEventForDetail = event
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }
    
    // 月表示モード用の選択された日のイベント表示（ScrollViewなし）
    private var selectedDateEventsForMonthView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: viewModel.selectedDate))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            let events = viewModel.eventsForDate(viewModel.selectedDate)
            
            // ローディング状態の表示
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("イベントを読み込み中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            // エラーメッセージの表示
            else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("再試行") {
                        Task {
                            await refreshData()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            // イベントが空の場合
            else if events.isEmpty {
                Text("予定はありません")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            // イベント一覧表示（ScrollViewなし、LazyVStackのまま）
            else {
                LazyVStack(spacing: 8) {
                    ForEach(events) { event in
                        EventRowView(event: event)
                            .onTapGesture {
                                selectedEventForDetail = event
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    // タイムライン表示モード
    private var timelineView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(hours, id: \.self) { hour in
                    TimelineHourView(
                        hour: hour,
                        events: eventsForHour(hour),
                        hourHeight: hourHeight,
                        onEventTap: { event in
                            selectedEventForDetail = event
                        }
                    )
                }
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await refreshData()
        }
    }
    
    private func eventsForHour(_ hour: Int) -> [Event] {
        let calendar = Calendar.current
        return viewModel.eventsForDate(viewModel.selectedDate).filter { event in
            if event.isAllDay { return hour == 0 } // 終日イベントは0時に表示
            
            let eventHour = calendar.component(.hour, from: event.startTime)
            return eventHour == hour
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.currentMonth) ?? viewModel.currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.currentMonth) ?? viewModel.currentMonth
        }
    }
}

struct CalendarDayView: View {
    @StateObject private var themeManager = ThemeManager.shared
    let date: Date
    let isInCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let hasEvents: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                if hasEvents {
                    Circle()
                        .fill(themeManager.currentTheme.gradient)
                        .frame(width: 5, height: 5)
                        .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.4), radius: 2)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(width: 40, height: 40)
            .background(backgroundColor)
            .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if !isInCurrentMonth {
            return .gray.opacity(0.3)
        } else if isSelected {
            return .white
        } else if isToday {
            return .accentColor
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return themeManager.currentTheme.primaryColor
        } else if isToday {
            return themeManager.currentTheme.primaryColor.opacity(0.15)
        } else {
            return .clear
        }
    }
}

struct EventRowView: View {
    let event: Event
    @StateObject private var oshiViewModel = OshiViewModel.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(eventColor)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: event.eventType.systemIcon)
                        .foregroundColor(eventColor)
                        .font(.caption)
                    
                    Text(event.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    if !event.isAllDay {
                        if let endTime = event.endTime {
                            Text(timeFormatter.string(from: event.startTime) + " - " + timeFormatter.string(from: endTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(timeFormatter.string(from: event.startTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("終日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let oshiId = event.oshiId,
                       let oshi = oshiViewModel.oshiList.first(where: { $0.serverId == oshiId }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(oshi.displayColor)
                                .frame(width: 8, height: 8)
                            Text(oshi.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: eventColor.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    private var eventColor: Color {
        if let oshiId = event.oshiId,
           let oshi = oshiViewModel.oshiList.first(where: { $0.serverId == oshiId }) {
            return oshi.displayColor
        }
        return Color.accentColor
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

// タイムライン表示用のビュー
struct TimelineHourView: View {
    let hour: Int
    let events: [Event]
    let hourHeight: CGFloat
    let onEventTap: (Event) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 時刻表示
            VStack {
                Text(String(format: "%02d", hour))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Text("00")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)
            .padding(.top, 4)
            
            // 区切り線
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
            
            // イベント表示エリア
            VStack(alignment: .leading, spacing: 4) {
                if events.isEmpty {
                    // 空の時間帯
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: hourHeight)
                } else {
                    ForEach(events) { event in
                        EventRowView(event: event)
                            .onTapGesture {
                                onEventTap(event)
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
        }
        .frame(height: hourHeight)
        .overlay(
            // 時刻の区切り線
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

// イベント詳細表示View
struct EventDetailView: View {
    let event: Event
    @StateObject private var oshiViewModel = OshiViewModel.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // イベントタイトル
                    HStack {
                        Image(systemName: event.eventType.systemIcon)
                            .foregroundColor(eventColor)
                            .font(.title2)
                        
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    // 日時情報
                    VStack(alignment: .leading, spacing: 8) {
                        Label("日時", systemImage: "calendar")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        HStack {
                            Text(dateFormatter.string(from: event.startTime))
                                .font(.body)
                            
                            if !event.isAllDay {
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                if let endTime = event.endTime {
                                    Text(timeFormatter.string(from: event.startTime) + " - " + timeFormatter.string(from: endTime))
                                        .font(.body)
                                } else {
                                    Text(timeFormatter.string(from: event.startTime))
                                        .font(.body)
                                }
                            } else {
                                Text("• 終日")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 推し情報
                    if let oshiId = event.oshiId,
                       let oshi = oshiViewModel.oshiList.first(where: { $0.serverId == oshiId }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("推し", systemImage: "heart.fill")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            HStack {
                                Circle()
                                    .fill(Color.init(hex: oshi.color) ?? .pink)
                                    .frame(width: 20, height: 20)
                                
                                Text(oshi.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // 説明
                    if !event.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("詳細", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            Text(event.description)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("イベント詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var eventColor: Color {
        if let oshiId = event.oshiId,
           let oshi = oshiViewModel.oshiList.first(where: { $0.serverId == oshiId }) {
            return Color.init(hex: oshi.color) ?? themeManager.currentTheme.primaryColor
        }
        return themeManager.currentTheme.primaryColor
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
}

#Preview {
    CalendarView()
}
