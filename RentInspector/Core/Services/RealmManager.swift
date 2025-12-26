/*
 Клас для роботи з локальною базою данних Realm.
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
        loadProperties()
    }
    
    // MARK: - Setup
    
    private func setupRealm() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 5,
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
                    
                    // Міграція 2 -> 3 (Властивості)
                    if oldSchemaVersion < 3 {
                        // Видалено: Створення дефолтного об'єкту
                    }
                    
                    // Міграція 3 -> 4 (ParentId)
                    if oldSchemaVersion < 4 {
                        migration.enumerateObjects(ofType: Record.className()) { oldObj, newObj in
                            newObj?["parentId"] = nil
                        }
                    }
                    
                    // Міграція 4 -> 5
                    if oldSchemaVersion < 5 {
                        // Realm автоматично видалить колонку updatedAt
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
    
    // MARK: - Property Management
    func loadProperties() {
            guard let realm = realm else { return }
            let results = realm.objects(Property.self).sorted(byKeyPath: "createdAt", ascending: false)
            let detachedProperties = Array(results).map { $0.detached() }
            
            DispatchQueue.main.async {
                self.properties = detachedProperties
            }
        }
    
    func createProperty(_ property: Property) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(property)
            }
            loadProperties()
            print("✅ Property created: \(property.displayName)")
        } catch {
            print("❌ Error creating property: \(error.localizedDescription)")
        }
    }
    
    func deleteProperty(_ property: Property) {
        guard let realm = realm else { return }
        guard let propToDelete = realm.object(ofType: Property.self, forPrimaryKey: property.id) else { return }
        
        do {
            try realm.write {
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
        let managedRecords = Array(results)
        self.records = managedRecords.map { $0.detached() }
        
        print("📊 Loaded \(records.count) records")
    }
    
    func loadRecords() {
        loadRecordsSync()
    }
    
    func updateRecord(_ record: Record, title: String? = nil, stage: RecordStage? = nil, reminderInterval: Int? = nil) {
        guard let realm = realm else { return }
        
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
        
        guard let fileName = ImageManager.shared.saveImage(photoData) else {
            print("❌ Failed to save image to disk")
            return
        }
        
        do {
            try realm.write {
                roomToUpdate.photoPaths.append(fileName)
            }
            loadRecordsSync()
            print("✅ Photo added to room: \(fileName)")
        } catch {
            print("❌ Error adding photo to DB: \(error.localizedDescription)")
            ImageManager.shared.deleteImage(named: fileName)
        }
    }
    
    func addRecordToProperty(record: Record, property: Property) {
        guard let realm = realm else { return }
        
        guard let liveProperty = realm.object(ofType: Property.self, forPrimaryKey: property.id),
              let liveRecord = realm.object(ofType: Record.self, forPrimaryKey: record.id) else {
            return
        }
        
        do {
            try realm.write {
                liveProperty.records.append(liveRecord)
                liveRecord.parentId = liveProperty.id
            }
            loadProperties()
            loadRecordsSync()
            print("✅ Record linked to property")
        } catch {
            print("❌ Error linking record: \(error.localizedDescription)")
        }
    }
    
    func getPropertyName(for id: ObjectId?) -> String? {
        guard let id = id else { return nil }
        return properties.first(where: { $0.id == id })?.displayName
    }
    
    func updateRecordProperty(record: Record, newProperty: Property?) {
        guard let realm = realm else { return }
        guard let liveRecord = realm.object(ofType: Record.self, forPrimaryKey: record.id) else { return }
        
        do {
            try realm.write {
                if let oldProperty = liveRecord.assignee.first {
                    if let index = oldProperty.records.firstIndex(of: liveRecord) {
                        oldProperty.records.remove(at: index)
                    }
                }
                
                if let newProperty = newProperty,
                   let liveNewProperty = realm.object(ofType: Property.self, forPrimaryKey: newProperty.id) {
                    if !liveNewProperty.records.contains(liveRecord) {
                        liveNewProperty.records.append(liveRecord)
                    }
                    liveRecord.parentId = liveNewProperty.id
                } else {
                    liveRecord.parentId = nil
                }
            }
            loadRecordsSync()
            loadProperties()
            print("✅ Record property updated")
        } catch {
            print("❌ Error updating record property: \(error.localizedDescription)")
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
            }
            
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
            record.titleString.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterRecordsByDate(from startDate: Date, to endDate: Date) -> [Record] {
        return records.filter { record in
            record.createdAt >= startDate && record.createdAt <= endDate
        }
    }
    
    func getRecordCount() -> Int {
        return records.count
    }
    
    func clearAllData() throws {
        guard !records.isEmpty || !properties.isEmpty else {
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
            try realm.write {
                realm.deleteAll()
            }
            
            //Оновлення Published властивості вручну для миттєвої реакції UI
            DispatchQueue.main.async {
                self.records = []
                self.properties = []
            }
            
            // Видаляємо файли у фоні
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
