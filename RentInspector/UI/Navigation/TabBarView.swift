/*
 UI-елемент: Навігація
 */
import SwiftUI

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
                    Label("Properties", systemImage: "building.2.fill")
                }
                .tag(Tab.properties)
            
            // 2. Вкладка "Останні" (Recent) - Колишній RecordsView
            NavigationStack {
                RecordsView()
            }
            .tabItem {
                Label("Recent", systemImage: "clock.fill")
            }
            .tag(Tab.recent)
            
            // 3. Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(Tab.profile)
            
            // 4. Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .tint(AppTheme.primaryColor) // Використовуємо колір з теми
    }
}

#Preview {
    TabBarView()
        .environmentObject(RealmManager.shared)
        .environmentObject(ThemeManager.shared)
}
