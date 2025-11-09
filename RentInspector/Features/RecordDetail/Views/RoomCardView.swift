//
//  RoomCardView.swift
//  RentInspector
//
//  Created by Valentyn on 08.11.2025.
//
import SwiftUI

struct RoomCardView: View {
    let room: Room
    
    var body: some View {
        HStack(spacing: 16) {
            // Іконка кімнати
            ZStack {
                Circle()
                    .fill(AppTheme.primaryColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: room.roomType.icon)
                    .font(.title3)
                    .foregroundColor(AppTheme.primaryColor)
            }
            
            // Інформація про кімнату
            VStack(alignment: .leading, spacing: 4) {
                Text(room.displayName)
                    .font(AppTheme.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                if !room.comment.isEmpty {
                    Text(room.comment)
                        .font(AppTheme.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Кількість фото
            if !room.photoData.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "photo.fill")
                        .font(.caption)
                    Text("\(room.photoData.count)")
                        .font(AppTheme.caption)
                }
                .foregroundColor(AppTheme.primaryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.primaryColor.opacity(0.15))
                .cornerRadius(8)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(16)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
}

#Preview {
    let room = Room(type: .bedroom, customName: "Спальня")
    room.comment = "Велика кімната з балконом"
    
    return RoomCardView(room: room)
        .padding()
}
