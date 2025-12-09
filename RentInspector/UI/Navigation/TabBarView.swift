/*
 UI-елемент: Навігація
 */
internal import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var realmManager: RealmManager
    @State private var selectedTab: Tab = .recent
    
    enum Tab {
        case properties
        case recent
        case profile
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. Вкладка "Об'єкти" (Properties)
            // PropertiesListView вже має свій NavigationStack всередині
            PropertiesListView()
                .tabItem {
                    Label("tab_properties", systemImage: "building.2.fill")
                }
                .tag(Tab.properties)
            
            // 2. Вкладка "Останні" (Recent, RecordsView)
            NavigationStack {
                RecordsView()
            }
            .tabItem {
                Label("tab_records", systemImage: "clock.fill")
            }
            .tag(Tab.recent)
            
            // 3. Profile Tab
//            NavigationStack {
//                ProfileView()
//            }
//            .tabItem {
//                Label("tab_profile", systemImage: "person.fill")
//            }
//            .tag(Tab.profile)
            
            // 4. Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("tab_settings", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .tint(AppTheme.primaryColor) 
    }
}

#Preview {
    TabBarView()
        .environmentObject(RealmManager.shared)
        .environmentObject(ThemeManager.shared)
}
