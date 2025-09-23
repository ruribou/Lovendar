import Foundation

enum CalendarViewMode: String, CaseIterable {
    case month
    case timeline
    
    var displayName: String {
        switch self {
        case .month:
            return "月表示"
        case .timeline:
            return "タイムライン"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .month:
            return "calendar"
        case .timeline:
            return "clock"
        }
    }
}
