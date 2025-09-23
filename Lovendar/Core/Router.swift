//
//  Router.swift
//  Lovendar
//
//  Created by AI Assistant on 2025/09/23.
//

import SwiftUI
import Combine

// MARK: - Tab Selection
enum TabSelection: CaseIterable, Hashable {
    case calendar
    case add
    case settings
    
    var title: String {
        switch self {
        case .calendar:
            return "カレンダー"
        case .add:
            return "追加"
        case .settings:
            return "設定"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .calendar:
            return "calendar"
        case .add:
            return "plus.circle"
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
