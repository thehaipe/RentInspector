//
//  View+Extensions.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI

extension View {
    /// Приховує клавіатуру
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Умовний модифікатор
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
