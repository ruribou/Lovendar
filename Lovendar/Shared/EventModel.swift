//
//  EventModel.swift
//  Lovendar
//
//  Created by AI Assistant on 2025/09/23.
//

import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var isAllDay: Bool
    
    init(title: String, description: String = "", date: Date, startTime: Date? = nil, endTime: Date? = nil, isAllDay: Bool = false) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.date = date
        self.isAllDay = isAllDay
        
        if isAllDay {
            self.startTime = Calendar.current.startOfDay(for: date)
            self.endTime = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)) ?? date
        } else {
            self.startTime = startTime ?? date
            self.endTime = endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: startTime ?? date) ?? date
        }
    }
}

extension Event {
    static let sampleEvents: [Event] = [
        Event(title: "ミーティング", description: "チームとの定例会議", date: Date(), startTime: Date(), endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()),
        Event(title: "誕生日", description: "友人の誕生日", date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), isAllDay: true),
        Event(title: "歯医者", description: "定期検診", date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date())
    ]
}