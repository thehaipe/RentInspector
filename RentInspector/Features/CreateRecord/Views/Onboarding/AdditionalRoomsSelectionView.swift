/*
 Екран додоаткових кімнат, які можуть як бути в квартирі, так їх може і не бути (гардероб, кладова, інше). 
 */
internal import SwiftUI

struct AdditionalRoomsSelectionView: View {
    @ObservedObject var viewModel: CreateRecordViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            // Заголовок
            VStack(spacing: 8) {
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryColor)
                
                Text("create_additional_title")
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("create_additional_subtitle")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Лічильники
            VStack(spacing: 20) {
                CounterRowView(
                    icon: "cabinet.fill",
                    title: "room_type_Wardrobe",
                    count: $viewModel.wardrobeCount
                )
                
                CounterRowView(
                    icon: "archivebox.fill",
                    title: "room_type_Storage",
                    count: $viewModel.storageCount
                )
                
                CounterRowView(
                    icon: "questionmark.circle.fill",
                    title: "room_type_Other",
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
                    Text("create_action_to_record")
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
}

#Preview {
    AdditionalRoomsSelectionView(viewModel: CreateRecordViewModel())
}
