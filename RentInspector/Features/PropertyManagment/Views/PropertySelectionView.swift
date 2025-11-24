import SwiftUI

struct PropertySelectionView: View {
    @Binding var selectedProperty: Property?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var realmManager: RealmManager // Беремо список звідси
    
    var body: some View {
        NavigationStack {
            List {
                // Опція "Без прив'язки"
                Button(action: {
                    selectedProperty = nil
                    dismiss()
                }) {
                    Text("Не прив'язувати")
                        .foregroundColor(.secondary)
                }
                
                // Список існуючих
                ForEach(realmManager.properties) { property in
                    Button(action: {
                        selectedProperty = property
                        dismiss()
                    }) {
                        HStack {
                            Text(property.displayName)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if selectedProperty?.id == property.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Оберіть об'єкт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
        }
        .onAppear {
            // Переконуємось, що дані свіжі
            if realmManager.properties.isEmpty {
                realmManager.loadProperties()
            }
        }
    }
}
