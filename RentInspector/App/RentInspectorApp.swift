//Entry Point
internal import SwiftUI
import RealmSwift
internal import Combine
@main
struct RentInspectorApp: SwiftUI.App {
    @StateObject private var realmManager = RealmManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("selectedLanguage") private var languageCode = "uk"
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(realmManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentColorScheme)
                .environment(\.locale, Locale(identifier: languageCode))
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
