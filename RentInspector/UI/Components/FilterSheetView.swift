internal import SwiftUI

struct FilterSheetView: View {
    @Binding var selectedFilter: RecordsViewModel.DateFilter
    // Опціональний фільтр по етапу
    var selectedStageFilter: Binding<RecordStage?>? = nil
    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.secondaryBackgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionHeader("records_filter_by_date")
                            VStack(spacing: 0) {
                                ForEach(Array(RecordsViewModel.DateFilter.allCases.enumerated()), id: \.element) { index, filter in
                                    filterOptionRow(
                                        title: filter.displayName,
                                        isSelected: selectedFilter == filter,
                                        isLast: index == RecordsViewModel.DateFilter.allCases.count - 1
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedFilter = filter
                                        }
                                    }
                                }
                            }
                            .background(AppTheme.backgroundColor)
                            .cornerRadius(16)
                        }
                        if let stageBinding = selectedStageFilter {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionHeader("record_stage")
                                
                                VStack(spacing: 0) {
                                    // Option: All
                                    filterOptionRow(
                                        title: "filter_all".localized,
                                        isSelected: stageBinding.wrappedValue == nil,
                                        isLast: false
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            stageBinding.wrappedValue = nil
                                        }
                                    }
                                    
                                    // Stages
                                    ForEach(Array(RecordStage.allCases.enumerated()), id: \.element) { index, stage in
                                        filterOptionRow(
                                            title: stage.displayName,
                                            icon: stage.icon,
                                            isSelected: stageBinding.wrappedValue == stage,
                                            isLast: index == RecordStage.allCases.count - 1
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                stageBinding.wrappedValue = stage
                                            }
                                        }
                                    }
                                }
                                .background(AppTheme.backgroundColor)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            .navigationTitle("records_filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Text("general_done")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.primaryColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(AppTheme.primaryColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
    
    private func sectionHeader(_ key: String) -> some View {
        Text(key.localized.uppercased())
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(AppTheme.textSecondary)
            .padding(.leading, 16)
    }
    
    private func filterOptionRow(title: String, icon: String? = nil, isSelected: Bool, isLast: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 24)
                    }
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                if !isLast {
                    Divider().padding(.leading, 16)
                }
            }
            .contentShape(Rectangle())
        }
    }
    // Overload for LocalizedStringKey
    private func filterOptionRow(title: LocalizedStringKey, icon: String? = nil, isSelected: Bool, isLast: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 24)
                    }
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                if !isLast {
                    Divider().padding(.leading, 16)
                }
            }
            .contentShape(Rectangle())
        }
    }
}
