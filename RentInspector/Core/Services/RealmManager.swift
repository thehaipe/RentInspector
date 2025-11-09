//
//  RealmManager.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import Foundation
import RealmSwift
internal import Combine

class RealmManager: ObservableObject {
    static let shared = RealmManager()
    
    private var realm: Realm?
    
    @Published var records: [Record] = []
    @Published var isLoading: Bool = true  // ← Додано
    
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
                        // Міграції при оновленні схеми
                    }
                }
            )
            
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            
            print("✅ Realm initialized at: \(realm?.configuration.fileURL?.path ?? "unknown")")
        } catch {
            print("❌ Error initializing Realm: \(error.localizedDescription)")
            isLoading = false  // ← Додано
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
            records = Array(results)
            
            print("📊 Loaded \(records.count) records")
        }
    func loadRecords() {
        loadRecordsSync()
    }
    
    func updateRecord(_ record: Record, title: String? = nil, stage: RecordStage? = nil, reminderInterval: Int? = nil) {
        guard let realm = realm, let recordToUpdate = realm.object(ofType: Record.self, forPrimaryKey: record.id) else { return }
        
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
        guard let realm = realm, let recordToDelete = realm.object(ofType: Record.self, forPrimaryKey: record.id) else { return }
        
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
        guard let realm = realm, let recordToUpdate = realm.object(ofType: Record.self, forPrimaryKey: record.id) else { return }
        
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
        guard let realm = realm, let roomToUpdate = realm.object(ofType: Room.self, forPrimaryKey: room.id) else { return }
        
        do {
            try realm.write {
                if let customName = customName {
                    roomToUpdate.customName = customName
                }
                if let comment = comment {
                    roomToUpdate.comment = comment
                }
            }
            loadRecords()
            print("✅ Room updated")
        } catch {
            print("❌ Error updating room: \(error.localizedDescription)")
        }
    }
    
    func addPhotoToRoom(_ room: Room, photoData: Data) {
        guard let realm = realm, let roomToUpdate = realm.object(ofType: Room.self, forPrimaryKey: room.id) else { return }
        
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
        guard let realm = realm, let roomToUpdate = realm.object(ofType: Room.self, forPrimaryKey: room.id) else { return }
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
        guard let realm = realm,
              let recordToUpdate = realm.object(ofType: Record.self, forPrimaryKey: record.id),
              let roomToDelete = realm.object(ofType: Room.self, forPrimaryKey: room.id) else { return }
        
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
            try realm.write {
                realm.deleteAll()
            }
            loadRecordsSync()
            print("✅ All data cleared")
        } catch {
            print("❌ Error clearing data: \(error.localizedDescription)")
        }
    }
}

