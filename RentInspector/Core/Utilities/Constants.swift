
import Foundation

struct Constants {
    // MARK: - User Defaults Keys
    
    struct UserDefaultsKeys {
        static let userName = "userName"
        static let selectedTheme = "selectedTheme"
        static let isFirstLaunch = "isFirstLaunch"
    }
    
    // MARK: - App Info
    
    struct AppInfo {
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Limits
    
    struct Limits {
        static let maxPhotosPerRoom = 10
        static let maxRoomNameLength = 50
        static let maxCommentLength = 500
        static let maxRecordTitleLength = 100
    }
    
    // MARK: - Default Values
    
    struct Defaults {
        static let defaultUserName = "User"
        static let defaultRecordTitle = "Record"
        static let minReminderInterval = 30 // днів
        static let maxReminderInterval = 365 // днів
    }
    
    enum AppLanguage: String, CaseIterable, Identifiable {
        case ukrainian = "uk"
        case english = "en"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .ukrainian: return "Українська"
            case .english: return "English"
            }
        }
    }
}
