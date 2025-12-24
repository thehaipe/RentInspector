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
            
            // Лічильники
            VStack(spacing: 20) {
                counterOption(
                    icon: "sun.max.fill",
                    title: "room_type_Balcony",
                    count: $viewModel.balconyCount
                )
                
                counterOption(
                    icon: "rectangle.stack.fill",
                    title: "room_type_Loggia",
                    count: $viewModel.loggiaCount
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
    
    // UI компонент лічильника
    private func counterOption(icon: String, title: LocalizedStringKey, count: Binding<Int>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 40)
            
            Text(title)
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            // Stepper
            HStack(spacing: 16) {
                Button(action: {
                    if count.wrappedValue > 0 {
                        count.wrappedValue -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(count.wrappedValue > 0 ? AppTheme.primaryColor : AppTheme.textSecondary.opacity(0.3))
                }
                .disabled(count.wrappedValue == 0)
                
                Text("\(count.wrappedValue)")
                    .font(AppTheme.title3)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(minWidth: 30)
                
                Button(action: {
                    if count.wrappedValue < 5 {
                        count.wrappedValue += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(count.wrappedValue < 5 ? AppTheme.primaryColor : AppTheme.textSecondary.opacity(0.3))
                }
                .disabled(count.wrappedValue == 5)
            }
        }
        .padding(20)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

#Preview {
    BalconySelectionView(viewModel: CreateRecordViewModel())
}
