//
//  RoomType.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import Foundation

enum RoomType: String, Codable, CaseIterable {
    case bedroom = "Bedroom"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case balcony = "Balcony"
    case loggia = "Loggia"
    case wardrobe = "Wardrobe"
    case storage = "Storage"
    case other = "Other"
    
    var displayName: String {
        switch self {
        case .bedroom: return "Кімната"
        case .kitchen: return "Кухня"
        case .bathroom: return "Санвузол"
        case .balcony: return "Балкон"
        case .loggia: return "Лоджа"
        case .wardrobe: return "Гардероб"
        case .storage: return "Кладова"
        case .other: return "Інше"
        }
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
