import SwiftUI

struct TimelineCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate = Date()
    
    private let hourHeight: CGFloat = 60
    private let hours = Array(0...23)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 日付選択ヘッダー
                dateSelectionHeader
                
                Divider()
                
                // タイムライン
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
            .navigationTitle("タイムライン")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var dateSelectionHeader: some View {
        VStack {
            DatePicker("日付選択", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .frame(height: 300)
                .padding(.horizontal)
            
            HStack {
                Text(dateFormatter.string(from: selectedDate))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                let dayEvents = viewModel.eventsForDate(selectedDate)
                Text("\(dayEvents.count)件の予定")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    private func eventsForHour(_ hour: Int) -> [Event] {
        let calendar = Calendar.current
        return viewModel.eventsForDate(selectedDate).filter { event in
            if event.isAllDay { return hour == 0 } // 終日イベントは0時に表示
            
            let eventHour = calendar.component(.hour, from: event.startTime)
            return eventHour == hour
        }
    }
}

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
                        TimelineEventView(event: event)
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

struct TimelineEventView: View {
    let event: Event
    @StateObject private var oshiViewModel = OshiViewModel.shared
    
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
                        .font(.subheadline)
                        .fontWeight(.medium)
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
                        Text("\(timeFormatter.string(from: event.startTime)) - \(timeFormatter.string(from: event.endTime))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("終日")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let oshiId = event.oshiId,
                       let oshi = oshiViewModel.oshiList.first(where: { $0.id == oshiId }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(oshi.displayColor)
                                .frame(width: 12, height: 12)
                            Text(oshi.name)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(eventColor.opacity(0.1))
        .cornerRadius(8)
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

#Preview {
    TimelineCalendarView()
}
