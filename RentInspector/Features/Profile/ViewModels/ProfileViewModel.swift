/*
 Клас для роботи з профілем користувача (відображення статистики, юзернейму)
 */

import SwiftUI
internal import Combine

class ProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var showSuccessMessage: Bool = false
    @Published var showErrorMessage: Bool = false  // ← Додано
    @Published var errorMessage: String = ""        // ← Додано
    
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
        
        // Перевірка на порожнє ім'я
        if trimmedName.isEmpty {
            userName = Constants.Defaults.defaultUserName
            UserDefaults.standard.set(userName, forKey: Constants.UserDefaultsKeys.userName)
            showSuccess()
            return
        }
        
        // Валідація імені
        do {
            try validateName(trimmedName)
            
            // Зберігаємо валідне ім'я
            userName = trimmedName
            UserDefaults.standard.set(userName, forKey: Constants.UserDefaultsKeys.userName)
            showSuccess()
            
        } catch let error as ValidationError {
            showError(error.errorDescription ?? "Невідома помилка")
        } catch {
            showError("Невідома помилка")
        }
    }
    
    // MARK: - Validation
    
    /// Валідація імені користувача
    /// - Дозволено: латиниця, кирилиця, пробіли, апострофи, дефіси
    /// - Заборонено: цифри, спецсимволи (окрім апострофа та дефіса)
    private func validateName(_ name: String) throws {
        // Перевірка довжини
        guard name.count >= 2 else {
            throw ValidationError.nameTooShort
        }
        
        guard name.count <= 50 else {
            throw ValidationError.nameTooLong
        }
        
        // Регулярний вираз:
        // ^                    - початок рядка
        // [a-zA-Zа-яА-ЯіІїЇєЄґҐ''-] - дозволені символи (латиниця, кирилиця, апостроф, дефіс, пробіл)
        // {2,50}              - від 2 до 50 символів
        // $                    - кінець рядка
        let namePattern = "^[a-zA-Zа-яА-ЯіІїЇєЄґҐ''\\-\\s]{2,50}$"
        
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", namePattern)
        
        guard namePredicate.evaluate(with: name) else {
            throw ValidationError.invalidCharacters
        }
        
        // Перевірка на цифри
        let containsDigits = name.rangeOfCharacter(from: .decimalDigits) != nil
        guard !containsDigits else {
            throw ValidationError.containsDigits
        }
        
        // Перевірка на спецсимволи (окрім дозволених)
        let allowedCharacters = CharacterSet.letters
            .union(CharacterSet(charactersIn: " '-"))
        let nameCharacterSet = CharacterSet(charactersIn: name)
        
        guard allowedCharacters.isSuperset(of: nameCharacterSet) else {
            throw ValidationError.containsSpecialCharacters
        }
    }
    
    // MARK: - Helpers
    
    private func showSuccess() {
        withAnimation {
            showSuccessMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation {
                self?.showSuccessMessage = false
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        
        withAnimation {
            showErrorMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            withAnimation {
                self?.showErrorMessage = false
            }
        }
    }
    
    var canSave: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
