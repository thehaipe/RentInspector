import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertyViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.properties.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(viewModel.properties) { property in
                            NavigationLink(destination: PropertyDetailView(property: property)){
                                HStack(spacing: 16) {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(AppTheme.primaryColor)
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(AppTheme.primaryColor.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        if !property.name.isEmpty {
                                            Text(property.name)
                                                .font(AppTheme.headline)
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                        
                                        Text(property.address.isEmpty ? "Без адреси" : property.address)
                                            .font(property.name.isEmpty ? AppTheme.headline : AppTheme.caption)
                                            .foregroundColor(property.name.isEmpty ? AppTheme.textPrimary : AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Лічильник звітів (поки 0, бо зв'язок ще не заповнюється)
                                    Text("\(property.records.count)")
                                        .font(AppTheme.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.secondaryBackgroundColor)
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: viewModel.deleteProperty)
                    }
                }
            }
            .navigationTitle("Об'єкти")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.showAddPropertySheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddPropertySheet) {
                addPropertySheet
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            
            Text("Немає об'єктів")
                .font(AppTheme.title2)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Створіть свій перший об'єкт нерухомості, щоб групувати звіти.")
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.showAddPropertySheet = true
            }) {
                Text("Додати об'єкт")
                    .font(AppTheme.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.primaryColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
            .padding(.horizontal, 32)
        }
    }
    
    private var addPropertySheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Інформація про об'єкт")) {
                    TextField("Назва (напр. Офіс)", text: $viewModel.newPropertyName)
                    TextField("Адреса (напр. вул. Хрещатик 1)", text: $viewModel.newPropertyAddress)
                }
            }
            .navigationTitle("Новий об'єкт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        viewModel.showAddPropertySheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        viewModel.createProperty()
                    }
                    .disabled(viewModel.newPropertyName.isEmpty && viewModel.newPropertyAddress.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
