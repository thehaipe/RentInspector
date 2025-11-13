import Foundation

enum RealmError: LocalizedError {
    case noRecordsToDelete
    case recordNotFound
    case roomNotFound
    case operationFailed(String)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .noRecordsToDelete:
            return "Немає записів до видалення"
        case .recordNotFound:
            return "Запис не знайдено"
        case .roomNotFound:
            return "Кімнату не знайдено"
        case .operationFailed(let message):
            return "Помилка операції: \(message)"
        case .invalidData:
            return "Невалідні дані"
        }
    }
    
    var icon: String {
        switch self {
        case .noRecordsToDelete, .recordNotFound, .roomNotFound:
            return "xmark.circle.fill"
        case .operationFailed, .invalidData:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .noRecordsToDelete, .recordNotFound, .roomNotFound:
            return "warning" // Жовтий
        case .operationFailed, .invalidData:
            return "error" // Червоний
        }
    }
}
enum ValidationError: LocalizedError {
    case nameTooShort
    case nameTooLong
    case invalidCharacters
    case containsDigits
    case containsSpecialCharacters
    
    var errorDescription: String? {
        switch self {
        case .nameTooShort:
            return "Ім'я має містити мінімум 2 символи"
        case .nameTooLong:
            return "Ім'я має містити максимум 50 символів"
        case .invalidCharacters:
            return "Дозволено тільки літери (латиниця/кирилиця)"
        case .containsDigits:
            return "Ім'я не може містити цифри"
        case .containsSpecialCharacters:
            return "Ім'я не може містити спецсимволи"
        }
    }
}
