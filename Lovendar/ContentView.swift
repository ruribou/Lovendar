import SwiftUI

struct ContentView: View {
    @StateObject private var router = Router.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(TabSelection.allCases, id: \.self) { (tab: TabSelection) in
                getViewForTab(tab)
                    .tabItem {
                        Label {
                            Text(tab.title)
                        } icon: {
                            Image(systemName: router.selectedTab == tab ? tab.systemIcon : tab.unselectedIcon)
                                .renderingMode(.template)
                        }
                    }
                    .tag(tab)
            }
        }
        .accentColor(themeManager.currentTheme.primaryColor)
        .tint(themeManager.currentTheme.primaryColor)
    }
    
    @ViewBuilder
    private func getViewForTab(_ tab: TabSelection) -> some View {
        switch tab {
        case .calendar:
            CalendarView()
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
