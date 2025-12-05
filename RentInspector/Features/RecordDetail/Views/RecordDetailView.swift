/*
 Екран перегляду готового звіту та елементи взаємодії з ним.
 */
import SwiftUI
import RealmSwift

struct RecordDetailView: View {
    @StateObject private var viewModel: RecordDetailViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTitleFocused: Bool
    
    @State private var pdfURL: URL?
    
    init(record: Record) {
        _viewModel = StateObject(wrappedValue: RecordDetailViewModel(record: record))
    }
    
    var body: some View {
        ZStack {
            // Основний контент
            ScrollView {
                VStack(spacing: 24) {
                    // Header Info (З вибором об'єкта)
                    headerSection
                    
                    // Stage Section
                    stageSection
                    
                    // Reminder Section
                    reminderSection
                    
                    // Rooms Section
                    roomsSection
                    
                    // Delete Button
                    deleteButton
                }
                .padding()
            }
            
            // Toast помилки (Валідація етапів)
            if viewModel.showErrorToast {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text(viewModel.errorMessage)
                            .font(AppTheme.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture {
                        withAnimation {
                            viewModel.showErrorToast = false
                        }
                    }
                }
                .zIndex(100) // Поверх усього
            }
        }
        .navigationTitle(viewModel.record.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        viewModel.isEditingTitle = true
                    }) {
                        Label("edit_record_title", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        exportPDF()
                    }) {
                        Label("export_pdf_from_selected_record", systemImage: "arrow.down.doc")
                    }
                    
                    Button(role: .destructive, action: {
                        viewModel.showDeleteAlert = true
                    }) {
                        Label("delete_record", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        // Шторка експорту PDF
        .sheet(item: $pdfURL) { url in
            ShareSheet(items: [url, viewModel.record.displayTitle])
        }
        // Шторка вибору об'єкту
        .sheet(isPresented: $viewModel.showPropertyPicker) {
            PropertySelectionView(selectedProperty: Binding(
                get: { viewModel.selectedProperty },
                set: { newProp in
                    viewModel.updateProperty(newProp)
                }
            ))
        }
        // Алерт редагування назви
        .alert("edit_record_title", isPresented: $viewModel.isEditingTitle) {
            TextField("form_title_label", text: $viewModel.editedTitle)
            Button("general_cancel", role: .cancel) {
                viewModel.editedTitle = viewModel.record.title
            }
            Button("general_save") {
                viewModel.saveTitle()
            }
        }
        // Алерт видалення
        .alert("delete_record", isPresented: $viewModel.showDeleteAlert) {
            Button("general_cancel", role: .cancel) { }
            Button("general_delete", role: .destructive) {
                viewModel.deleteRecord {
                    dismiss()
                }
            }
        } message: {
            Text("error_delete_record_confirmation")
        }
        // Пікер нагадування
        .sheet(isPresented: $viewModel.showReminderPicker) {
            reminderPickerSheet
        }
        // Деталі кімнати
        .sheet(item: $viewModel.selectedRoomIndex) { index in
            if index < viewModel.record.rooms.count {
                RoomDetailView(
                    room: viewModel.record.rooms[index],
                    roomIndex: index,
                    viewModel: viewModel
                )
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // --- Секція вибору об'єкта ---
            Button(action: {
                viewModel.showPropertyPicker = true
            }) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(width: 20)
                    
                    if let property = viewModel.selectedProperty {
                        Text(property.displayName)
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.textPrimary)
                    } else {
                        Text("attach_to_property")
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .italic()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            // Дата створення
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.primaryColor)
                
                Text(viewModel.formattedDate)
                    .font(AppTheme.callout)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // Статистика
            HStack(spacing: 24) {
                statItem(icon: "door.left.hand.open", value: "\(viewModel.record.rooms.count)", label: "record_room")
                statItem(icon: "photo", value: "\(viewModel.record.totalPhotos)", label: "record_photo")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    private func statItem(icon: String, value: String, label: LocalizedStringKey) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.primaryColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(AppTheme.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(label)
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Stage Section
    
    private var stageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("record_stage")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(RecordStage.allCases, id: \.self) { stage in
                    stageButton(stage: stage)
                }
            }
        }
        .padding(16)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    private func stageButton(stage: RecordStage) -> some View {
            // Кнопка тепер завжди disabled, вона працює як індикатор
            let isSelected = viewModel.editedStage == stage
            
            return Button(action: {
                // Ніякої дії. Етап змінювати не можна.
            }) {
                VStack(spacing: 8) {
                    Image(systemName: stage.icon)
                        .font(.title2)
                    
                    Text(stage.displayName)
                        .font(AppTheme.caption)
                }
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.backgroundColor
                )
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .disabled(true) // Головна зміна: кнопка вимкнена назавжди
        }
    
    private func exportPDF() {
        if let url = PDFExportService.shared.generatePDF(for: viewModel.record) {
            pdfURL = url
        }
    }
    
    // MARK: - Reminder Section
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("remiender")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Button(action: {
                viewModel.showReminderPicker = true
            }) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(AppTheme.primaryColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if viewModel.record.reminderInterval > 0 {
                            Text("form_reminder_days".localized(viewModel.record.reminderInterval))
                                .foregroundColor(AppTheme.textPrimary)
                                .font(AppTheme.body)
                            
                            Text("record_next_visit".localized(viewModel.nextReminderText))
                                .foregroundColor(AppTheme.textSecondary)
                                .font(AppTheme.caption)
                        } else {
                            Text("form_reminder_none")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.tertiaryBackgroundColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
        .padding(16)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    private var reminderPickerSheet: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        viewModel.updateReminderInterval(0)
                        viewModel.showReminderPicker = false
                    }) {
                        HStack {
                            Text("turned_off")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if viewModel.record.reminderInterval == 0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                    }
                }
                
                Section("form_remiender_range") {
                    ForEach([7, 14, 30, 60, 90], id: \.self) { days in
                        Button(action: {
                            viewModel.updateReminderInterval(days)
                            viewModel.showReminderPicker = false
                        }) {
                            HStack {
                                Text("\(days) \("days".localized)")
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                if viewModel.record.reminderInterval == days {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.primaryColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("remiender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("general_done") {
                        viewModel.showReminderPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Rooms Section
    
    private var roomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("record_rooms")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 16)
            
            ForEach(Array(viewModel.record.rooms.enumerated()), id: \.element.id) { index, room in
                Button(action: {
                    viewModel.selectedRoomIndex = index
                }) {
                    RoomCardView(room: room)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Delete Button
    
    private var deleteButton: some View {
        Button(action: {
            viewModel.showDeleteAlert = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "trash.fill")
                    .font(.title3)
                Text("general_delete")
                    .font(AppTheme.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.errorColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
        .padding(.top, 16)
    }
}

// MARK: - Int Extension for Identifiable

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    let record = Record(title: "Квартира на Шевченка", stage: .moveIn)
    let room1 = Room(type: .bedroom, customName: "Кімната 1")
    let room2 = Room(type: .kitchen)
    record.rooms.append(objectsIn: [room1, room2])
    
    return NavigationStack {
        RecordDetailView(record: record)
    }
}
