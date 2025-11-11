/*
 Клас для роботи з готовими записами. Фільтація, завантаження з БД, видалення. 
 */
import SwiftUI
internal import Combine

@MainActor
class RecordsViewModel: ObservableObject {
    @Published var records: [Record] = []
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var selectedDateFilter: DateFilter = .all
    
    private var realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum DateFilter: String, CaseIterable {
        case all = "Всі"
        case today = "Сьогодні"
        case week = "Тиждень"
        case month = "Місяць"
        case year = "Рік"
    }
    
    init() {
        self.records = realmManager.records
        
        // Потім підписуємось на зміни
        setupBindings()
    }
    
    private func setupBindings() {
        // Підписка на зміни в RealmManager
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
                record.displayTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
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
        }
    }
}
