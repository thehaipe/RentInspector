//
//  RecordSuccessView.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI

struct RecordSuccessView: View {
    let recordTitle: String
    let onExportPDF: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Іконка успіху
            ZStack {
                Circle()
                    .fill(AppTheme.successColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.successColor)
            }
            
            // Текст
            VStack(spacing: 12) {
                Text("Звіт створено!")
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(recordTitle)
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Кнопки
            VStack(spacing: 16) {
                Button(action: onExportPDF) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.title3)
                        Text("Експортувати PDF")
                            .font(AppTheme.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.primaryColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, y: 4)
                }
                
                Button(action: onDismiss) {
                    Text("Готово")
                        .font(AppTheme.headline)
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.secondaryBackgroundColor)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

#Preview {
    RecordSuccessView(
        recordTitle: "Квартира на Шевченка",
        onExportPDF: {},
        onDismiss: {}
    )
}
