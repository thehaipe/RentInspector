internal import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertyViewModel()
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.properties.isEmpty {
                        emptyStateView
                            .padding(.top, 40)
                    } else {
                        propertiesList
                    }
                }
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    customHeader
                    
                    if viewModel.isSearching {
                        SearchBar(text: $viewModel.searchText)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                            .background(AppTheme.backgroundColor)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .background(
                    AppTheme.backgroundColor.ignoresSafeArea(edges: .top)
                )
            }
            .overlay(alignment: .top) {
                if viewModel.showErrorToast {
                    errorToast
                        .padding(.top, viewModel.isSearching ? 160 : 110)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $viewModel.showAddPropertySheet) {
                addPropertySheet
            }
            .sheet(isPresented: $showFilterSheet) {
                if #available(iOS 18.0, *) {
                    NativeFilterSheetView(
                        selectedFilter: $viewModel.selectedDateFilter,
                        isPresented: $showFilterSheet
                    )
                } else {
                    FilterSheetView(
                        selectedFilter: $viewModel.selectedDateFilter,
                        isPresented: $showFilterSheet
                    )
                }
            }
        }
    }
    
    // MARK: - Custom Header
    
    private var customHeader: some View {
        CustomTopBar(title: "tab_properties") {
            if !viewModel.properties.isEmpty {
                TopBarButton(icon: "magnifyingglass") {
                    withAnimation { viewModel.toggleSearch() }
                }
                
                Menu {
                    ForEach(RecordsViewModel.SortOrder.allCases, id: \.self) { order in
                        Button(action: { viewModel.setSortOrder(order) }) {
                            Label(order.displayName, systemImage: viewModel.sortOrder == order ? "arrow.down.circle" : order.icon)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(width: 28, height: 28)
                        .overlay(Circle().strokeBorder(AppTheme.primaryColor, lineWidth: 1.5))
                }
                
                Button(action: { showFilterSheet = true }) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(width: 28, height: 28)
                        .overlay(Circle().strokeBorder(AppTheme.primaryColor, lineWidth: 1.5))
                }
                TopBarPrimaryButton {
                    viewModel.showAddPropertySheet = true
                }
            }
        }
    }
    
    // MARK: - Properties List
    
    private var propertiesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredProperties) { property in
                NavigationLink(destination: PropertyDetailView(property: property)) {
                    // Картка об'єкту
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
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Text(property.address.isEmpty ? "form_blank_address".localized : property.address)
                                .font(property.name.isEmpty ? AppTheme.headline : AppTheme.caption)
                                .foregroundColor(property.name.isEmpty ? AppTheme.textPrimary : AppTheme.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        // Лічильник
                        HStack(spacing: 4) {
                            Text("\(property.records.count)")
                                .font(AppTheme.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textPrimary)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.secondaryBackgroundColor)
                        .cornerRadius(8)
                    }
                    .padding(16)
                    .background(AppTheme.secondaryBackgroundColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .shadow(color: AppTheme.shadowColor, radius: 4, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    Button(role: .destructive) {
                        if let index = viewModel.properties.firstIndex(where: { $0.id == property.id }) {
                            viewModel.deleteProperty(at: IndexSet(integer: index))
                        }
                    } label: {
                        Label("general_delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    // MARK: - UI Components
    
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
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    PropertiesListView()
}
