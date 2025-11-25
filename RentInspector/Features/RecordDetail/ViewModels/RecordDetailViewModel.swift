/*
 Клас для роботи з уже створеним звітом. Станом на зараз, він відповідає за зміну інформації запису. (Фото, назви, етап) проте у майбутньому створений звіт буде статичним, залишиться лише можливість експортувати його.
 */
import SwiftUI
internal import Combine
import RealmSwift

class RecordDetailViewModel: ObservableObject {
    @Published var record: Record
    @Published var editedTitle: String = ""
    @Published var editedStage: RecordStage
    @Published var editedReminderInterval: Int = 0
    @Published var isEditingTitle: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var showReminderPicker: Bool = false
    @Published var selectedRoomIndex: Int? = nil
    @Published var selectedProperty: Property?
    @Published var showPropertyPicker: Bool = false
    
    @Published var showErrorToast: Bool = false
    @Published var errorMessage: String = ""
    
    private var realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(record: Record) {
        self.record = record
        self.editedTitle = record.title
        self.editedStage = record.recordStage
        self.editedReminderInterval = record.reminderInterval
        
        if let parentId = record.parentId {
            // Шукаємо об'єкт у завантаженому списку RealmManager
            self.selectedProperty = RealmManager.shared.properties.first(where: { $0.id == parentId })
        }
    }
    
    // MARK: - Update Methods
    
    func saveTitle() {
        guard !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            editedTitle = record.title
            isEditingTitle = false
            return
        }
        
        realmManager.updateRecord(record, title: editedTitle)
        isEditingTitle = false
        refreshRecord()
    }
    
    func updateStage(_ stage: RecordStage) {
        editedStage = stage
        realmManager.updateRecord(record, stage: stage)
        refreshRecord()
    }
    
    func updateReminderInterval(_ interval: Int) {
        editedReminderInterval = interval
        realmManager.updateRecord(record, reminderInterval: interval)
        refreshRecord()
    }
    
    func deleteRecord(completion: @escaping () -> Void) {
        realmManager.deleteRecord(record)
        completion()
    }
    func updateProperty(_ property: Property?) {
        if let property = property {
            let isRestrictedStage = record.recordStage == .moveIn || record.recordStage == .moveOut
            
            if isRestrictedStage && property.hasRecord(with: record.recordStage) {
                errorMessage = "У об'єкті '\(property.displayName)' вже існує звіт етапу '\(record.recordStage.displayName)'. Видаліть старий звіт або змініть етап поточного."
                showErrorToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.showErrorToast = false
                }
                return // Перериваємо операцію
            }
        }
        
        selectedProperty = property
        RealmManager.shared.updateRecordProperty(record: record, newProperty: property)
        refreshRecord() // Це не обов'язково, бо RealmManager.updateRecordProperty оновить об'єкт
    }
    
    // MARK: - Room Methods
    
    func updateRoomName(at index: Int, name: String) {
        guard index < record.rooms.count else { return }
        let room = record.rooms[index]
        realmManager.updateRoom(room, customName: name)
        refreshRecord()
    }
    
    func updateRoomComment(at index: Int, comment: String) {
        guard index < record.rooms.count else { return }
        let room = record.rooms[index]
        realmManager.updateRoom(room, comment: comment)
        refreshRecord()
    }
    
    func addPhotoToRoom(at index: Int, photoData: Data) {
        guard index < record.rooms.count else { return }
        let room = record.rooms[index]
        realmManager.addPhotoToRoom(room, photoData: photoData)
        refreshRecord()
    }
    
    func removePhotoFromRoom(roomIndex: Int, photoIndex: Int) {
        guard roomIndex < record.rooms.count else { return }
        let room = record.rooms[roomIndex]
        realmManager.removePhotoFromRoom(room, at: photoIndex)
        refreshRecord()
    }
    func canDeleteRoom(at index: Int) -> Bool {
        guard index >= 0 && index < record.rooms.count else { return false }
        
        let room = record.rooms[index]
        
        switch room.roomType {
        case .bedroom, .kitchen:
            return false
        case .bathroom:
            if let firstBathroomIndex = record.rooms.firstIndex(where: { $0.roomType == .bathroom }) {
                return index != firstBathroomIndex
            }
            return true
        default:
            return true
        }
    }
    func deleteRoom(at index: Int) {
        guard index < record.rooms.count else { return }
        let room = record.rooms[index]
        realmManager.deleteRoom(room, from: record)
        refreshRecord()
    }
    
    // MARK: - Helper Methods
    
    private func refreshRecord() {
        // Оновлюємо локальний об'єкт record
        realmManager.loadRecords()
        if let updatedRecord = realmManager.records.first(where: { $0.id == record.id }) {
            self.record = updatedRecord
        }
    }
    
    var formattedDate: String {
        record.createdAt.formatted(date: .long, time: .shortened)
    }
    
    var nextReminderText: String {
        guard let nextDate = record.nextReminderDate else {
            return "Не встановлено"
        }
        return nextDate.formatted(date: .abbreviated, time: .omitted)
    }
}

