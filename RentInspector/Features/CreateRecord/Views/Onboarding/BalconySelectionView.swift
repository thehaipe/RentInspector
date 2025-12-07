/*
 Екран додавання балкону, лоджі
 */
internal import SwiftUI

struct BalconySelectionView: View {
    @ObservedObject var viewModel: CreateRecordViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            // Заголовок
            VStack(spacing: 8) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryColor)
                
                Text("create_balcony_title")
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("create_balcony_subtitle")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Toggles
            VStack(spacing: 20) {
                toggleOption(
                    icon: "sun.max.fill",
                    title: "room_type_Balcony",
                    isOn: $viewModel.hasBalcony
                )
                
                toggleOption(
                    icon: "rectangle.stack.fill",
                    title: "room_type_Loggia",
                    isOn: $viewModel.hasLoggia
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Кнопки навігації
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.previousStep()
                }) {
                    Text("general_back")
                        .font(AppTheme.headline)
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.secondaryBackgroundColor)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }
                
                Button(action: {
                    viewModel.nextStep()
                }) {
                    Text("general_next")
                        .font(AppTheme.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
    
    private func toggleOption(icon: String, title: LocalizedStringKey, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isOn.wrappedValue ? AppTheme.primaryColor : AppTheme.textSecondary)
                .frame(width: 40)
            
            Text(title)
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(20)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

#Preview {
    BalconySelectionView(viewModel: CreateRecordViewModel())
}
