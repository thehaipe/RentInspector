internal import SwiftUI

struct PropertySelectionView: View {
    @Binding var selectedProperty: Property?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var realmManager: RealmManager // Беремо список звідси
    @StateObject private var viewModel = PropertyViewModel()
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
                Button {
                    viewModel.showAddPropertySheet = true
                } label: {
                    Text("add_property")
                        .font(AppTheme.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }

            }
            .sheet(isPresented: $viewModel.showAddPropertySheet) {
                addPropertySheet
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
    private var addPropertySheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("property_information")) {
                    TextField("property_placeholder_name_label", text: $viewModel.newPropertyName)
                    TextField("property_placeholder_address_label", text: $viewModel.newPropertyAddress)
                }
            }
            .navigationTitle("records_new_property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("general_cancel") {
                        viewModel.showAddPropertySheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("general_save") {
                        viewModel.createProperty()
                    }
                    .disabled(viewModel.newPropertyName.isEmpty && viewModel.newPropertyAddress.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

