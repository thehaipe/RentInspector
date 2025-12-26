internal import SwiftUI
internal import Combine
import RealmSwift

@MainActor
class PropertyViewModel: ObservableObject {
    
    @Published var properties: [Property] = []
    
    // UI State: Пошук та Фільтрація
    @Published var searchText: String = "" {
        didSet { checkSearchResults() }
    }
    @Published var isSearching: Bool = false
    @Published var selectedDateFilter: RecordsViewModel.DateFilter = .all
    @Published var sortOrder: RecordsViewModel.SortOrder = .descending 
    
    // UI State: Модальні вікна та Тости
    @Published var showAddPropertySheet: Bool = false
    @Published var showErrorToast: Bool = false
    @Published var errorMessage: String = ""
    
    // Поля для створення
    @Published var newPropertyName: String = ""
    @Published var newPropertyAddress: String = ""
    
    private var realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        realmManager.loadProperties()
    }
    
    private func setupBindings() {
            realmManager.$properties
                .receive(on: DispatchQueue.main)
                .sink { [weak self] props in
                    self?.properties = props
                }
                .store(in: &cancellables)
            realmManager.$records
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.realmManager.loadProperties()
                }
                .store(in: &cancellables)
        }
    
    // MARK: - Computed Properties
    
    var filteredProperties: [Property] {
        var result = properties
        
        // 1. Фільтр за датою
        result = filterByDate(result)
        
        // 2. Пошук за текстом
        if !searchText.isEmpty {
            result = result.filter { property in
                property.name.localizedCaseInsensitiveContains(searchText) ||
                property.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 3. Сортування
        result = sortProperties(result, ascending: sortOrder == .ascending)
        
        return result
    }
    
    // MARK: - Helpers
    
    // Сортування
    private func sortProperties(_ array: [Property], ascending: Bool) -> [Property] {
        return array.sorted { p1, p2 in
            ascending ? p1.createdAt < p2.createdAt : p1.createdAt > p2.createdAt
        }
    }
    
    // Фільтрація дати
    private func filterByDate(_ props: [Property]) -> [Property] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedDateFilter {
        case .all: return props
        case .today: return props.filter { calendar.isDateInToday($0.createdAt) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return props.filter { $0.createdAt >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return props.filter { $0.createdAt >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return props.filter { $0.createdAt >= yearAgo }
        }
    }
    
    // Валідація пошуку
    private func checkSearchResults() {
        showErrorToast = false
        guard !searchText.isEmpty else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            if !self.searchText.isEmpty && !self.properties.isEmpty && self.filteredProperties.isEmpty {
                self.showError("property_search_not_found".localized(self.searchText))
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        withAnimation { showErrorToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            withAnimation { self?.showErrorToast = false }
        }
    }
    
    // MARK: - Actions
    
    func toggleSearch() {
        isSearching.toggle()
        if !isSearching {
            searchText = ""
            showErrorToast = false
        }
    }
    
    func setSortOrder(_ order: RecordsViewModel.SortOrder) {
        sortOrder = order
    }
    
    func createProperty() {
        guard !newPropertyName.isEmpty || !newPropertyAddress.isEmpty else { return }
        let newProperty = Property(name: newPropertyName, address: newPropertyAddress)
        realmManager.createProperty(newProperty)
        newPropertyName = ""
        newPropertyAddress = ""
        showAddPropertySheet = false
    }
    
    func deleteProperty(at offsets: IndexSet) {
        // Важливо видаляти з основного масиву (properties), а не filtered
        // Тому треба знайти правильний індекс
        offsets.forEach { index in
            // Краще видаляти по ID обʼєкьа, а не по індексу у filtered масиві, але для простоти поки лишу так.
            if index < filteredProperties.count {
                let property = filteredProperties[index]
                realmManager.deleteProperty(property)
            }
        }
    }
}
