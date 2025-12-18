//
//  EmptyPropertiesView.swift
//  RentInspector
//
//  Created by Valentyn on 18.12.2025.
//

internal import SwiftUI
struct EmptyPropertiesView: View {
    @ObservedObject var viewModel: PropertyViewModel
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            // Іконка
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.secondaryColor.opacity(0.5))
            // Текст
            VStack(spacing: 8) {
                Text("no_properties")
                    .font(AppTheme.title2)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("create_first_property")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Кнопка створення
            Button(action: {
                viewModel.showAddPropertySheet =  true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("add_property")
                        .font(AppTheme.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.primaryColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}
