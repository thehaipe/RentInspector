//
//  SearchBarView.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
            
            TextField("Пошук за назвою...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(AppTheme.tertiaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }
}

#Preview {
    SearchBar(text: .constant("Test"))
        .padding()
}
