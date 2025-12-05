/*
 UI-компонент: Зміна теми додатку
 */
import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        themeManager.selectedTheme = theme
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }) {
                    HStack(spacing: 16) {
                        // Іконка теми
                        ZStack {
                            Circle()
                                .fill(themeManager.selectedTheme == theme
                                      ? AppTheme.primaryColor.opacity(0.2)
                                      : AppTheme.tertiaryBackgroundColor)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: theme.icon)
                                .font(.title3)
                                .foregroundColor(themeManager.selectedTheme == theme
                                                 ? AppTheme.primaryColor
                                                 : AppTheme.textSecondary)
                        }
                        
                        // Назва та опис
                        VStack(alignment: .leading, spacing: 4) {
                            Text(theme.displayName)
                                .font(AppTheme.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(theme.description)
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Checkmark
                        if themeManager.selectedTheme == theme {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.primaryColor)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("settings_choose_theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ThemeSelectionView()
            .environmentObject(ThemeManager.shared)
    }
}
