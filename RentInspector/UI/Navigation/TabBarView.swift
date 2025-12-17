internal import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var realmManager: RealmManager
    @State private var selectedTab: Tab = .recent
    init() {
            //Приховування системного таббару
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = .clear
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    enum Tab {
        case properties
        case recent
        case profile
        case settings
    }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            nativeTabView
        } else {
            customTabView
        }
    }
    
    // MARK: - Native (iOS 18+)
    @ViewBuilder
    private var nativeTabView: some View {
        TabView(selection: $selectedTab) {
            PropertiesListView()
                .tabItem { Label("tab_properties", systemImage: "building.2.fill") }
                .tag(Tab.properties)
            
            NavigationStack { RecordsView() }
                .tabItem { Label("tab_records", systemImage: "clock.fill") }
                .tag(Tab.recent)
            
            NavigationStack { SettingsView() }
                .tabItem { Label("tab_settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(AppTheme.primaryColor)
    }
    
    // MARK: - Custom (iOS < 18)
    @ViewBuilder
    private var customTabView: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                PropertiesListView()
                    .tag(Tab.properties)
                    .toolbar(.hidden, for: .tabBar)
                NavigationStack { RecordsView() }
                    .tag(Tab.recent)
                    .toolbar(.hidden, for: .tabBar)
                NavigationStack { SettingsView() }
                    .tag(Tab.settings)
                    .toolbar(.hidden, for: .tabBar)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}
