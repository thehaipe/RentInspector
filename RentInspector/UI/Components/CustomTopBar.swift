internal import SwiftUI


struct CustomTopBar<Actions: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let actions: Actions
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Заголовок
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            
            Spacer(minLength: 16)
            
            // Капсула з кнопками
            HStack(spacing: 12) {
                actions
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .padding(.top, 4)
    }
}

// Кнопки лишаємо ті самі, вони гарні
struct TopBarButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 36, height: 36)
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
                .frame(width: 36, height: 36)
                .background(AppTheme.primaryColor)
                .clipShape(Circle())
        }
    }
}
