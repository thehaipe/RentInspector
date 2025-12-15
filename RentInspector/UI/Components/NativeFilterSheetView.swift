internal import SwiftUI

struct NativeFilterSheetView: View {
    @Binding var selectedFilter: RecordsViewModel.DateFilter
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section("records_filter_by_date") {
                    ForEach(RecordsViewModel.DateFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            isPresented = false
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
