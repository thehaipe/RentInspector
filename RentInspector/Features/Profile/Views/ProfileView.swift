//
//  ProfileView.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        ZStack {
                VStack(spacing: 32) {
                    // Аватар
                    avatarSection
                    
                    // Форма імені
                    nameSection
                    
                    // Статистика
                    statisticsSection
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Профіль")
                .navigationBarTitleDisplayMode(.inline)
            
            // Success Toast
            if viewModel.showSuccessMessage {
                successToast
            }
        }
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
            
            Text("Welcome!")
                .font(AppTheme.title3)
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.top, 20)
    }
    // MARK: - Name Section
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ім'я")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            TextField("Введіть ваше ім'я", text: $viewModel.userName)
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
                Text("Зберегти")
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
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 12) {
                statisticRow(
                    icon: "doc.text.fill",
                    title: "Всього звітів",
                    value: "\(RealmManager.shared.getRecordCount())"
                )
                
                statisticRow(
                    icon: "clock.fill",
                    title: "Використовуєте додаток з",
                    value: installDate
                )
                
                statisticRow(
                    icon: "info.circle.fill",
                    title: "Версія",
                    value: "\(Constants.AppInfo.version) (\(Constants.AppInfo.build))"
                )
            }
        }
        .padding(20)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    private func statisticRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 30)
            
            Text(title)
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.callout)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
        }
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
                
                Text("Ім'я збережено")
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
