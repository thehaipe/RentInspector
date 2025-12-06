/*
 UI-елемент: Поле пошуку
 */
internal import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(AppTheme.tertiaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusSmall)
            .font(AppTheme.body)
    }
}
