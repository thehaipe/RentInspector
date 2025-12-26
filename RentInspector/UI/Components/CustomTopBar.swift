internal import SwiftUI

struct CustomTopBar<Actions: View>: View {
    
    let title: LocalizedStringKey
    // За замовчуванням true, щоб не ламати SettingsView
    var isActionsVisible: Bool = true
    var onBackButtonTap: (() -> Void)? = nil
    @ViewBuilder let actions: Actions
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            // Кнопка "Назад"
            if let onBack = onBackButtonTap {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.primaryColor)
                        .padding(.trailing, 8)
                }
            }
            
            // Заголовок
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            
            Spacer(minLength: 16)
            
            // Логіка відображення кнопок
            if Actions.self != EmptyView.self && isActionsVisible {
                HStack(spacing: 12) {
                    actions
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                //Адаптивний фон
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(Capsule())
                //Обводка тільки у темній темі
                .overlay(
                    Capsule()
                        .strokeBorder(
                            colorScheme == .dark ? Color.white.opacity(0.15) : Color.clear,
                            lineWidth: 1
                        )
                )
                //Тінь тільки у світлій темі
                .shadow(
                    color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 3
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct TopBarButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 28, height: 28)
        }
    }
}

struct TopBarPrimaryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(AppTheme.primaryColor)
                .clipShape(Circle())
        }
    }
}
