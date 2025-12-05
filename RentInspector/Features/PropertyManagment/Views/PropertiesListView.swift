import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertyViewModel()
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.properties.isEmpty {
                    emptyStateView
                } else {
                    propertiesContent
                }
                if viewModel.showErrorToast {
                    errorToast
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("tab_properties")
                            .font(AppTheme.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                // Тулбар 
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.properties.isEmpty {
                        HStack(spacing: 16) {
                            // 1. Пошук
                            Button(action: {
                                viewModel.toggleSearch()
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title3)
                            }
                            
                            // 2. Сортування
                            Menu {
                                ForEach(RecordsViewModel.SortOrder.allCases, id: \.self) { order in
                                    Button(action: {
                                        viewModel.setSortOrder(order)
                                    }) {
                                        Label(
                                            order.rawValue,
                                            systemImage: viewModel.sortOrder == order ? "arrow.down.circle" : order.icon
                                        )
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down.circle")
                                    .font(.title3)
                            }
                            
                            // 3. Фільтр
                            Button(action: {
                                showFilterSheet = true
                            }) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.title3)
                            }
                            
                            // 4. Додати
                            Button(action: {
                                viewModel.showAddPropertySheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    } else {
                        // Якщо пусто - тільки плюс
                        Button(action: {
                            viewModel.showAddPropertySheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddPropertySheet) {
                addPropertySheet
            }
            .sheet(isPresented: $showFilterSheet) {
                filterSheet
            }
        }
    }
    
    private var propertiesContent: some View {
        VStack(spacing: 0) {
            // Рядок пошуку
            if viewModel.isSearching {
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            List {
                ForEach(viewModel.filteredProperties) { property in
                    NavigationLink(destination: PropertyDetailView(property: property)) {
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
                                
                                Text(property.address.isEmpty ? "form_blank_address".localized : property.address)
                                    .font(property.name.isEmpty ? AppTheme.headline : AppTheme.caption)
                                    .foregroundColor(property.name.isEmpty ? AppTheme.textPrimary : AppTheme.textSecondary)
                            }
                            
                            Spacer()
                            
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
        .animation(.easeInOut, value: viewModel.isSearching)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            
            Text("no_properties")
                .font(AppTheme.title2)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("create_first_property")
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.showAddPropertySheet = true
            }) {
                Text("add_property")
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
    
    // Reuse filter sheet logic
    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("records_filter_by_date") {
                    ForEach(RecordsViewModel.DateFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            viewModel.selectedDateFilter = filter
                            showFilterSheet = false
                        }) {
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                if viewModel.selectedDateFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.primaryColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("records_filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("general_done") {
                        showFilterSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var addPropertySheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Інформація про об'єкт")) {
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
    
    private var errorToast: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.warningColor)
                
                Text(viewModel.errorMessage)
                    .font(AppTheme.callout)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding()
            .background(AppTheme.secondaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: AppTheme.shadowColor, radius: 10, y: 5)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
