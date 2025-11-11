/*
 Клас для роботи з локальною базою данних Realm. Всі критичні моменти проходять через транзакцію realm.wrire, яка валить додаток при невдачі.
 На майбутнє: Написати міграцію. Видалити поле "updatedAt", додати квадратуру квартири. 
 */
import Foundation
import RealmSwift
internal import Combine

class RealmManager: ObservableObject {
    static let shared = RealmManager()
    
    private var realm: Realm?
    
    @Published var records: [Record] = []
    
    private init() {
        setupRealm()
        loadRecordsSync()
    }
    
    // MARK: - Setup
    
    private func setupRealm() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 1 {
                        // Міграції при оновленні схеми, додати поле "squreMeters", видалити поле "updatedAt"
                    }
                }
            )
            
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            
            print("✅ Realm initialized at: \(realm?.configuration.fileURL?.path ?? "unknown")")
        } catch {
            print("❌ Error initializing Realm: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CRUD Operations for Record
    
    func createRecord(_ record: Record) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.add(record)
            }
            loadRecordsSync()
            print("✅ Record created: \(record.displayTitle)")
        } catch {
            print("❌ Error creating record: \(error.localizedDescription)")
        }
    }
    
    private func loadRecordsSync() {
        guard let realm = realm else { return }
        
        let results = realm.objects(Record.self).sorted(byKeyPath: "createdAt", ascending: false)
        
        // Конвертуємо Results<Record> в [Record], потім в detached. Deatached потрібен, бо при видаленні обʼекту з Realm, View все одно тримає звʼязки на нього, і якщо не зробити "легку" копію, впаде додаток. Перевірено. Тричі.
        let managedRecords = Array(results)
        self.records = managedRecords.map { $0.detached() }
        
        print("📊 Loaded \(records.count) records")
    }
    
    func loadRecords() {
        loadRecordsSync()
    }
    
    func updateRecord(_ record: Record, title: String? = nil, stage: RecordStage? = nil, reminderInterval: Int? = nil) {
        guard let realm = realm else { return }
        
        // Знаходимо об'єкт заново через primary key
        guard let recordToUpdate = realm.object(ofType: Record.self, forPrimaryKey: record.id) else {
            print("⚠️ Record not found")
            return
        }
        
        do {
            try realm.write {
                if let title = title {
                    recordToUpdate.title = title
                }
                if let stage = stage {
                    recordToUpdate.stage = stage.rawValue
                }
                if let reminderInterval = reminderInterval {
                    recordToUpdate.reminderInterval = reminderInterval
                    if reminderInterval > 0 {
                        recordToUpdate.nextReminderDate = Calendar.current.date(byAdding: .day, value: reminderInterval, to: Date())
                    } else {
                        recordToUpdate.nextReminderDate = nil
                    }
                }
                recordToUpdate.updatedAt = Date()
            }
            loadRecordsSync()
            print("✅ Record updated: \(recordToUpdate.displayTitle)")
        } catch {
            print("❌ Error updating record: \(error.localizedDescription)")
        }
    }
    
    func deleteRecord(_ record: Record) {
        guard let realm = realm else { return }
        
        // Пошук об'єкт заново
        guard let recordToDelete = realm.object(ofType: Record.self, forPrimaryKey: record.id) else {
            print("⚠️ Record not found or already deleted")
            loadRecordsSync() // Оновлюємо список
            return
        }
        
        do {
            try realm.write {
                // Видаляємо всі кімнати разом із записом
                realm.delete(recordToDelete.rooms)
                realm.delete(recordToDelete)
            }
            loadRecordsSync()
            print("✅ Record deleted")
        } catch {
            print("❌ Error deleting record: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Operations for Room
    
    func addRoom(to record: Record, room: Room) {
        guard let realm = realm else { return }
        
        guard let recordToUpdate = realm.object(ofType: Record.self, forPrimaryKey: record.id) else {
            print("⚠️ Record not found")
            return
        }
        
        do {
            try realm.write {
                recordToUpdate.rooms.append(room)
                recordToUpdate.updatedAt = Date()
            }
            loadRecordsSync()
            print("✅ Room added to record")
        } catch {
            print("❌ Error adding room: \(error.localizedDescription)")
        }
    }
    
    func updateRoom(_ room: Room, customName: String? = nil, comment: String? = nil) {
        guard let realm = realm else { return }
        
        guard let roomToUpdate = realm.object(ofType: Room.self, forPrimaryKey: room.id) else {
            print("⚠️ Room not found")
            return
        }
        
        do {
            try realm.write {
                if let customName = customName {
                    roomToUpdate.customName = customName
                }
                if let comment = comment {
                    roomToUpdate.comment = comment
                }
            }
            loadRecordsSync()
            print("✅ Room updated")
        } catch {
            print("❌ Error updating room: \(error.localizedDescription)")
        }
    }
    
    func addPhotoToRoom(_ room: Room, photoData: Data) {
        guard let realm = realm else { return }
        
        guard let roomToUpdate = realm.object(ofType: Room.self, forPrimaryKey: room.id) else {
            print("⚠️ Room not found")
            return
        }
        
        do {
            try realm.write {
                roomToUpdate.photoData.append(photoData)
            }
            loadRecordsSync()
            print("✅ Photo added to room")
        } catch {
            print("❌ Error adding photo: \(error.localizedDescription)")
        }
    }
    
    func removePhotoFromRoom(_ room: Room, at index: Int) {
        guard let realm = realm else { return }
        
        guard let roomToUpdate = realm.object(ofType: Room.self, forPrimaryKey: room.id) else {
            print("⚠️ Room not found")
            return
        }
        
        guard index >= 0 && index < roomToUpdate.photoData.count else { return }
        
        do {
            try realm.write {
                roomToUpdate.photoData.remove(at: index)
            }
            loadRecordsSync()
            print("✅ Photo removed from room")
        } catch {
            print("❌ Error removing photo: \(error.localizedDescription)")
        }
    }
    
    func deleteRoom(_ room: Room, from record: Record) {
        guard let realm = realm else { return }
        
        guard let recordToUpdate = realm.object(ofType: Record.self, forPrimaryKey: record.id),
              let roomToDelete = realm.object(ofType: Room.self, forPrimaryKey: room.id) else {
            print("⚠️ Record or Room not found")
            return
        }
        
        do {
            try realm.write {
                if let index = recordToUpdate.rooms.firstIndex(of: roomToDelete) {
                    recordToUpdate.rooms.remove(at: index)
                }
                realm.delete(roomToDelete)
                recordToUpdate.updatedAt = Date()
            }
            loadRecordsSync()
            print("✅ Room deleted")
        } catch {
            print("❌ Error deleting room: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Search & Filter
    
    func searchRecords(query: String) -> [Record] {
        guard !query.isEmpty else { return records }
        
        return records.filter { record in
            record.displayTitle.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterRecordsByDate(from startDate: Date, to endDate: Date) -> [Record] {
        return records.filter { record in
            record.createdAt >= startDate && record.createdAt <= endDate
        }
    }
    
    // MARK: - Utility
    
    func getRecordCount() -> Int {
        return records.count
    }
    
    func clearAllData() {
        guard let realm = realm else { return }
        
        do {
            // Спочатку очищуємо UI на main thread
            DispatchQueue.main.async { [weak self] in
                self?.records = []
            }
            
            // Потім видаляємо з realm
            try realm.write {
                realm.deleteAll()
            }
            
            print("✅ All data cleared")
        } catch {
            print("❌ Error clearing data: \(error.localizedDescription)")
        }
    }
}
