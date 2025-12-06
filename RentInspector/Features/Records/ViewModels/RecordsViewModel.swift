/*
 Клас для роботи з готовими записами. Фільтація, завантаження з БД, видалення.
 */
internal import SwiftUI
internal import Combine

@MainActor
class RecordsViewModel: ObservableObject {
    @Published var records: [Record] = []
    @Published var searchText: String = "" {
        didSet {
            // Викликаємо перевірку при зміні тексту пошуку
            checkSearchResults()
        }
    }
    @Published var isSearching: Bool = false
    @Published var selectedDateFilter: DateFilter = .all
    @Published var sortOrder: SortOrder = .descending
    @Published var showErrorToast: Bool = false
    @Published var errorMessage: String = ""
    
    private var realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum DateFilter: String, CaseIterable {
            case all = "all"
            case today = "today"
            case week = "week"
            case month = "month"
            case year = "year"
        }
    
    enum SortOrder: String, CaseIterable {
            case ascending = "ascending"
            case descending = "descending"
            
            var icon: String {
                switch self {
                case .ascending: return "arrow.up.circle"
                case .descending: return "arrow.down.circle"
                }
            }
        }
    
    init() {
        self.records = realmManager.records
        setupBindings()
    }
    
    private func setupBindings() {
        realmManager.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                self?.records = records
            }
            .store(in: &cancellables)
    }
    
    func loadRecords() {
        realmManager.loadRecords()
    }
    
    var filteredRecords: [Record] {
        var result = records
        
        // Фільтр за датою
        result = filterByDate(result)
        
        // Пошук за текстом
        if !searchText.isEmpty {
            result = result.filter { record in
                record.titleString.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        result = shellSortByDate(result, ascending: sortOrder == .ascending)
        
        return result
    }
    
    private func checkSearchResults() {
        // Ховаємо попередній toast
        showErrorToast = false
        
        // Якщо пошук порожній, виходимо
        guard !searchText.isEmpty else { return }
        
        // Чекаємо трошки щоб користувач закінчив вводити (debounce)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            // Перевіряємо чи текст пошуку не змінився за цей час
            let currentSearchText = self.searchText
            
            // Якщо є текст пошуку, є записи в БД, але немає результатів
            if !currentSearchText.isEmpty
                && !self.records.isEmpty
                && self.filteredRecords.isEmpty {
                self.showError("search_result_not_found".localized(currentSearchText))
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        
        withAnimation {
            showErrorToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            withAnimation {
                self?.showErrorToast = false
            }
        }
    }
    
    private func shellSortByDate(_ array: [Record], ascending: Bool) -> [Record] {
        guard array.count > 1 else { return array }
        
        var arr = array
        var gap = arr.count / 2
        
        while gap > 0 {
            for i in gap..<arr.count {
                let temp = arr[i]
                var j = i
                
                while j >= gap && arr[j - gap].createdAt > temp.createdAt {
                    arr[j] = arr[j - gap]
                    j -= gap
                }
                
                arr[j] = temp
            }
            
            gap /= 2
        }
        
        return ascending ? arr : arr.reversed()
    }
    
    func setSortOrder(_ order: SortOrder) {
        sortOrder = order
    }
    
    private func filterByDate(_ records: [Record]) -> [Record] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedDateFilter {
        case .all:
            return records
        case .today:
            return records.filter { calendar.isDateInToday($0.createdAt) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return records.filter { $0.createdAt >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return records.filter { $0.createdAt >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return records.filter { $0.createdAt >= yearAgo }
        }
    }
    
    func deleteRecord(_ record: Record) {
        realmManager.deleteRecord(record)
    }
    
    func toggleSearch() {
        isSearching.toggle()
        if !isSearching {
            searchText = ""
            showErrorToast = false
        }
    }
}

