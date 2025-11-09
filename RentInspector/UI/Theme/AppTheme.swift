//
//  AppTheme.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI

struct AppTheme {
    // MARK: - Colors
    
    static let primaryColor = Color.blue
    static let secondaryColor = Color.gray
    static let accentColor = Color.orange
    
    static let backgroundColor = Color(uiColor: .systemBackground)
    static let secondaryBackgroundColor = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackgroundColor = Color(uiColor: .tertiarySystemBackground)
    
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    static let successColor = Color.green
    static let errorColor = Color.red
    static let warningColor = Color.orange
    
    // MARK: - Fonts
    
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)
    
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let caption = Font.caption
    
    // MARK: - Spacing
    
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingExtraLarge: CGFloat = 32
    
    // MARK: - Corner Radius
    
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    
    // MARK: - Shadows
    
    static let shadowRadius: CGFloat = 8
    static let shadowColor = Color.black.opacity(0.1)
}
