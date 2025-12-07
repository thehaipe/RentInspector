/*
 Опис стадій. Заселення, Проживання, Виселення
 */
import Foundation
internal import SwiftUI // for LocalizedStringKey
enum RecordStage: String, Codable, CaseIterable {
    case moveIn = "Move In"
    case living = "Living"
    case moveOut = "Move Out"
    
    var displayName: LocalizedStringKey {
        let key = "stage_\(self.rawValue)"
        return LocalizedStringKey(key)
    }
    
    var icon: String {
        switch self {
        case .moveIn: return "arrow.down.circle.fill"
        case .living: return "house.fill"
        case .moveOut: return "arrow.up.circle.fill"
        }
    }
}

