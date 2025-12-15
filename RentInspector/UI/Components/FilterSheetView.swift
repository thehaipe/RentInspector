internal import SwiftUI

struct FilterSheetView: View {
    @Binding var selectedFilter: RecordsViewModel.DateFilter
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.secondaryBackgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("records_filter_by_date".localized.uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.leading, 32)
                            .padding(.top, 24)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(RecordsViewModel.DateFilter.allCases.enumerated()), id: \.element) { index, filter in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedFilter = filter
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        isPresented = false
                                    }
                                }) {
                                    HStack {
                                        Text(filter.displayName)
                                            .font(.body)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                        if selectedFilter == filter {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.primaryColor)
                                        }
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                }
                                
                                if index < RecordsViewModel.DateFilter.allCases.count - 1 {
                                    Divider().padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(AppTheme.backgroundColor)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    }
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
}
