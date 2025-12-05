import SwiftUI
import RealmSwift

struct RoomDetailView: View {
    let room: Room
    let roomIndex: Int
    // ViewModel нам тут вже майже не потрібна для редагування,
    // але залишаємо, якщо треба щось читати.
    @ObservedObject var viewModel: RecordDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPhotoIndex: Int? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Тип кімнати
                    roomTypeSection
                    
                    // Назва (Read Only)
                    infoSection(title: "form_record_title_label", text: room.displayName)
                    
                    // Коментар (Read Only)
                    if !room.comment.isEmpty {
                        infoSection(title: "records_comment", text: room.comment)
                    }
                    
                    // Фотографії (Тільки перегляд)
                    photosSection
                }
                .padding()
            }
            .navigationTitle(room.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("general_close") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(item: $selectedPhotoIndex) { index in
                if index < room.photoPaths.count,
                   let uiImage = ImageManager.shared.loadImage(named: room.photoPaths[index]) {
                    PhotoViewerView(image: uiImage) {
                        selectedPhotoIndex = nil
                    }
                }
            }
        }
    }
    
    private var roomTypeSection: some View {
        HStack {
            Image(systemName: room.roomType.icon)
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primaryColor)
            Text(room.roomType.displayName)
                .font(AppTheme.title3)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
        .padding(16)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    // Універсальна картка для тексту
    private func infoSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(text)
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppTheme.tertiaryBackgroundColor)
                .cornerRadius(AppTheme.cornerRadiusSmall)
        }
    }
    
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("records_photos")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            if room.photoPaths.isEmpty {
                Text("records_no_photos")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .italic()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(room.photoPaths.enumerated()), id: \.offset) { index, photoPath in
                        photoThumbnail(photoPath: photoPath, index: index)
                    }
                }
            }
        }
    }
    
    private func photoThumbnail(photoPath: String, index: Int) -> some View {
        Button(action: {
            selectedPhotoIndex = index
        }) {
            HStack(spacing: 12) {
                if let uiImage = ImageManager.shared.loadImage(named: photoPath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                        .clipped()
                }
                
                Text("photo_number_format".localized(index + 1))
                    .font(AppTheme.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "eye.fill")
                    .foregroundColor(AppTheme.primaryColor)
            }
            .padding(12)
            .background(AppTheme.tertiaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
}
