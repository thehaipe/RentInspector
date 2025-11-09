//
//  RoomDetailView.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI
import PhotosUI
import RealmSwift

struct RoomDetailView: View {
    let room: Room
    let roomIndex: Int
    @ObservedObject var viewModel: RecordDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var editedName: String
    @State private var editedComment: String
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showDeleteAlert = false
    @State private var selectedPhotoIndex: Int? = nil
    @FocusState private var isNameFocused: Bool
    @FocusState private var isCommentFocused: Bool
    
    init(room: Room, roomIndex: Int, viewModel: RecordDetailViewModel) {
        self.room = room
        self.roomIndex = roomIndex
        self.viewModel = viewModel
        _editedName = State(initialValue: room.customName)
        _editedComment = State(initialValue: room.comment)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Room Type
                    roomTypeSection
                    
                    // Name Field
                    nameSection
                    
                    // Comment Field
                    commentSection
                    
                    // Photos Section
                    photosSection
                    
                    // Delete Room Button (якщо це не єдина кімната)
                    if viewModel.record.rooms.count > 1 && room.roomType != .kitchen {
                        deleteRoomButton
                    }
                }
                .padding()
            }
            .navigationTitle(room.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        saveChanges()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
            .alert("Видалити кімнату?", isPresented: $showDeleteAlert) {
                Button("Скасувати", role: .cancel) { }
                Button("Видалити", role: .destructive) {
                    viewModel.deleteRoom(at: roomIndex)
                    dismiss()
                }
            } message: {
                Text("Ця кімната та всі її фото будуть видалені.")
            }
            .fullScreenCover(item: $selectedPhotoIndex) { index in
                if index < room.photoData.count, let uiImage = UIImage(data: room.photoData[index]) {
                    PhotoViewerView(image: uiImage) {
                        selectedPhotoIndex = nil
                    }
                }
            }
            .onChange(of: selectedPhotos) { oldValue, newValue in
                loadPhotos(from: newValue)
            }
        }
    }
    
    // MARK: - Room Type Section
    
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
    
    // MARK: - Name Section
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Назва")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            TextField(room.roomType.displayName, text: $editedName)
                .textFieldStyle(CustomTextFieldStyle())
                .focused($isNameFocused)
                .onChange(of: editedName) { oldValue, newValue in
                    if newValue.count > Constants.Limits.maxRoomNameLength {
                        editedName = String(newValue.prefix(Constants.Limits.maxRoomNameLength))
                    }
                }
            
            Text("\(editedName.count)/\(Constants.Limits.maxRoomNameLength)")
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    // MARK: - Comment Section
    
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Коментар")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            TextEditor(text: $editedComment)
                .frame(minHeight: 100)
                .padding(8)
                .background(AppTheme.tertiaryBackgroundColor)
                .cornerRadius(AppTheme.cornerRadiusSmall)
                .focused($isCommentFocused)
                .onChange(of: editedComment) { oldValue, newValue in
                    if newValue.count > Constants.Limits.maxCommentLength {
                        editedComment = String(newValue.prefix(Constants.Limits.maxCommentLength))
                    }
                }
            
            Text("\(editedComment.count)/\(Constants.Limits.maxCommentLength)")
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    // MARK: - Photos Section
    
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Фотографії")
                    .font(AppTheme.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(room.photoData.count)/\(Constants.Limits.maxPhotosPerRoom)")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if room.photoData.isEmpty {
                emptyPhotosView
            } else {
                photosGrid
            }
        }
    }
    
    private var emptyPhotosView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            
            Text("Немає фотографій")
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textSecondary)
            
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: Constants.Limits.maxPhotosPerRoom,
                matching: .images
            ) {
                Text("Додати фото")
                    .font(AppTheme.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryColor)
                    .cornerRadius(AppTheme.cornerRadiusSmall)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppTheme.tertiaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    private var photosGrid: some View {
        VStack(spacing: 16) {
            // Кнопка додавання фото (зверху)
            if room.photoData.count < Constants.Limits.maxPhotosPerRoom {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: Constants.Limits.maxPhotosPerRoom - room.photoData.count,
                    matching: .images
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Додати фото")
                            .font(AppTheme.callout)
                    }
                    .foregroundColor(AppTheme.primaryColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.tertiaryBackgroundColor)
                    .cornerRadius(AppTheme.cornerRadiusSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                            .stroke(AppTheme.primaryColor, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                }
            }
            
            // Список фото (вертикально)
            if !room.photoData.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(Array(room.photoData.enumerated()), id: \.offset) { index, photoData in
                        photoThumbnailHorizontal(photoData: photoData, index: index)
                    }
                }
            }
        }
    }

    private func photoThumbnailHorizontal(photoData: Data, index: Int) -> some View {
        Button(action: {
            selectedPhotoIndex = index
        }) {
            HStack(spacing: 12) {
                // Фото
                if let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                        .clipped()
                }
                
                // Інфо
                VStack(alignment: .leading, spacing: 4) {
                    Text("Фото \(index + 1)")
                        .font(AppTheme.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Натисніть для перегляду")
                        .font(AppTheme.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                // Кнопка видалення
                Button(action: {
                    withAnimation {
                        viewModel.removePhotoFromRoom(roomIndex: roomIndex, photoIndex: index)
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.errorColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
            .background(AppTheme.tertiaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Delete Room Button
    
    private var deleteRoomButton: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "trash.fill")
                Text("Видалити кімнату")
                    .font(AppTheme.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.errorColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveChanges() {
        viewModel.updateRoomName(at: roomIndex, name: editedName)
        viewModel.updateRoomComment(at: roomIndex, comment: editedComment)
    }
    
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

#Preview {
    let record = Record(title: "Test", stage: .moveIn)
    let room = Room(type: .bedroom, customName: "Спальня")
    record.rooms.append(room)
    
    return RoomDetailView(
        room: room,
        roomIndex: 0,
        viewModel: RecordDetailViewModel(record: record)
    )
}
