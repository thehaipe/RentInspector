/*
 Клас для роботи з профілем користувача (відображення статистики, юзернейму)
 */
import SwiftUI
internal import Combine

class ProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var showSuccessMessage: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUserName()
    }
    
    func loadUserName() {
        userName = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userName)
            ?? Constants.Defaults.defaultUserName
    }
    
    func saveUserName() {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            userName = Constants.Defaults.defaultUserName
        } else {
            userName = trimmedName
        }
        
        UserDefaults.standard.set(userName, forKey: Constants.UserDefaultsKeys.userName)
        
        // Показуємо повідомлення про успіх
        withAnimation {
            showSuccessMessage = true
        }
        
        // Ховаємо через 2 секунди
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation {
                self?.showSuccessMessage = false
            }
        }
    }
    
    var canSave: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

