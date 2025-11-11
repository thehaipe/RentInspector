/*
 Екран додоаткових кімнат, які можуть як бути в квартирі, так їх може і не бути (гардероб, кладова, інше). 
 */
import SwiftUI

struct AdditionalRoomsSelectionView: View {
    @ObservedObject var viewModel: CreateRecordViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            // Заголовок
            VStack(spacing: 8) {
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryColor)
                
                Text("Додаткові кімнати")
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Вкажіть кількість додаткових приміщень")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Лічильники
            VStack(spacing: 20) {
                counterOption(
                    icon: "cabinet.fill",
                    title: "Гардероб",
                    count: $viewModel.wardrobeCount
                )
                
                counterOption(
                    icon: "archivebox.fill",
                    title: "Кладова",
                    count: $viewModel.storageCount
                )
                
                counterOption(
                    icon: "questionmark.circle.fill",
                    title: "Інше",
                    count: $viewModel.otherCount
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Кнопки навігації
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.previousStep()
                }) {
                    Text("Назад")
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
                    Text("До запису")
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
    
    private func counterOption(icon: String, title: String, count: Binding<Int>) -> some View {
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
    AdditionalRoomsSelectionView(viewModel: CreateRecordViewModel())
}
