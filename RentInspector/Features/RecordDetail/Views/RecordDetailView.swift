//
//  RecordDetailView.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI
import RealmSwift

struct RecordDetailView: View {
    @StateObject private var viewModel: RecordDetailViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTitleFocused: Bool
    
    @State private var showShareSheet = false  // ← Додано
    @State private var pdfURL: URL?
    init(record: Record) {
        _viewModel = StateObject(wrappedValue: RecordDetailViewModel(record: record))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Info
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
        .navigationTitle(viewModel.record.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        viewModel.isEditingTitle = true
                    }) {
                        Label("Редагувати назву", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // TODO: Export PDF
                        exportPDF()
                        print("Export PDF")
                    }) {
                        Label("Експорт PDF", systemImage: "arrow.down.doc")
                    }
                    
                    Button(role: .destructive, action: {
                        viewModel.showDeleteAlert = true
                    }) {
                        Label("Видалити звіт", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Редагувати назву", isPresented: $viewModel.isEditingTitle) {
            TextField("Назва звіту", text: $viewModel.editedTitle)
            Button("Скасувати", role: .cancel) {
                viewModel.editedTitle = viewModel.record.title
            }
            Button("Зберегти") {
                viewModel.saveTitle()
            }
        }
        .alert("Видалити звіт?", isPresented: $viewModel.showDeleteAlert) {
            Button("Скасувати", role: .cancel) { }
            Button("Видалити", role: .destructive) {
                viewModel.deleteRecord {
                    dismiss()
                }
            }
        } message: {
            Text("Цей звіт буде видалено назавжди. Цю дію неможливо скасувати.")
        }
        .sheet(isPresented: $viewModel.showReminderPicker) {
            reminderPickerSheet
        }
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
                statItem(icon: "door.left.hand.open", value: "\(viewModel.record.rooms.count)", label: "Кімнат")
                statItem(icon: "photo", value: "\(viewModel.record.totalPhotos)", label: "Фото")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondaryBackgroundColor)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
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
            Text("Етап")
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
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.updateStage(stage)
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: stage.icon)
                    .font(.title2)
                
                Text(stage.displayName)
                    .font(AppTheme.caption)
            }
            .foregroundColor(viewModel.editedStage == stage ? .white : AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                viewModel.editedStage == stage
                    ? AppTheme.primaryColor
                    : AppTheme.tertiaryBackgroundColor
            )
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
    private func exportPDF() {
        if let url = PDFExportService.shared.generatePDF(for: viewModel.record) {
            pdfURL = url
            showShareSheet = true
        }
    }
    
    // MARK: - Reminder Section
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Нагадування")
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
                            Text("Кожні \(viewModel.record.reminderInterval) днів")
                                .foregroundColor(AppTheme.textPrimary)
                                .font(AppTheme.body)
                            
                            Text("Наступний візит: \(viewModel.nextReminderText)")
                                .foregroundColor(AppTheme.textSecondary)
                                .font(AppTheme.caption)
                        } else {
                            Text("Не встановлено")
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
                            Text("Вимкнено")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if viewModel.record.reminderInterval == 0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                    }
                }
                
                Section("Інтервал нагадування") {
                    ForEach([7, 14, 30, 60, 90], id: \.self) { days in
                        Button(action: {
                            viewModel.updateReminderInterval(days)
                            viewModel.showReminderPicker = false
                        }) {
                            HStack {
                                Text("\(days) днів")
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
            .navigationTitle("Нагадування")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
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
            Text("Кімнати")
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
                Text("Видалити звіт")
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
