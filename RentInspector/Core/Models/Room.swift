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
    
    // Computed property для зручності
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
}
