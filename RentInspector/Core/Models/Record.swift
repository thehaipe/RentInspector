/*
 Опис структури звіту (Record).
 Поля:
 @Persisted(primaryKey: true) var id: ObjectId - унікальний ідентифікатор
 @Persisted var title: String - Заголовок звіту
 @Persisted var stage: String - Стадія (Заселення, Проживання, Виселення)
 @Persisted var rooms: List<Room> - Кімнати
 @Persisted var reminderInterval: Int = 0 - Днів до нагадування (0 = вимкнено)
 @Persisted var nextReminderDate: Date? - Дата нагадування про візит
 @Persisted var createdAt: Date = Date() - Дата створення звіту
 @Persisted var updatedAt: Date = Date() - Дата оновлення звіту (планується забрати до версії 2.0)
 */
import Foundation
import RealmSwift

class Record: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var stage: String = RecordStage.moveIn.rawValue
    @Persisted var rooms: List<Room>
    @Persisted var reminderInterval: Int = 0 // Днів до нагадування (0 = вимкнено)
    @Persisted var nextReminderDate: Date?
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    
    // Computed properties
    var recordStage: RecordStage {
        get { RecordStage(rawValue: stage) ?? .moveIn }
        set { stage = newValue.rawValue }
    }
    
    var displayTitle: String {
        return title.isEmpty ? "Record \(createdAt.formatted(date: .abbreviated, time: .omitted))" : title
    }
    
    var totalPhotos: Int {
        return rooms.reduce(0) { $0 + $1.photoData.count }
    }
    
    convenience init(title: String, stage: RecordStage = .moveIn) {
        self.init()
        self.title = title
        self.stage = stage.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    func detached() -> Record {
            let detachedRecord = Record()
            detachedRecord.id = self.id
            detachedRecord.title = self.title
            detachedRecord.stage = self.stage
            detachedRecord.reminderInterval = self.reminderInterval
            detachedRecord.nextReminderDate = self.nextReminderDate
            detachedRecord.createdAt = self.createdAt
            detachedRecord.updatedAt = self.updatedAt
            
            // Копіюємо кімнати
            for room in self.rooms {
                detachedRecord.rooms.append(room.detached())
            }
            
            return detachedRecord
        }
}
