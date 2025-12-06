/*
 Екран, при випадку коли звітів ще не створено
 */
internal import SwiftUI

struct EmptyRecordsView: View {
    let onCreateRecord: () -> Void
    @AppStorage(Constants.UserDefaultsKeys.userName) private var userName = Constants.Defaults.defaultUserName
    
    var body: some View {
        VStack(spacing: 24) {
            // Вітання
            Text("profile_welcome_user_formar".localized(userName))
                .font(AppTheme.title2)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.top, 40)
            
            Spacer()
            
            // Іконка
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.secondaryColor.opacity(0.5))
            
            // Текст
            VStack(spacing: 8) {
                Text("records_empty_title")
                    .font(AppTheme.title2)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("records_empty_desc")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Кнопка створення
            Button(action: onCreateRecord) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("records_create_button")
                        .font(AppTheme.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.primaryColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

#Preview {
    EmptyRecordsView(onCreateRecord: {})
}
