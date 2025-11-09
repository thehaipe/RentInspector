//
//  RecordStage.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import Foundation

enum RecordStage: String, Codable, CaseIterable {
    case moveIn = "Move In"
    case living = "Living"
    case moveOut = "Move Out"
    
    var displayName: String {
        switch self {
        case .moveIn: return "Заселення"
        case .living: return "Проживання"
        case .moveOut: return "Виселення"
        }
    }
    
    var icon: String {
        switch self {
        case .moveIn: return "arrow.down.circle.fill"
        case .living: return "house.fill"
        case .moveOut: return "arrow.up.circle.fill"
        }
    }
}
