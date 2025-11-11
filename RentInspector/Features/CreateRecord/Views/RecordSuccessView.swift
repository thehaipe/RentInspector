//
//  RecordSuccessView.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI

struct RecordSuccessView: View {
    let record: Record  
    let onExportPDF: () -> Void
    let onDismiss: () -> Void
    
    //@State private var showShareSheet = false
    @State private var pdfURL: URL?
    
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
                
                Text(record.displayTitle)
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Кнопки
            VStack(spacing: 16) {
                Button(action: {
                    exportPDF()
                }) {
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
        .sheet(item: $pdfURL) { url in
            ShareSheet(items: [url, record.displayTitle])
        }
    }
    
    private func exportPDF() {
            if let url = PDFExportService.shared.generatePDF(for: record) {
                pdfURL = url
            }
        }
}

// Share Sheet для SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let record = Record(title: "Квартира на Шевченка", stage: .moveIn)
    
    return RecordSuccessView(
        record: record,
        onExportPDF: {},
        onDismiss: {}
    )
}

