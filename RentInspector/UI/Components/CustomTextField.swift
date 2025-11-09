//
//  CustomTextField.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(AppTheme.tertiaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusSmall)
            .font(AppTheme.body)
    }
}
