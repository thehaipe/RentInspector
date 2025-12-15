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
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.records.isEmpty {
                        EmptyRecordsView(onCreateRecord: {
                            showCreateRecord = true
                        })
                        .padding(.top, 40)
                    } else {
                        recordsList
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
            .fullScreenCover(isPresented: $showCreateRecord) {
                CreateRecordCoordinator()
            }
            .sheet(isPresented: $showFilterSheet) {
                filterSheet
            }
        }
        
        // MARK: - Header
        
        private var customHeader: some View {
            CustomTopBar(title: "records_title") {
                if !viewModel.records.isEmpty {
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
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(AppTheme.primaryColor, lineWidth: 2.2)
                            )
                    }
                    
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(AppTheme.primaryColor, lineWidth: 2.2)
                            )
                    }
                    TopBarPrimaryButton {
                        showCreateRecord = true
                    }
                }
            }
        }
    
    // MARK: - List Content
    
    private var recordsList: some View {
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
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    // MARK: - UI Components
    
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
                                Text(filter.displayName)
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
                    Button("general_done") { showFilterSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
