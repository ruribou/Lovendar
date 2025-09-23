import SwiftUI
import Combine

// MARK: - Tab Selection
enum TabSelection: CaseIterable, Hashable {
    case calendar
    case timeline
    case oshi
    case settings
    
    var title: String {
        switch self {
        case .calendar:
            return "カレンダー"
        case .timeline:
            return "タイムライン"
        case .oshi:
            return "推し"
        case .settings:
            return "設定"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .calendar:
            return "calendar"
        case .timeline:
            return "clock"
        case .oshi:
            return "heart.fill"
        case .settings:
            return "gearshape"
        }
    }
}

// MARK: - Router Class
@MainActor
class Router: ObservableObject {
    @Published var selectedTab: TabSelection = .calendar
    
    static let shared = Router()
    
    private init() {}
    
    func navigate(to tab: TabSelection) {
        selectedTab = tab
    }
}
