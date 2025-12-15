/*
 Екран налаштувань додатку
 */
internal import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showThemeSheet = false
    @AppStorage("selectedLanguage") private var languageCode = "uk"
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Секція Appearance
                    SettingsSectionView(title: "settings_appearance") {
                        Button(action: { showThemeSheet = true }) {
                            SettingsRow(
                                icon: themeManager.selectedTheme.icon,
                                title: "settings_theme",
                                value: themeManager.selectedTheme.displayName,
                                showChevron: true
                            )
                        }
                        
                        customDivider
                        Menu {
                            Picker(selection: $languageCode) {
                                ForEach(Constants.AppLanguage.allCases) { language in
                                    Text(language.displayName).tag(language.rawValue)
                                }
                            } label: { EmptyView() }
                        } label: {
                            SettingsRow(
                                icon: "globe",
                                title: "settings_language",
                                value: Constants.AppLanguage.allCases.first(where: { $0.rawValue == languageCode })?.displayName,
                                showChevron: true
                            )
                        }
                    }
                    
                    // MARK: - Секція Stats & Data
                    SettingsSectionView(title: "settings_data") {
                        SettingsRow(
                            icon: "clock.fill",
                            title: "profile_app_usage",
                            value: installDate
                        )
                        
                        customDivider
                        
                        NavigationLink(destination: RecordsView()) {
                            SettingsRow(
                                icon: "internaldrive.fill",
                                title: "settings_storage_info",
                                value: "\(RealmManager.shared.getRecordCount())",
                                showChevron: true
                            )
                        }
                        
                        customDivider
                        
                        Button(action: { viewModel.showClearDataAlert = true }) {
                            SettingsRow(
                                icon: "trash.fill",
                                title: "settings_clear_data",
                                color: AppTheme.errorColor
                            )
                        }
                    }
                    
                    // MARK: - Секція About
                    SettingsSectionView(title: "settings_about") {
                        SettingsRow(icon: "info.circle.fill", title: "settings_version", value: Constants.AppInfo.version)
                        
                        customDivider
                        
                        SettingsRow(icon: "number.circle.fill", title: "settings_build", value: Constants.AppInfo.build)
                        
                        customDivider
                        
                        SettingsRow(icon: "hammer.fill", title: "settings_developer", value: "settings_me")
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("settings")
                        .font(AppTheme.title2)
                        .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showThemeSheet) {
                themeSelectionSheet
            }
            .alert("settings_clear_alert_title", isPresented: $viewModel.showClearDataAlert) {
                Button("general_cancel", role: .cancel) { }
                Button("general_delete", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("error_delete_all_records_alert_title")
            }
            
            // Toasts
            if viewModel.showSuccessToast { successToast }
            if viewModel.showErrorToast { errorToast }
        }
    }
    
    // MARK: - Helpers & Components
    
    private var customDivider: some View {
        Divider()
            .padding(.leading, 40)
    }
    
    private var installDate: String {
        if let installDate = UserDefaults.standard.object(forKey: "installDate") as? Date {
            return installDate.formatted(date: .abbreviated, time: .omitted)
        } else {
            let now = Date()
            UserDefaults.standard.set(now, forKey: "installDate")
            return now.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    // MARK: - Theme Sheet
    private var themeSelectionSheet: some View {
        NavigationStack {
            List {
                ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                    Button(action: {
                        withAnimation { themeManager.selectedTheme = theme }
                        showThemeSheet = false
                    }) {
                        HStack {
                            Image(systemName: theme.icon)
                                .foregroundColor(AppTheme.primaryColor)
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
            .navigationTitle("settings_choose_theme")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("general_done") { showThemeSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Toasts
    private var successToast: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.successColor)
                Text("success_all_records_deleted")
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
        .zIndex(100)
    }
    
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
        .zIndex(100)
    }
}

// MARK: - Reusable UI Components

struct SettingsSectionView<Content: View>: View {
    let title: LocalizedStringKey?
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.leading, 16)
                    .textCase(nil)
            }
            
            VStack(spacing: 0) {
                content
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
            .background(AppTheme.secondaryBackgroundColor)
            .cornerRadius(16)
        }
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    @ViewBuilder let trailing: Content
    
    init(icon: String, title: LocalizedStringKey, color: Color = AppTheme.primaryColor, @ViewBuilder trailing: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24, alignment: .center)
            
            Text(title)
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            trailing
        }
        .padding(.vertical, 12)
    }
}

extension SettingsRow where Content == AnyView {
    
    // Ініціалізатор для звичайного String
    init(icon: String, title: LocalizedStringKey, value: String? = nil, color: Color = AppTheme.primaryColor, showChevron: Bool = false) {
        self.init(icon: icon, title: title, color: color) {
            AnyView(
                HStack(spacing: 6) {
                    if let value = value {
                        Text(value)
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.body)
                    }
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(uiColor: .tertiaryLabel))
                    }
                }
            )
        }
    }
    
    init(icon: String, title: LocalizedStringKey, value: LocalizedStringKey?, color: Color = AppTheme.primaryColor, showChevron: Bool = false) {
        self.init(icon: icon, title: title, color: color) {
            AnyView(
                HStack(spacing: 6) {
                    if let value = value {
                        Text(value)
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.body)
                    }
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(uiColor: .tertiaryLabel))
                    }
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ThemeManager.shared)
    }
}
