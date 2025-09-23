import SwiftUI

struct ContentView: View {
    @StateObject private var router = Router.shared
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(TabSelection.allCases, id: \.self) { (tab: TabSelection) in
                getViewForTab(tab)
                    .tabItem {
                        Image(systemName: tab.systemIcon)
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
        .accentColor(.primary)
    }
    
    @ViewBuilder
    private func getViewForTab(_ tab: TabSelection) -> some View {
        switch tab {
        case .calendar:
            CalendarView()
        case .timeline:
            TimelineCalendarView()
        case .oshi:
            OshiListView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
