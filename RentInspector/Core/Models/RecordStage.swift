/*
 Опис стадій. Заселення, Проживання, Виселення
 */
import Foundation

enum RecordStage: String, Codable, CaseIterable {
    case moveIn = "Move In"
    case living = "Living"
    case moveOut = "Move Out"
    
    var displayName: String {
        return localizedName
    }
    
    var icon: String {
        switch self {
        case .moveIn: return "arrow.down.circle.fill"
        case .living: return "house.fill"
        case .moveOut: return "arrow.up.circle.fill"
        }
    }
}
extension RecordStage: LocalizableEnum {
    var localizedKeyPrefix: String { "stage" }
}
