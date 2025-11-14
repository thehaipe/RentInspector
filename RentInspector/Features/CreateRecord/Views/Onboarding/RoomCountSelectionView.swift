/*
 Екран вибору кількості кімнат
 */
import SwiftUI

struct RoomCountSelectionView: View {
    @ObservedObject var viewModel: CreateRecordViewModel
    @Environment(\.dismiss) var dismiss
    private let roomOptions = [1, 2, 3, 4, 5]
    
    var body: some View {
        VStack(spacing: 32) {
            // Заголовок
            VStack(spacing: 8) {
                Image(systemName: "bed.double.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryColor)
                
                Text("Скільки кімнат?")
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Оберіть кількість житлових кімнат")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Вибір кількості кімнат
            VStack(spacing: 16) {
                ForEach(roomOptions, id: \.self) { count in
                    roomOptionButton(count: count)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Кнопка Next
            Button(action: {
                viewModel.nextStep()
            }) {
                Text("Далі")
                    .font(AppTheme.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.primaryColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
            .padding(.horizontal, 24)
            //БАГ-РЕПОРТ: Тестувальник №6, кнопка залазить в Safe Area, попереднє значення: 32
            .padding(.bottom, 70)
            .disabled(!viewModel.canProceed)
            .opacity(viewModel.canProceed ? 1 : 0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
    
    private func roomOptionButton(count: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectedRoomCount = count
            }
        }) {
            HStack {
                Text("\(count)-кімнатна")
                    .font(AppTheme.headline)
                    .foregroundColor(viewModel.selectedRoomCount == count ? .white : AppTheme.textPrimary)
                
                Spacer()
                
                if viewModel.selectedRoomCount == count {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .background(
                viewModel.selectedRoomCount == count
                    ? AppTheme.primaryColor
                    : AppTheme.secondaryBackgroundColor
            )
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(
                color: viewModel.selectedRoomCount == count
                    ? AppTheme.primaryColor.opacity(0.3)
                    : AppTheme.shadowColor,
                radius: 8,
                y: 4
            )
        }
    }
}

#Preview {
    RoomCountSelectionView(viewModel: CreateRecordViewModel())
}
