/*
 Клас для створення звіту за шаблоном (кількість кімнат, наявність балкону чи лоджі, гардеробу, кладової або іншої кімнати). Тільки цей клас обслуговує створення звіту.
 */
internal import SwiftUI
internal import Combine
import RealmSwift
internal import Realm

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
    @Published var showStageConflictToast: Bool = false
    // Додатково, додати до обʼєкту
    @Published var selectedProperty: Property? {
        didSet {
            autoSelectValidStage()
        }
    }
    
    private func autoSelectValidStage() {
        // Якщо об'єкт не вибрано, нічого не робимо
        guard let property = selectedProperty else { return }
        
        // Перевіряємо, чи поточний обраний етап є забороненим
        if disabledStages.contains(recordStage) {
            // Логіка пріоритетів:
            // 1. Якщо Заселення зайняте -> пропонуємо Проживання (найчастіший кейс)
            // 2. Якщо Виселення зайняте (а ми були на ньому) -> пропонуємо Проживання
            // 3. Якщо і Заселення і Виселення зайняті -> лишається тільки Проживання
            recordStage = .living
            showStageConflictToast = true
        }
    }
    
    private var realmManager = RealmManager.shared
    
    init(preselectedProperty: Property? = nil) {
        self.selectedProperty = preselectedProperty
        autoSelectValidStage()
    }
    
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
        
        var displayName: LocalizedStringKey {
            if customName.isEmpty {
                return type.displayName
            } else {
                return LocalizedStringKey(customName)
            }
        }
    }
    
    var disabledStages: [RecordStage] {
        guard let property = selectedProperty else { return [] }
        var disabled: [RecordStage] = []
        
        // Якщо вже є Заселення - блокуємо
        if property.hasRecord(with: .moveIn) {
            disabled.append(.moveIn)
        }
        // Якщо вже є Виселення - блокуємо
        if property.hasRecord(with: .moveOut) {
            disabled.append(.moveOut)
        }
        
        return disabled
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
                customName: "default_room_bedroom".localized(i),
                comment: "",
                photos: []
            ))
        }
        
        // Додаємо кухню
        rooms.append(RoomData(
            type: .kitchen,
            // Кухня зазвичай одна, тому використовуємо ключ без %d (якщо він так прописаний)
            // Або .localized(1), якщо ключ "Kitchen %d"
            customName: "room_type_Kitchen".localized,
            comment: "",
            photos: []
        ))
        
        // Додаємо санвузол (завжди мінімум 1)
        rooms.append(RoomData(
            type: .bathroom,
            // Виправлено: додав (1), бо ключ "default_room_bathroom" містить %d
            customName: "default_room_bathroom".localized(1),
            comment: "",
            photos: []
        ))
        
        // Додаємо балкон
        if hasBalcony {
            rooms.append(RoomData(
                type: .balcony,
                customName: "default_room_balcony".localized(1),
                comment: "",
                photos: []
            ))
        }
        
        // Додаємо лоджію
        if hasLoggia {
            rooms.append(RoomData(
                type: .loggia,
                customName: "default_room_loggia".localized(1),
                comment: "",
                photos: []
            ))
        }
        
        // Додаємо гардероби
        if wardrobeCount > 0 {
            for i in 1...wardrobeCount {
                rooms.append(RoomData(
                    type: .wardrobe,
                    customName: "default_room_wardrobe".localized(i),
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
                    customName: "default_room_storage".localized(i),
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
                    customName: "default_room_other".localized(i),
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
        // Виправлено: Тепер назва "Санвузол N" локалізована
        let nextNumber = rooms.filter { $0.type == .bathroom }.count + 1
        rooms.append(RoomData(
            type: .bathroom,
            customName: "default_room_bathroom".localized(nextNumber),
            comment: "",
            photos: []
        ))
    }
    
    func canDeleteRoom(at index: Int) -> Bool {
        guard index < rooms.count else { return false }
        let room = rooms[index]
        
        switch room.type {
        case .bedroom, .kitchen:
            return false
        case .bathroom:
            let firstBathroomIndex = rooms.firstIndex(where: { $0.type == .bathroom })
            return index != firstBathroomIndex
        default:
            return true
        }
    }
    
    func deleteRoom(at index: Int) {
        guard index < rooms.count else { return }
        rooms.remove(at: index)
    }
    
    // MARK: - Save Record
    
    func saveRecord(completion: @escaping (Record?) -> Void) {
        isLoading = true
        let newRecord = Record(
            title: recordTitle.isEmpty ? "default_record_title_format".localized(Date().formatted(date: .abbreviated, time: .omitted)) : recordTitle,
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
            for photoData in roomData.photos {
                if let fileName = ImageManager.shared.saveImage(photoData) {
                    room.photoPaths.append(fileName)
                }
            }
            newRecord.rooms.append(room)
        }
        
        // Зберігаємо в Realm
        realmManager.createRecord(newRecord)
        
        if let property = selectedProperty {
            // Важливо: property може бути detached, тому передаємо його ID або шукаємо "живий"
            realmManager.addRecordToProperty(record: newRecord, property: property)
        }
        if reminderInterval > 0 {
            NotificationService.shared.requestPermissions { granted in
                if granted {
                    NotificationService.shared.scheduleReportReminder(
                        reportId: newRecord.id.stringValue, // Realm ID в String
                        title: "remiender".localized, // "Нагадування"
                        body: "record_next_visit".localized(newRecord.titleString),
                        daysInterval: self.reminderInterval
                    )
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            self?.showSuccessView = true
            completion(newRecord.detached())  // Повертаємо DETACHED копію
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
