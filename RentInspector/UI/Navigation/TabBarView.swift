/*
 UI-елемент: Навігація
 */
import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var realmManager: RealmManager
    @State private var selectedTab: Tab = .records
    
    enum Tab {
        case records
        case profile
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Records Tab
            NavigationStack {
                RecordsView()
            }
            .tabItem {
                Label("Records", systemImage: "doc.text.fill")
            }
            .tag(Tab.records)
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(Tab.profile)
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .tint(.blue) // Колір активної іконки
    }
}

#Preview {
    TabBarView()
        .environmentObject(RealmManager.shared)
        .environmentObject(ThemeManager.shared)
}
