/*
 Класс для роботи з налаштуваннями додатку
 */
import SwiftUI
internal import Combine
class SettingsViewModel: ObservableObject {
    @Published var showClearDataAlert: Bool = false
    @Published var showClearDataSuccess: Bool = false
    
    private var realmManager = RealmManager.shared
    
    func clearAllData() {
        realmManager.clearAllData()
        
        withAnimation {
            showClearDataSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation {
                self?.showClearDataSuccess = false
            }
        }
    }
}
