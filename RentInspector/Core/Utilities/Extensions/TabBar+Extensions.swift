extension TabBarView.Tab {
    var iconName: String {
        switch self {
        case .properties: return "building.2"
        case .recent: return "clock"
        case .settings: return "gearshape"
        case .profile: return "person"
        }
    }
    
    var title: String {
        switch self {
        case .properties: return "tab_properties".localized
        case .recent: return "tab_records".localized
        case .settings: return "tab_settings".localized
        case .profile: return "tab_profile".localized
        }
    }
}

extension TabBarView.Tab: CaseIterable {
    static var allCases: [TabBarView.Tab] {
        return [.properties, .recent, .settings]
    }
}
