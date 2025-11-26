/*
 Екран-карточка запису для ScrollView, щоб відобразити його мініатюру у RecordsView
 */
import SwiftUI
import RealmSwift

struct RecordCardView: View {
    let record: Record
    @ObservedObject private var realmManager = RealmManager.shared
    
    var body: some View {
        if !record.isInvalidated {
            NavigationLink(destination: RecordDetailView(record: record)) {
                cardContent
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 1. Назва Об'єкта (Context)
            if let parentId = record.parentId,
               let propertyName = realmManager.getPropertyName(for: parentId) {
                HStack(spacing: 4) {
                    Image(systemName: "building.2.fill")
                        .font(.caption2)
                    Text(propertyName.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(0.5)
                }
                .foregroundColor(AppTheme.primaryColor)
                .padding(.bottom, -4)
            }
            
            // 2. Заголовок, Дата, Етап
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.displayTitle)
                        .font(AppTheme.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTheme.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                stageBadge
            }
            
            Divider()
            
            // 3. Статистика
            HStack(spacing: 16) {
                // Кімнати
                statItem(
                    icon: "door.left.hand.open",
                    value: "\(record.rooms.count)",
                    label: "Кімнат"
                )
                
                // Фото
                statItem(
                    icon: "photo",
                    value: "\(record.totalPhotos)",
                    label: "Фото"
                )
                
                // Нагадування
                if record.reminderInterval > 0 {
                    statItem(
                        icon: "bell.fill",
                        value: "\(record.reminderInterval)д",
                        label: ""
                    )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, y: 2)
    }
    
    // Повернули старий дизайн: Іконка (Колір) + Число (Жирне) + Текст (Сірий)
    private func statItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body) // Трохи більша іконка
                .foregroundColor(AppTheme.primaryColor)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(AppTheme.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(label)
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
    
    private var stageBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: record.recordStage.icon)
                .font(.caption)
            Text(record.recordStage.displayName)
                .font(AppTheme.caption)
        }
        .foregroundColor(stageColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(stageColor.opacity(0.15))
        .cornerRadius(8)
    }
    
    private var stageColor: Color {
        switch record.recordStage {
        case .moveIn: return AppTheme.successColor
        case .living: return AppTheme.primaryColor
        case .moveOut: return AppTheme.warningColor
        }
    }
}

#Preview {
    let record = Record(title: "Квартира на Шевченка", stage: .moveIn)
    let room1 = Room(type: .bedroom)
    let room2 = Room(type: .kitchen)
    record.rooms.append(objectsIn: [room1, room2])
    record.reminderInterval = 7
    
    return RecordCardView(record: record)
        .padding()
        .environmentObject(RealmManager.shared)
}
