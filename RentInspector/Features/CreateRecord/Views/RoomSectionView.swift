/*
 Шаблон кімнати, використовується як фабрика для інших кімнат у формі.
 */
import SwiftUI
import PhotosUI

struct RoomSectionView: View {
    @Binding var roomData: CreateRecordViewModel.RoomData
    let roomIndex: Int
    @ObservedObject var viewModel: CreateRecordViewModel
    
    @State private var isExpanded: Bool = true
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @FocusState private var isNameFocused: Bool
    @FocusState private var isCommentFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок секції
            sectionHeader
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Назва кімнати
                    nameField
                    
                    // Коментар
                    commentField
                    
                    // Фотографії
                    photosSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
        .onChange(of: selectedPhotos) { oldValue, newValue in
            loadPhotos(from: newValue)
        }
    }
    
    // MARK: - Section Header
    
    private var sectionHeader: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Image(systemName: roomData.type.icon)
                    .foregroundColor(AppTheme.primaryColor)
                    .frame(width: 30)
                
                Text(roomData.displayName)
                    .font(AppTheme.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                // Індикатор фото
                if !roomData.photos.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .font(.caption)
                        Text("\(roomData.photos.count)")
                            .font(AppTheme.caption)
                    }
                    .foregroundColor(AppTheme.primaryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryColor.opacity(0.15))
                    .cornerRadius(8)
                }
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(16)
        }
    }
    
    // MARK: - Name Field
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Назва")
                .font(AppTheme.callout)
                .foregroundColor(AppTheme.textSecondary)
            
            TextField(roomData.type.displayName, text: Binding(
                get: { roomData.customName },
                set: { viewModel.updateRoomName(at: roomIndex, name: $0) }
            ))
            .textFieldStyle(CustomTextFieldStyle())
            .focused($isNameFocused)
            .onChange(of: roomData.customName) { oldValue, newValue in
                if newValue.count > Constants.Limits.maxRoomNameLength {
                    viewModel.updateRoomName(at: roomIndex, name: String(newValue.prefix(Constants.Limits.maxRoomNameLength)))
                }
            }
            
            Text("\(roomData.customName.count)/\(Constants.Limits.maxRoomNameLength)")
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    // MARK: - Comment Field
    
    private var commentField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Коментар")
                .font(AppTheme.callout)
                .foregroundColor(AppTheme.textSecondary)
            
            TextEditor(text: Binding(
                get: { roomData.comment },
                set: { viewModel.updateRoomComment(at: roomIndex, comment: $0) }
            ))
            .frame(minHeight: 80)
            .padding(8)
            .background(AppTheme.tertiaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusSmall)
            .focused($isCommentFocused)
            .onChange(of: roomData.comment) { oldValue, newValue in
                    // Перевірка на натискання Return (останній символ — новий рядок)
                    if newValue.last == "\n" {
                        // Видаляємо символ нового рядка
                        let cleanComment = String(newValue.dropLast())
                        viewModel.updateRoomComment(at: roomIndex, comment: cleanComment)
                        // Ховаємо клавіатуру
                        isCommentFocused = false
                        return
                    }
                    if newValue.count > Constants.Limits.maxCommentLength {
                        viewModel.updateRoomComment(at: roomIndex, comment: String(newValue.prefix(Constants.Limits.maxCommentLength)))
                    }
            }
            
            Text("\(roomData.comment.count)/\(Constants.Limits.maxCommentLength)")
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    // MARK: - Photos Section
    
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Фотографії")
                    .font(AppTheme.callout)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Text("\(roomData.photos.count)/\(Constants.Limits.maxPhotosPerRoom)")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Кнопка додавання фото
                    if roomData.photos.count < Constants.Limits.maxPhotosPerRoom {
                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: Constants.Limits.maxPhotosPerRoom - roomData.photos.count,
                            matching: .images
                        ) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                Text("Додати")
                                    .font(AppTheme.caption)
                            }
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 100, height: 100)
                            .background(AppTheme.tertiaryBackgroundColor)
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                                    .stroke(AppTheme.primaryColor, style: StrokeStyle(lineWidth: 2, dash: [5]))
                            )
                        }
                    }
                    
                    // Фотографії
                    ForEach(Array(roomData.photos.enumerated()), id: \.offset) { index, photoData in
                        photoThumbnail(photoData: photoData, index: index)
                    }
                }
            }
        }
    }
    
    private func photoThumbnail(photoData: Data, index: Int) -> some View {
        Button(action: {
            // TODO: Повноекранний перегляд фото
        }) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                        .clipped()
                }
                
                // Кнопка видалення (правильне позиціонування)
                Button(action: {
                    withAnimation {
                        viewModel.removePhotoFromRoom(at: roomIndex, photoIndex: index)
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white, .red)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(6)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Load Photos
    
    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.addPhotoToRoom(at: roomIndex, photoData: data)
                    }
                }
            }
            await MainActor.run {
                selectedPhotos.removeAll()
            }
        }
    }
}
