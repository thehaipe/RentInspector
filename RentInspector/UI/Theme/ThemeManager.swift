//
//  ThemeManager.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI
internal import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var selectedTheme: Theme = .auto {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
        
        var displayName: String {
            switch self {
            case .light: return "Світла"
            case .dark: return "Темна"
            case .auto: return "Авто"
            }
        }
        
        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .auto: return "circle.lefthalf.filled"
            }
        }
    }
    
    var currentColorScheme: ColorScheme? {
        switch selectedTheme {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
    
    private init() {
        // Завантажуємо збережену тему
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = Theme(rawValue: savedTheme) {
            self.selectedTheme = theme
        }
    }
}

