/*
 Екран вибору кількості кімнат
 */
internal import SwiftUI

struct RoomCountSelectionView: View {
    @ObservedObject var viewModel: CreateRecordViewModel
        @Environment(\.dismiss) var dismiss
        private let roomOptions = [1, 2, 3, 4, 5]
        
        var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primaryColor)
                    
                    Text("create_step_rooms")
                        .font(AppTheme.title)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("create_room_count_subtitle")
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 32)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(roomOptions, id: \.self) { count in
                            roomOptionButton(count: count)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Кнопки навігації
                HStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("general_cancel")
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
                .padding(.top, 16)
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
                Text("create_room_option_format".localized(count))
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
