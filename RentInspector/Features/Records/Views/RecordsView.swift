/*
 Екран відображення списку всіх записів
 */
internal import SwiftUI
import RealmSwift

struct RecordsView: View {
    @StateObject private var viewModel = RecordsViewModel()
    @State private var showCreateRecord = false
    @State private var showFilterSheet = false
    
    var body: some View {
        ZStack {
            if viewModel.records.isEmpty {
                EmptyRecordsView(onCreateRecord: {
                    showCreateRecord = true
                })
            } else {
                recordsList
            }
            if viewModel.showErrorToast {
                errorToast
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Title (по центру, але зліва від кнопок)
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("records_title")
                        .font(AppTheme.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
            }
            
            // Кнопки (справа)
            ToolbarItem(placement: .topBarTrailing) {
                if !viewModel.records.isEmpty {
                    HStack(spacing: 16) {
                        // Кнопка пошуку
                        Button(action: {
                            viewModel.toggleSearch()
                            
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                        }
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
                        
                        // Кнопка фільтрації
                        Button(action: {
                            showFilterSheet = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title3)
                        }
                        
                        // Кнопка створення
                        Button(action: {
                            showCreateRecord = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCreateRecord) {
            CreateRecordCoordinator()
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
        }
    }
    
    private var recordsList: some View {
        VStack(spacing: 0) {
            // Пошукова строка
            if viewModel.isSearching {
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Список звітів
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredRecords) { record in
                        RecordCardView(record: record)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteRecord(record)
                                } label: {
                                    Label("general_delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .animation(.easeInOut, value: viewModel.isSearching)
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
}

#Preview {
    NavigationStack {
        RecordsView()
            .environmentObject(RealmManager.shared)
    }
}
