/*
 Екран профілю користувача
 */
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Аватар
                    avatarSection
                    
                    // Форма імені
                    nameSection
                    
                    // Статистика
                    //statisticsSection
                    
                    Spacer()
                }
                .padding()
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //розташування або principal, або largeTitle, чекаю оновлення аби подивитись Canvas
                ToolbarItem(placement: .principal) {
                    Text("profile")
                        .font(AppTheme.title2)
                        .fontWeight(.bold)
                }
            }
            
            // Success Toast
            if viewModel.showSuccessMessage {
                successToast
            }
            
            // Error Toast
            if viewModel.showErrorMessage {
                errorToast
            }
        }
    }
    
    private var errorToast: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppTheme.errorColor)
                
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
    
    // MARK: - Avatar Section
    
    private var avatarSection: some View {
        VStack(spacing: 16) {
            // Іконка профілю
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.primaryColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text(viewModel.userName.prefix(1).uppercased())
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 20, y: 10)
            
            Text("profile_welcome")
                .font(AppTheme.title3)
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.top, 20)
    }
    // MARK: - Name Section
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("profile_name_label")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            TextField("profile_name_placeholder", text: $viewModel.userName)
                .textFieldStyle(CustomTextFieldStyle())
                .focused($isNameFocused)
                .submitLabel(.done)
                .onSubmit {
                    if viewModel.canSave {
                        viewModel.saveUserName()
                        isNameFocused = false
                    }
                }
            
            Button(action: {
                viewModel.saveUserName()
                isNameFocused = false
            }) {
                Text("general_save")
                    .font(AppTheme.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.canSave ? AppTheme.primaryColor : AppTheme.secondaryColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
            .disabled(!viewModel.canSave)
        }
        .padding(20)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
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
    
    // MARK: - Success Toast
    
    private var successToast: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.successColor)
                
                Text("success_name_saved")
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
        ProfileView()
    }
}
