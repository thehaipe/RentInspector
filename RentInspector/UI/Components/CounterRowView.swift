/*
 Універсальний рядок з лічильником
 */
internal import SwiftUI

struct CounterRowView: View {
    let icon: String
    let title: LocalizedStringKey
    @Binding var count: Int
    var maxCount: Int = 5 // Дефолтне обмеження, міняється за потреби при виклику
    
    var body: some View {
        HStack {
            // Іконка та назва
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
                // Кнопка Мінус
                Button(action: {
                    if count > 0 {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        count -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(count > 0 ? AppTheme.primaryColor : AppTheme.textSecondary.opacity(0.3))
                }
                .disabled(count == 0)
                
                // Цифра
                Text("\(count)")
                    .font(AppTheme.title3)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(minWidth: 30, alignment: .center)
                
                // Кнопка Плюс
                Button(action: {
                    if count < maxCount {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        count += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(count < maxCount ? AppTheme.primaryColor : AppTheme.textSecondary.opacity(0.3))
                }
                .disabled(count >= maxCount)
            }
        }
        .padding(20)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

#Preview {
    ZStack {
        Color.gray
        CounterRowView(icon: "star.fill", title: "Test Item", count: .constant(2))
            .padding()
    }
}
