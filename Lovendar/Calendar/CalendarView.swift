import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // カレンダーヘッダー
                calendarHeader
                
                // 曜日ヘッダー
                weekdayHeader
                
                // カレンダーグリッド
                calendarGrid
                
                Divider()
                
                // 選択された日の予定リスト
                selectedDateEvents
                
                Spacer()
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var calendarHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(viewModel.monthYearString(from: viewModel.currentMonth))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
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
                        .fill(Color.accentColor)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
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
            return .accentColor
        } else if isToday {
            return .accentColor.opacity(0.1)
        } else {
            return .clear
        }
    }
}

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if !event.isAllDay {
                    Text(timeFormatter.string(from: event.startTime) + " - " + timeFormatter.string(from: event.endTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

#Preview {
    CalendarView()
}