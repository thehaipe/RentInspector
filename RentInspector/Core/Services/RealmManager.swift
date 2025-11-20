/*
 Клас для роботи з локальною базою данних Realm. Всі критичні моменти проходять через транзакцію realm.wrire, яка валить додаток при невдачі.
 На майбутнє: Написати міграцію. Видалити поле "updatedAt", додати квадратуру квартири. 
 */
import Foundation
import RealmSwift
internal import Combine
internal import Realm

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
                schemaVersion: 2, // ПІДНІМАЄМО ВЕРСІЮ!
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 2 {
                        // Проходимося по всіх кімнатах
                        migration.enumerateObjects(ofType: Room.className()) { oldObject, newObject in
                            guard let oldObject = oldObject, let newObject = newObject else { return }
                            
                            // Отримуємо старий список даних фото (якщо він був)
                            if let oldPhotoDataList = oldObject["photoData"] as? List<Data> {
                                let newPhotoPathsList = List<String>()
                                
                                // Зберігаємо кожне фото на диск і записуємо шлях
                                for data in oldPhotoDataList {
                                    if let fileName = ImageManager.shared.saveImage(data) {
                                        newPhotoPathsList.append(fileName)
                                    }
                                }
                                
                                // Присвоюємо новий список новій властивості
                                newObject["photoPaths"] = newPhotoPathsList
                            }
                        }
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
            
            //Спочатку зберігаємо фото на диск і отримуємо ім'я файлу
            guard let fileName = ImageManager.shared.saveImage(photoData) else {
                print("❌ Failed to save image to disk")
                return
            }
            
            do {
                try realm.write {
                    //Тепер додаємо в базу лише ім'я файлу
                    roomToUpdate.photoPaths.append(fileName)
                }
                loadRecordsSync()
                print("✅ Photo added to room: \(fileName)")
            } catch {
                print("❌ Error adding photo to DB: \(error.localizedDescription)")
                
                //Якщо запис в БД не вдався, видалити файл, щоб не займати місце
                ImageManager.shared.deleteImage(named: fileName)
            }
        }
    
    func removePhotoFromRoom(_ room: Room, at index: Int) {
        guard let realm = realm else { return }
        
        guard let roomToUpdate = realm.object(ofType: Room.self, forPrimaryKey: room.id) else {
            print("⚠️ Room not found")
            return
        }
        
        guard index >= 0 && index < roomToUpdate.photoPaths.count else { return }
        
        do {
            try realm.write {
                roomToUpdate.photoPaths.remove(at: index)
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
    
    func clearAllData() throws {
        // Перевірка чи є що видаляти
        guard !records.isEmpty else {
            throw RealmError.noRecordsToDelete
        }
        
        guard let realm = realm else {
            throw RealmError.operationFailed("Realm не ініціалізований")
        }
        
        do {
            // Спочатку очищуємо UI
            records.removeAll()
            
            // Потім видаляємо з realm
            try realm.write {
                realm.deleteAll()
            }
            
            print("✅ All data cleared")
        } catch {
            throw RealmError.operationFailed(error.localizedDescription)
        }
    }
}
