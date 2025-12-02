/*
 Екран налаштувань додатку
 */
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showThemeSheet = false
    @AppStorage("selectedLanguage") private var languageCode = "uk"
    var body: some View {
            ZStack {
                List {
                    // Секція Appearance
                    Section {
                        themeButton
                        languagePicker
                    } header: {
                        Text("Зовнішній вигляд")
                    }
                    
                    // Секція Data
                    Section {
                        NavigationLink(destination: RecordsView()) {
                            storageInfo
                        }
                        clearDataButton
                    } header: {
                        Text("Дані")
                    }
                    
                    // Секція About
                    Section {
                        aboutRow(icon: "info.circle.fill", title: "Версія", value: Constants.AppInfo.version)
                        aboutRow(icon: "number.circle.fill", title: "Збірка", value: Constants.AppInfo.build)
                        aboutRow(icon: "hammer.fill", title: "Розробник", value: "")
                    } header: {
                        Text("Про додаток")
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //розташування або principal, або largeTitle, чекаю оновлення аби подивитись Canvas
                    ToolbarItem(placement: .principal) {
                        Text("Налаштування")
                            .font(AppTheme.title2)
                            .fontWeight(.bold)
                    }
                }
                .sheet(isPresented: $showThemeSheet) {
                    themeSelectionSheet
                }
                .alert("Очистити всі дані?", isPresented: $viewModel.showClearDataAlert) {
                    Button("Скасувати", role: .cancel) { }
                    Button("Видалити", role: .destructive) {
                        viewModel.clearAllData()
                    }
                } message: {
                    Text("Всі звіти будуть видалені назавжди. Цю дію неможливо скасувати.")
                }
                
                // Success Toast
                if viewModel.showSuccessToast {
                    successToast
                }
                
                // Error Toast
                if viewModel.showErrorToast {
                    errorToast
                }
            }
    }
    
    // MARK: - Theme Button
    
    private var themeButton: some View {
        Button(action: {
            showThemeSheet = true
        }) {
            HStack {
                Image(systemName: themeManager.selectedTheme.icon)
                    .foregroundColor(AppTheme.primaryColor)
                    .frame(width: 30)
                
                Text("Тема")
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text(themeManager.selectedTheme.displayName)
                    .foregroundColor(AppTheme.textSecondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
    // MARK: - Language Picker
        
        private var languagePicker: some View {
            Picker(selection: $languageCode) {
                ForEach(Constants.AppLanguage.allCases) { language in
                    Text(language.displayName)
                        .tag(language.rawValue)
                }
            } label: {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(width: 30)
                    
                    Text("Languages")
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .pickerStyle(.menu) 
        }
    // MARK: - Storage Info
    
    private var storageInfo: some View {
        HStack {
            Image(systemName: "internaldrive.fill")
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 30)
            
            Text("Звітів збережено")
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Text("\(RealmManager.shared.getRecordCount())")
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    // MARK: - Clear Data Button
    
    private var clearDataButton: some View {
        Button(action: {
            viewModel.showClearDataAlert = true
        }) {
            HStack {
                Image(systemName: "trash.fill")
                    .foregroundColor(AppTheme.errorColor)
                    .frame(width: 30)
                
                Text("Очистити всі дані")
                    .foregroundColor(AppTheme.errorColor)
            }
        }
    }
    
    // MARK: - About Row
    
    private func aboutRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    // MARK: - Theme Selection Sheet
    
    private var themeSelectionSheet: some View {
        NavigationStack {
            List {
                ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                    Button(action: {
                        withAnimation {
                            themeManager.selectedTheme = theme
                        }
                        showThemeSheet = false
                    }) {
                        HStack {
                            Image(systemName: theme.icon)
                                .foregroundColor(AppTheme.primaryColor)
                                .frame(width: 30)
                            
                            Text(theme.displayName)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            if themeManager.selectedTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Вибір теми")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        showThemeSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Success Toast
    
    private var successToast: some View {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.successColor)
                    
                    Text("Дані успішно видалено")
                        .font(AppTheme.callout)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                }
                .padding()
                .background(AppTheme.secondaryBackgroundColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .shadow(color: AppTheme.shadowColor, radius: 10, y: 5)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    // MARK: - Error Toast
    private var errorToast: some View {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.warningColor)
                    
                    Text(viewModel.errorMessage)
                        .font(AppTheme.callout)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                }
                .padding()
                .background(AppTheme.secondaryBackgroundColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .shadow(color: AppTheme.shadowColor, radius: 10, y: 5)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ThemeManager.shared)
    }
}
