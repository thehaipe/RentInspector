/*
 Класс для роботи з налаштуваннями додатку
 */
import SwiftUI
internal import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var showClearDataAlert: Bool = false
    @Published var showSuccessToast: Bool = false
    @Published var showErrorToast: Bool = false
    @Published var errorMessage: String = ""
    
    private var realmManager = RealmManager.shared
    
    func clearAllData() {
        do {
            try realmManager.clearAllData()
            
            // Показуємо success toast
            withAnimation {
                showSuccessToast = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.showSuccessToast = false
                }
            }
        } catch let error as RealmError {
            // Показуємо error toast
            errorMessage = error.errorDescription ?? "Невідома помилка"
            
            withAnimation {
                showErrorToast = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.showErrorToast = false
                }
            }
        } catch {
            // Інші помилки
            errorMessage = error.localizedDescription
            
            withAnimation {
                showErrorToast = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.showErrorToast = false
                }
            }
        }
    }
}
