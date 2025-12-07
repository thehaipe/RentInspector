/*
 Опис типів кімнат. Тут описані базові, у майбутньому цей enum легко розширити без переписування всього додатку
 */
import Foundation
internal import SwiftUI
enum RoomType: String, Codable, CaseIterable {
    case bedroom = "Bedroom"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case balcony = "Balcony"
    case loggia = "Loggia"
    case wardrobe = "Wardrobe"
    case storage = "Storage"
    case other = "Other"
    
    var displayName: LocalizedStringKey {
            let key = "room_type_\(self.rawValue)"
            return LocalizedStringKey(key)
        }
    
    var icon: String {
        switch self {
        case .bedroom: return "bed.double.fill"
        case .kitchen: return "fork.knife"
        case .bathroom: return "shower.fill"
        case .balcony: return "sun.max.fill"
        case .loggia: return "rectangle.stack.fill"
        case .wardrobe: return "cabinet.fill"
        case .storage: return "archivebox.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

