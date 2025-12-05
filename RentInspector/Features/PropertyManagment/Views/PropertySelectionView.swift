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
                    Text("not_attach_to_property")
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
            .navigationTitle("choose_property_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("general_cancel") { dismiss() }
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
