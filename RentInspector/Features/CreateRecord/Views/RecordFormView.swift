//
//  RecordFormView.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import SwiftUI
import PhotosUI

struct RecordFormView: View {
    @ObservedObject var viewModel: CreateRecordViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showReminderPicker = false
    @State private var savedRecord: Record? = nil
    var onRecordSaved: ((Record) -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок звіту
                recordTitleSection
                
                // Етап звіту
                recordStageSection
                
                // Секції кімнат
                roomSectionsView
                
                // Нагадування
                reminderSection
                
                // Кнопка збереження
                saveButton
            }
            .padding()
        }
        .navigationTitle(viewModel.recordTitle.isEmpty ? "Новий звіт" : viewModel.recordTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Скасувати") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showReminderPicker) {
            reminderPickerSheet
        }
    }
    
    // MARK: - Record Title Section
    
    private var recordTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Назва звіту")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            TextField("Record \(Date().formatted(date: .abbreviated, time: .omitted))", text: $viewModel.recordTitle)
                .textFieldStyle(CustomTextFieldStyle())
                .onChange(of: viewModel.recordTitle) { oldValue, newValue in
                    if newValue.count > Constants.Limits.maxRecordTitleLength {
                        viewModel.recordTitle = String(newValue.prefix(Constants.Limits.maxRecordTitleLength))
                    }
                }
            
            Text("\(viewModel.recordTitle.count)/\(Constants.Limits.maxRecordTitleLength)")
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    // MARK: - Record Stage Section
    
    private var recordStageSection: some View {
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
    }
    
    private func stageButton(stage: RecordStage) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.recordStage = stage
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: stage.icon)
                    .font(.title2)
                
                Text(stage.displayName)
                    .font(AppTheme.caption)
            }
            .foregroundColor(viewModel.recordStage == stage ? .white : AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                viewModel.recordStage == stage
                    ? AppTheme.primaryColor
                    : AppTheme.secondaryBackgroundColor
            )
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }
    
    // MARK: - Room Sections
    
    private var roomSectionsView: some View {
        VStack(spacing: 16) {
            ForEach(Array(viewModel.rooms.enumerated()), id: \.element.id) { index, room in
                RoomSectionView(
                    roomData: $viewModel.rooms[index],
                    roomIndex: index,
                    viewModel: viewModel
                )
                
                // Кнопка "Додати санвузол" після останнього санвузла
                if room.type == .bathroom && index == viewModel.rooms.lastIndex(where: { $0.type == .bathroom }) {
                    Button(action: {
                        viewModel.addBathroom()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Додати санвузол")
                                .font(AppTheme.callout)
                        }
                        .foregroundColor(AppTheme.primaryColor)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    // MARK: - Reminder Section
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Нагадування про візит")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Button(action: {
                showReminderPicker = true
            }) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(AppTheme.primaryColor)
                    
                    if viewModel.reminderInterval > 0 {
                        Text("Кожні \(viewModel.reminderInterval) днів")
                            .foregroundColor(AppTheme.textPrimary)
                    } else {
                        Text("Не встановлено")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.secondaryBackgroundColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
    }
    
    private var reminderPickerSheet: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        viewModel.reminderInterval = 0
                        showReminderPicker = false
                    }) {
                        HStack {
                            Text("Вимкнено")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if viewModel.reminderInterval == 0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                    }
                }
                
                Section("Інтервал нагадування") {
                    ForEach([7, 14, 30, 60, 90], id: \.self) { days in
                        Button(action: {
                            viewModel.reminderInterval = days
                            showReminderPicker = false
                        }) {
                            HStack {
                                Text("\(days) днів")
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                if viewModel.reminderInterval == days {
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
                        showReminderPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button(action: {
            viewModel.saveRecord { record in
                if let record = record {
                    onRecordSaved?(record)  
                }
            }
            }) {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("Зберегти звіт")
                        .font(AppTheme.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(viewModel.isLoading ? AppTheme.secondaryColor : AppTheme.primaryColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(viewModel.isLoading || !viewModel.canProceed)
        .padding(.top, 16)
    }
}

#Preview {
    NavigationStack {
        RecordFormView(viewModel: CreateRecordViewModel())
    }
}
