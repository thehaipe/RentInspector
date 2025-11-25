/*
 Екран-карточка запису для ScrollView, щоб відобразити його мініатюру у RecordsView
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
                if let parentId = record.parentId,
                   let propertyName = realmManager.getPropertyName(for: parentId) {
                    HStack(spacing: 4) {
                        Image(systemName: "building.2.fill")
                            .font(.caption)
                        Text(propertyName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppTheme.primaryColor)
                    .padding(.bottom, 2)
                }
                // Заголовок та дата
                HStack {
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

                    // Етап звіту
                    stageBadge
                }
                
                Divider()
                
                // Статистика
                HStack(spacing: 20) {
                    statItem(icon: "door.left.hand.open", value: "\(record.rooms.count)", label: "Кімнат")
                    statItem(icon: "photo", value: "\(record.totalPhotos)", label: "Фото")
                    
                    if record.reminderInterval > 0 {
                        statItem(icon: "bell.fill", value: "\(record.reminderInterval)д", label: "Нагадування")
                    }
                }
            }
            .padding(16)
            .background(AppTheme.secondaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, y: 2)
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
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppTheme.primaryColor)
            
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

#Preview {
    let record = Record(title: "Квартира на Шевченка", stage: .moveIn)
    let room1 = Room(type: .bedroom)
    let room2 = Room(type: .kitchen)
    record.rooms.append(objectsIn: [room1, room2])
    
    return RecordCardView(record: record)
        .padding()
}
