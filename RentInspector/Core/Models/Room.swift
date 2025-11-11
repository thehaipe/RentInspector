//
//  Room.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import Foundation
import RealmSwift

class Room: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var type: String // RoomType.rawValue
    @Persisted var customName: String = ""
    @Persisted var comment: String = ""
    @Persisted var photoData: List<Data> // Зберігаємо фото як Data
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
            for photo in self.photoData {
                detachedRoom.photoData.append(photo)
            }
            
            return detachedRoom
        }
}
