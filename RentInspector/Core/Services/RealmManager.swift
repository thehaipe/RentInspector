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
    @Published var properties: [Property] = []
    
    private init() {
        setupRealm()
        loadRecordsSync()
    }
    
    // MARK: - Setup
    
    // RentInspector/Core/Services/RealmManager.swift
    
    private func setupRealm() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 3,
                migrationBlock: { migration, oldSchemaVersion in
                    
                    // Міграція 1 -> 2 (Фото)
                    if oldSchemaVersion < 2 {
                        migration.enumerateObjects(ofType: Room.className()) { oldObject, newObject in
                            guard let oldObject = oldObject, let newObject = newObject else { return }
                            if let oldPhotoDataList = oldObject["photoData"] as? List<Data> {
                                let newPhotoPathsList = List<String>()
                                for data in oldPhotoDataList {
                                    if let fileName = ImageManager.shared.saveImage(data) {
                                        newPhotoPathsList.append(fileName)
                                    }
                                }
                                newObject["photoPaths"] = newPhotoPathsList
                            }
                        }
                    }
                    
                    if oldSchemaVersion < 3 {
                        // 1. Створюємо дефолтний об'єкт нерухомості
                        let defaultProperty = migration.create(Property.className(), value: [
                            "id": ObjectId.generate(),
                            "name": "Мій об'єкт (Default)",
                            "address": "Створено автоматично",
                            "createdAt": Date()
                        ])
                        
                        // 2. Отримуємо доступ до списку 'records' нового об'єкту
                        // У міграції списки потрібно кастити до List<MigrationObject>
                        if let recordsList = defaultProperty["records"] as? List<MigrationObject> {
                            
                            // 3. Проходимось по всіх існуючих звітах (Record)
                            migration.enumerateObjects(ofType: Record.className()) { _, newRecord in
                                // newRecord - це об'єкт звіту в новій схемі
                                if let newRecord = newRecord {
                                    // Додаємо існуючий звіт до списку записів дефолтного об'єкту
                                    recordsList.append(newRecord)
                                }
                            }
                        }
                    }
                }
            )
            
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            // ...
        } catch {
            print("❌ Error initializing Realm: \(error.localizedDescription)")
        }
    }
    // MARK: - Property managment
    func loadProperties() {
        guard let realm = realm else { return }
        // Завантажуємо та сортуємо за датою створення
        let results = realm.objects(Property.self).sorted(byKeyPath: "createdAt", ascending: false)
        self.properties = Array(results).map { $0.detached() } // Використовуємо detached для UI списків
    }
    func createProperty(_ property: Property) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(property)
            }
            loadProperties() // Оновлюємо список
            print("✅ Property created: \(property.displayName)")
        } catch {
            print("❌ Error creating property: \(error.localizedDescription)")
        }
    }
    func deleteProperty(_ property: Property) {
        guard let realm = realm else { return }
        
        // Знаходимо живий об'єкт
        guard let propToDelete = realm.object(ofType: Property.self, forPrimaryKey: property.id) else { return }
        
        do {
            try realm.write {
                // ВАЖЛИВО: Тут треба вирішити, що робити зі звітами.
                // Поки що видаляємо папку, а звіти стають "сиротами" (без папки), але не зникають.
                // Якщо треба видаляти і звіти - треба пройтись по propToDelete.records і видалити їх.
                realm.delete(propToDelete)
            }
            loadProperties()
            print("✅ Property deleted")
        } catch {
            print("❌ Error deleting property: \(error.localizedDescription)")
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
        guard let recordToDelete = realm.object(ofType: Record.self, forPrimaryKey: record.id) else {
            print("⚠️ Record not found or already deleted")
            loadRecordsSync()
            return
        }
        
        var photosToDelete: [String] = []
        photosToDelete = recordToDelete.rooms.flatMap { Array($0.photoPaths) }
        
        do {
            try realm.write {
                realm.delete(recordToDelete.rooms)
                realm.delete(recordToDelete)
            }
            //Видалення у фоні, щоб не блокувати UI
            DispatchQueue.global(qos: .background).async {
                for path in photosToDelete {
                    ImageManager.shared.deleteImage(named: path)
                }
                print("🗑️ Deleted \(photosToDelete.count) orphan photos from disk")
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
    func addRecordToProperty(record: Record, property: Property) {
        guard let realm = realm else { return }
        
        // Знаходимо "живі" об'єкти в базі за їх ID
        guard let liveProperty = realm.object(ofType: Property.self, forPrimaryKey: property.id),
              let liveRecord = realm.object(ofType: Record.self, forPrimaryKey: record.id) else {
            print("⚠️ Property or Record not found in Realm for linking")
            return
        }
        
        do {
            try realm.write {
                liveProperty.records.append(liveRecord)
            }
            loadProperties() // Оновлюємо UI списків
            print("✅ Record linked to property: \(liveProperty.displayName)")
        } catch {
            print("❌ Error linking record: \(error.localizedDescription)")
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
            print("Record or Room not found")
            return
        }
        let photosToDelete = Array(roomToDelete.photoPaths)
        
        do {
            try realm.write {
                if let index = recordToUpdate.rooms.firstIndex(of: roomToDelete) {
                    recordToUpdate.rooms.remove(at: index)
                }
                realm.delete(roomToDelete)
                recordToUpdate.updatedAt = Date()
            }
            
            // Видаляємо файли у фоновому режимі
            DispatchQueue.global(qos: .background).async {
                for path in photosToDelete {
                    ImageManager.shared.deleteImage(named: path)
                }
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
        guard !records.isEmpty else {
            throw RealmError.noRecordsToDelete
        }
        
        guard let realm = realm else {
            throw RealmError.operationFailed("Realm не ініціалізований")
        }
        
        let allRecords = realm.objects(Record.self)
        var allPhotosToDelete: [String] = []
        
        for record in allRecords {
            for room in record.rooms {
                allPhotosToDelete.append(contentsOf: room.photoPaths)
            }
        }
        
        do {
            records.removeAll()
            
            try realm.write {
                realm.deleteAll()
            }
            
            //Видаляємо всі файли з диску.
            DispatchQueue.global(qos: .background).async {
                for path in allPhotosToDelete {
                    ImageManager.shared.deleteImage(named: path)
                }
                print("Wiped \(allPhotosToDelete.count) photos from disk")
            }
            
            print("All data cleared")
        } catch {
            throw RealmError.operationFailed(error.localizedDescription)
        }
    }
}
