import Foundation
import RealmSwift

class Property: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""       // Назва (напр. "Студія на Подолі")
    @Persisted var address: String = ""    // Адреса (напр. "вул. Сагайдачного 10, кв 5")
    @Persisted var createdAt: Date = Date()
    
    @Persisted var records: List<Record>
    
    // Computed property для відображення в UI
    var displayName: String {
        if !name.isEmpty {
            return name
        }
        return address.isEmpty ? "New Property" : address
    }
    func detached() -> Property {
            let detached = Property()
            detached.id = self.id
            detached.name = self.name
            detached.address = self.address
            detached.createdAt = self.createdAt
            for record in self.records {
                detached.records.append(record.detached())
            }
            
            return detached
        }
    
    convenience init(name: String, address: String) {
        self.init()
        self.name = name
        self.address = address
    }
}
