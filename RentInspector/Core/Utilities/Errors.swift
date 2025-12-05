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
            return NSLocalizedString("realm_no_records", comment: "")
        case .recordNotFound:
            return NSLocalizedString("realm_record_not_found", comment: "")
        case .roomNotFound:
            return NSLocalizedString("realm_room_not_found", comment: "")
        case .operationFailed(let message):
            return String(format: NSLocalizedString("realm_operation_failed", comment: ""), message)
        case .invalidData:
            return NSLocalizedString("realm_invalid_data", comment: "")
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
                return NSLocalizedString("error_name_short", comment: "")
            case .nameTooLong:
                return NSLocalizedString("error_name_long", comment: "")
            case .invalidCharacters:
                return NSLocalizedString("error_name_letters_only", comment: "")
            case .containsDigits:
                return NSLocalizedString("error_name_digits", comment: "")
            case .containsSpecialCharacters:
                return NSLocalizedString("error_name_special_chars", comment: "")
            }
        }
}
