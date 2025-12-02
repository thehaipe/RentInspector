import SwiftUI

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
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
