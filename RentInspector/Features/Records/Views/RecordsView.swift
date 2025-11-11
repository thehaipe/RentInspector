/*
 Екран відображення списку всіх записів
 */
import SwiftUI
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Records")
                        .font(AppTheme.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
            }
            
            // Кнопки 
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
                        if !record.isInvalidated { 
                            RecordCardView(record: record)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteRecord(record)
                                    } label: {
                                        Label("Видалити", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding()
            }
        }
        .animation(.easeInOut, value: viewModel.isSearching)
    }
    
    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("Фільтр за датою") {
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
            .navigationTitle("Фільтрація")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
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
