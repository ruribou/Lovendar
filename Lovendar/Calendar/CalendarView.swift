import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var viewMode: CalendarViewMode = .month
    @State private var showCalendarPicker = false
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    private let hourHeight: CGFloat = 60
    private let hours = Array(0...23)
    
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
                VStack(spacing: 0) {
                    // カレンダーヘッダー
                    calendarHeader
                    
                    // 表示モードによって内容を切り替え
                    if viewMode == .month {
                        // 月表示モード
                        VStack(spacing: 0) {
                            // 曜日ヘッダー
                            weekdayHeader
                            
                            // カレンダーグリッド
                            calendarGrid
                            
                            // 選択された日の予定リスト
                            selectedDateEvents
                        }
                    } else {
                        // タイムライン表示モード
                        timelineView
                    }
                    
                    Spacer()
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
                    .foregroundStyle(themeManager.currentTheme.gradient)
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
            
            if events.isEmpty {
                Text("予定はありません")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(events) { event in
                            EventRowView(event: event)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
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
                        hourHeight: hourHeight
                    )
                }
            }
        }
        .scrollIndicators(.hidden)
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
                        Text(timeFormatter.string(from: event.startTime) + " - " + timeFormatter.string(from: event.endTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("終日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let oshiId = event.oshiId,
                       let oshi = oshiViewModel.oshiList.first(where: { $0.id == oshiId }) {
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
           let oshi = oshiViewModel.oshiList.first(where: { $0.id == oshiId }) {
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

#Preview {
    CalendarView()
}
