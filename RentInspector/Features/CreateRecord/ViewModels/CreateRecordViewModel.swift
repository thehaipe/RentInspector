//
//  CreateRecordViewModel.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI
internal import Combine
import RealmSwift
@MainActor
class CreateRecordViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Onboarding Stage
    @Published var currentStep: OnboardingStep = .roomCount
    
    // Step 1: Кількість кімнат
    @Published var selectedRoomCount: Int = 1
    
    // Step 2: Балкон/Лоджа
    @Published var hasBalcony: Bool = false
    @Published var hasLoggia: Bool = false
    
    // Step 3: Додаткові кімнати
    @Published var wardrobeCount: Int = 0
    @Published var storageCount: Int = 0
    @Published var otherCount: Int = 0
    
    // Record Form
    @Published var recordTitle: String = ""
    @Published var recordStage: RecordStage = .moveIn
    @Published var reminderInterval: Int = 0
    @Published var rooms: [RoomData] = []
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var showSuccessView: Bool = false
    
    private var realmManager = RealmManager.shared
    
    enum OnboardingStep: Int, CaseIterable {
        case roomCount = 0
        case balconyLoggia = 1
        case additionalRooms = 2
        case recordForm = 3
    }
    
    struct RoomData: Identifiable {
        let id = UUID()
        var type: RoomType
        var customName: String
        var comment: String
        var photos: [Data]
        
        var displayName: String {
            return customName.isEmpty ? type.displayName : customName
        }
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        if currentStep == .additionalRooms {
            // Генеруємо кімнати перед переходом до форми
            generateRooms()
        }
        
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = nextStep
            }
        }
    }
    
    func previousStep() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = previousStep
            }
        }
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .roomCount:
            return selectedRoomCount >= 1
        case .balconyLoggia:
            return true
        case .additionalRooms:
            return true
        case .recordForm:
            return !rooms.isEmpty
        }
    }
    
    // MARK: - Room Generation
    
    private func generateRooms() {
        rooms.removeAll()
        
        // Додаємо основні кімнати
        for i in 1...selectedRoomCount {
            rooms.append(RoomData(
                type: .bedroom,
                customName: "Кімната \(i)",
                comment: "",
                photos: []
            ))
        }
        
        // Додаємо кухню
        rooms.append(RoomData(
            type: .kitchen,
            customName: "",
            comment: "",
            photos: []
        ))
        
        // Додаємо санвузол (завжди мінімум 1)
        rooms.append(RoomData(
            type: .bathroom,
            customName: "",
            comment: "",
            photos: []
        ))
        
        // Додаємо балкон
        if hasBalcony {
            rooms.append(RoomData(
                type: .balcony,
                customName: "",
                comment: "",
                photos: []
            ))
        }
        
        // Додаємо лоджію
        if hasLoggia {
            rooms.append(RoomData(
                type: .loggia,
                customName: "",
                comment: "",
                photos: []
            ))
        }
        
        // Додаємо гардероби
        if wardrobeCount > 0 {
            for i in 1...wardrobeCount {
                rooms.append(RoomData(
                    type: .wardrobe,
                    customName: wardrobeCount > 1 ? "Гардероб \(i)" : "",
                    comment: "",
                    photos: []
                ))
            }
        }
        
        
        // Додаємо кладові
        if storageCount > 0 {
            for i in 1...storageCount {
                rooms.append(RoomData(
                    type: .storage,
                    customName: storageCount > 1 ? "Кладова \(i)" : "",
                    comment: "",
                    photos: []
                ))
            }
        }
        
        
        // Додаємо інші кімнати
        if otherCount > 0 {
            for i in 1...otherCount {
                rooms.append(RoomData(
                    type: .other,
                    customName: "Інше \(i)",
                    comment: "",
                    photos: []
                ))
            }
        }
    }
    
    // MARK: - Room Management
    
    func updateRoomName(at index: Int, name: String) {
        guard index < rooms.count else { return }
        rooms[index].customName = name
    }
    
    func updateRoomComment(at index: Int, comment: String) {
        guard index < rooms.count else { return }
        rooms[index].comment = comment
    }
    
    func addPhotoToRoom(at index: Int, photoData: Data) {
        guard index < rooms.count else { return }
        rooms[index].photos.append(photoData)
    }
    
    func removePhotoFromRoom(at roomIndex: Int, photoIndex: Int) {
        guard roomIndex < rooms.count, photoIndex < rooms[roomIndex].photos.count else { return }
        rooms[roomIndex].photos.remove(at: photoIndex)
    }
    
    func addBathroom() {
        rooms.append(RoomData(
            type: .bathroom,
            customName: "Санвузол \(rooms.filter { $0.type == .bathroom }.count + 1)",
            comment: "",
            photos: []
        ))
    }
    
    // MARK: - Save Record
    
    func saveRecord(completion: @escaping (Record?) -> Void) {
        isLoading = true
        
        // Створюємо новий Record
        let newRecord = Record(
            title: recordTitle.isEmpty ? "Record \(Date().formatted(date: .abbreviated, time: .omitted))" : recordTitle,
            stage: recordStage
        )
        newRecord.reminderInterval = reminderInterval
        
        if reminderInterval > 0 {
            newRecord.nextReminderDate = Calendar.current.date(byAdding: .day, value: reminderInterval, to: Date())
        }
        
        // Створюємо Room об'єкти
        for roomData in rooms {
            let room = Room(type: roomData.type, customName: roomData.customName)
            room.comment = roomData.comment
            room.photoData.append(objectsIn: roomData.photos)
            newRecord.rooms.append(room)
        }
        
        // Зберігаємо в Realm
        realmManager.createRecord(newRecord)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            self?.showSuccessView = true
            completion(newRecord.detached())  // Повертаємо DEATACHED копію!!!!!!!!!!!!!!!!!, бо звичайна валить View
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        currentStep = .roomCount
        selectedRoomCount = 1
        hasBalcony = false
        hasLoggia = false
        wardrobeCount = 0
        storageCount = 0
        otherCount = 0
        recordTitle = ""
        recordStage = .moveIn
        reminderInterval = 0
        rooms.removeAll()
        showSuccessView = false
    }
}
