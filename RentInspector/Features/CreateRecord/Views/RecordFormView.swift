/*
 Екран форми звіту. На цьому екрані заповнюється вся інформація про квартиру, додаються фото, коментарі, встановлюються нагадування.
 */
internal import SwiftUI
import PhotosUI

struct RecordFormView: View {
    @ObservedObject var viewModel: CreateRecordViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showReminderPicker = false
    @State private var savedRecord: Record? = nil
    @State private var showPropertyPicker = false
    @FocusState private var isTitleFocused: Bool
    var onRecordSaved: ((Record) -> Void)?
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок звіту
                    recordTitleSection
                    
                    //Привʼязка
                    addPropertyPicker
                    
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
                .padding(.bottom, 60)
            }
            
            if viewModel.showStageConflictToast {
                errorToast
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                viewModel.showStageConflictToast = false
                            }
                        }
                    }
            }
        }
        .navigationTitle(viewModel.recordTitle.isEmpty ? "records_new_record".localized : viewModel.recordTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("general_back") {
                    viewModel.previousStep()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("general_cancel") {
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
            Text("form_title_label")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            TextField("Record \(Date().formatted(date: .abbreviated, time: .omitted))", text: $viewModel.recordTitle)
                .textFieldStyle(CustomTextFieldStyle())
                .focused($isTitleFocused)
                .submitLabel(.done)
                .onChange(of: viewModel.recordTitle) { oldValue, newValue in
                    if newValue.count > Constants.Limits.maxRecordTitleLength {
                        viewModel.recordTitle = String(newValue.prefix(Constants.Limits.maxRecordTitleLength))
                    }
                }
            HStack {
                Text("\(viewModel.recordTitle.count)/\(Constants.Limits.maxRecordTitleLength)")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                if isTitleFocused {
                    Button(action: {
                        isTitleFocused = false
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("general_done")
                                .font(AppTheme.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(12)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTitleFocused)
        }
    }
    
    // MARK: - Record Stage Section
    
    private var recordStageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("form_stage_label")
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
        let isDisabled = viewModel.disabledStages.contains(stage)
        
        return Button(action: {
            if !isDisabled {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.recordStage = stage
                }
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: stage.icon)
                    .font(.title2)
                
                Text(stage.displayName)
                    .font(AppTheme.caption)
            }
            .foregroundColor(
                viewModel.recordStage == stage ? .white :
                    (isDisabled ? AppTheme.textSecondary.opacity(0.5) : AppTheme.textPrimary)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                viewModel.recordStage == stage
                ? AppTheme.primaryColor
                : AppTheme.secondaryBackgroundColor
            )
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .opacity(isDisabled ? 0.5 : 1.0)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .disabled(isDisabled)
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
                            Text("add_bathroom")
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
            Text("form_reminder_label")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Button(action: {
                showReminderPicker = true
            }) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(AppTheme.primaryColor)
                    
                    if viewModel.reminderInterval > 0 {
                        Text("form_reminder_days".localized(viewModel.reminderInterval))
                            .foregroundColor(AppTheme.textPrimary)
                    } else {
                        Text("form_reminder_none")
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
                            Text("turned_off")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            if viewModel.reminderInterval == 0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                    }
                }
                
                Section("form_remiender_range") {
                    ForEach([30, 60, 180, 360], id: \.self) { days in
                        Button(action: {
                            viewModel.reminderInterval = days
                            showReminderPicker = false
                        }) {
                            HStack {
                                Text("form_reminder_days".localized(days))
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
            .navigationTitle("remiender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("general_done") {
                        showReminderPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    // MARK: - Add Property Picker
    private var addPropertyPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("property")
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            if let property = viewModel.selectedProperty {
                // Якщо об'єкт вже вибрано (або пре-вибрано)
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(AppTheme.primaryColor)
                    Text(property.displayName)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    // Кнопка "Змінити", якщо це не пре-вибір
                    Button("general_change") {
                        showPropertyPicker = true
                    }
                    .font(AppTheme.caption)
                }
                .padding()
                .background(AppTheme.secondaryBackgroundColor)
                .cornerRadius(AppTheme.cornerRadiusMedium)
            } else {
                // Якщо нічого не вибрано
                Button(action: {
                    showPropertyPicker = true
                }) {
                    HStack {
                        Image(systemName: "building.2")
                        Text("choose_property")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(AppTheme.secondaryBackgroundColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                }
            }
        }
        .sheet(isPresented: $showPropertyPicker) {
            PropertySelectionView(selectedProperty: $viewModel.selectedProperty)
        }
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
                    Text("create_save_record")
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
    // MARK: - Error Toast
    private var errorToast: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
                VStack(alignment: .leading, spacing: 4) {
                    Text("error_stage_conflict_title".localized)
                        .font(AppTheme.callout.weight(.semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("error_stage_conflict_message".localized)
                        .font(AppTheme.caption)
                        .foregroundColor(AppTheme.textPrimary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Button {
                    withAnimation {
                        viewModel.showStageConflictToast = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(AppTheme.textPrimary.opacity(0.5))
                        .font(.system(size: 14))
                }
            }
            .padding()
            .background(AppTheme.secondaryBackgroundColor)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: AppTheme.shadowColor, radius: 10, y: 5)
            .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(100)
    }
}

#Preview {
    NavigationStack {
        RecordFormView(viewModel: CreateRecordViewModel())
    }
}
