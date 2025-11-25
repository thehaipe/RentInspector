import RealmSwift
extension Property {
    func hasRecord(with stage: RecordStage) -> Bool {
        // Перевіряємо, чи є в списку активний (не видалений) звіт з таким етапом
        return records.contains { $0.recordStage == stage && !$0.isInvalidated }
    }
}
