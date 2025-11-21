//Entry Point
import SwiftUI
import RealmSwift
internal import Combine
@main
struct RentInspectorApp: SwiftUI.App {
    @StateObject private var realmManager = RealmManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(realmManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentColorScheme)
        }
    }
    
    private func configureAppearance() {
        // Налаштування UITabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Налаштування UINavigationBar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}
