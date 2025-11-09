//
//  RecordDetailViewModel.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
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
    
    private var realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(record: Record) {
        self.record = record
        self.editedTitle = record.title
        self.editedStage = record.recordStage
        self.editedReminderInterval = record.reminderInterval
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

