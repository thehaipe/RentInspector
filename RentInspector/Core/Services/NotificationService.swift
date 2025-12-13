import UserNotifications
import UIKit

class NotificationService: NSObject {
    
    static let shared = NotificationService()
    
    // ПРАПОРЕЦЬ ДЛЯ ТЕСТУВАННЯ
    // true = 1 день сприймається як 1 секунда (для швидких тестів)
    // false = 1 день = 86400 секунд (продакшн)
    private let isDebug = true
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 1. Запит дозволу
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // 2. Встановлення періодичного нагадування для конкретного звіту
    func scheduleReportReminder(
        reportId: String,
        title: String,
        body: String,
        daysInterval: Int
    ) {
        let identifier = makeIdentifier(for: reportId)
        removeReportReminder(reportId: reportId)
        let multiplier: TimeInterval = isDebug ? 1.0 : 86400.0
        let timeInterval = TimeInterval(daysInterval) * multiplier
        if timeInterval < 60 && isDebug {
            print("Інтервал \(timeInterval) сек замалий для повторюваних сповіщень (мінімум 60с).")
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for report \(reportId): \(error)")
            } else {
                let unit = self.isDebug ? "сек" : "днів"
                print("Нагадування для звіту [\(reportId)] встановлено.")
                print("Інтервал: \(daysInterval) \(unit) (Всього: \(timeInterval) сек)")
            }
        }
    }
    
    // 3. Видалення нагадування для конкретного звіту
    func removeReportReminder(reportId: String) {
        let identifier = makeIdentifier(for: reportId)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Нагадування для звіту [\(reportId)] видалено")
    }
    
    // 4. Перевірка активних нагадувань (debug)
    func checkPendingReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Всього активних нагадувань: \(requests.count)")
            for req in requests {
                if let trigger = req.trigger as? UNTimeIntervalNotificationTrigger {
                    print("ID: \(req.identifier)")
                    print("Наступне спрацювання через: \(String(format: "%.1f", trigger.timeInterval)) сек")
                }
            }
        }
    }
    
    // MARK: - Helpers
    // Єдине місце формування ID, щоб уникнути помилок ручного вводу
    private func makeIdentifier(for reportId: String) -> String {
        return "report_reminder_\(reportId)"
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

