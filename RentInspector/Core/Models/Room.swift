/*
 Опис структури кімнати (Частина запису)
 Поля:
 @Persisted(primaryKey: true) var id: ObjectId - Унікальний ідентифікатор
 @Persisted var type: String // RoomType.rawValue - Фаза
 @Persisted var customName: String - Довільне імʼя кімнаті, яке може дати користувач. За замовчуванням поле пусте та не застосовується
 @Persisted var comment: String - Коментар до кімнати, на що слід звернути увагу при перевірці у майбутньому
 @Persisted var photoData: List<Data> // Зберігаємо фото як Data - Фотограції
 @Persisted var createdAt: Date = Date() - Дата створення
 */
import Foundation
import RealmSwift

class Room: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var type: String // RoomType.rawValue
    @Persisted var customName: String = ""
    @Persisted var comment: String = ""
    //@Persisted var photoData: List<Data> // Зберігаємо фото як Data
    @Persisted var photoPaths: List<String>
    @Persisted var createdAt: Date = Date()
    
    var roomType: RoomType {
        get { RoomType(rawValue: type) ?? .other }
        set { type = newValue.rawValue }
    }
    
    var displayName: String {
        return customName.isEmpty ? roomType.displayName : customName
    }
    
    convenience init(type: RoomType, customName: String = "") {
        self.init()
        self.type = type.rawValue
        self.customName = customName
    }
    func detached() -> Room {
            let detachedRoom = Room()
            detachedRoom.id = self.id
            detachedRoom.type = self.type
            detachedRoom.customName = self.customName
            detachedRoom.comment = self.comment
            detachedRoom.createdAt = self.createdAt
            
            // Копіюємо фото
            for photo in self.photoPaths {
                detachedRoom.photoPaths.append(photo)
            }
            
            return detachedRoom
        }
}
