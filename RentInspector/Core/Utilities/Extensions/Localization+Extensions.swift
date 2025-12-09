internal import SwiftUI

extension String {
    private var localizedBundle: Bundle {
        let languageCode = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "uk"
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    var localized: String {
        // Використовуємо наш знайдений бандл замість стандартного
        return NSLocalizedString(self, tableName: nil, bundle: localizedBundle, value: "", comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        let format = NSLocalizedString(self, tableName: nil, bundle: localizedBundle, value: "", comment: "")
        return String(format: format, arguments: args)
    }
}

func localizeEnumRawValue<T: RawRepresentable>(_ value: T, prefix: String) -> String where T.RawValue == String {
    let key = "\(prefix)_\(value.rawValue)"
    // Якщо ключ не знайдено, повернеться сам ключ (але краще б повернути rawValue як фолбек)
    let result = NSLocalizedString(key, comment: "")
    return result == key ? value.rawValue : result
}

protocol LocalizableEnum {
    var localizedKeyPrefix: String { get }
    var localizedName: String { get }
}

extension LocalizableEnum where Self: RawRepresentable, Self.RawValue == String {
    var localizedName: String {
        let key = "\(localizedKeyPrefix)_\(self.rawValue)"
        return NSLocalizedString(key, comment: "")
    }
}
extension RecordsViewModel.DateFilter: LocalizableEnum {
    var localizedKeyPrefix: String { "filter" }
}

extension RecordsViewModel.SortOrder: LocalizableEnum {
    var localizedKeyPrefix: String { "sort" }
}
extension RoomType: LocalizableEnum {
    var localizedKeyPrefix: String { "room_type" }
}
extension RoomType {
    var localizedStringValue: String {
        let key = "room_type_\(self.rawValue)"
        return NSLocalizedString(key, comment: "")
    }
}
extension RecordStage {
    var localizedStringValue: String {
        let key = "stage_\(self.rawValue)"
        return NSLocalizedString(key, comment: "")
    }
}
extension ThemeManager.Theme: LocalizableEnum {
    
    var localizedName: String {
        let key = "theme_\(self.rawValue.lowercased())" // "theme_light"
        return NSLocalizedString(key, comment: "")
    }
    var localizedKeyPrefix: String { "theme" }
}
