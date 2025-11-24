import SwiftUI
internal import Combine
import RealmSwift

@MainActor
class PropertyViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var showAddPropertySheet: Bool = false
    
    // Поля для створення нового об'єкту
    @Published var newPropertyName: String = ""
    @Published var newPropertyAddress: String = ""
    
    private var realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        realmManager.loadProperties()
    }
    
    private func setupBindings() {
        // Підписуємось на оновлення в базі
        realmManager.$properties
            .receive(on: DispatchQueue.main)
            .sink { [weak self] props in
                self?.properties = props
            }
            .store(in: &cancellables)
    }
    
    func createProperty() {
        // Проста валідація
        guard !newPropertyName.isEmpty || !newPropertyAddress.isEmpty else { return }
        
        let newProperty = Property(name: newPropertyName, address: newPropertyAddress)
        realmManager.createProperty(newProperty)
        
        // Скидаємо поля і закриваємо шторку
        newPropertyName = ""
        newPropertyAddress = ""
        showAddPropertySheet = false
    }
    
    func deleteProperty(at offsets: IndexSet) {
        offsets.forEach { index in
            let property = properties[index]
            realmManager.deleteProperty(property)
        }
    }
}
