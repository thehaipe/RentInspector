internal import SwiftUI

struct NativeFilterSheetView: View {
    @Binding var selectedFilter: RecordsViewModel.DateFilter
    // Опціональна прив'язка до етапу. Якщо nil, секція не показується
    var selectedStageFilter: Binding<RecordStage?>? = nil
    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section("records_filter_by_date") {
                    ForEach(RecordsViewModel.DateFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            if selectedStageFilter == nil {
                                isPresented = false
                            }
                        }) {
                            HStack {
                                Text(filter.displayName)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.primaryColor)
                                }
                            }
                        }
                    }
                }
                if let stageBinding = selectedStageFilter {
                    Section("record_stage") {
                        Button(action: {
                            stageBinding.wrappedValue = nil
                        }) {
                            HStack {
                                Text("filter_all")
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                if stageBinding.wrappedValue == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.primaryColor)
                                }
                            }
                        }
                        
                        // Конкретні етапи
                        ForEach(RecordStage.allCases, id: \.self) { stage in
                            Button(action: {
                                stageBinding.wrappedValue = stage
                            }) {
                                HStack {
                                    Label(stage.displayName, systemImage: stage.icon)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    if stageBinding.wrappedValue == stage {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(AppTheme.primaryColor)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("records_filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("general_done") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
