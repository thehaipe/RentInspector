import SwiftUI
import RealmSwift

struct PropertyDetailView: View {
    let property: Property
    @ObservedObject var realmManager = RealmManager.shared
    @State private var showCreateRecord = false
    
    // Фільтруємо записи для конкретного об'єкту
    var propertyRecords: [Record] {
        realmManager.records.filter { record in
            record.parentId == property.id
        }
    }
    
    var body: some View {
        ZStack {
            if propertyRecords.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(propertyRecords) { record in
                            RecordCardView(record: record)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(property.name.isEmpty ? property.address : property.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showCreateRecord = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        // Передаємо цей об'єкт у координатор, щоб звіт створився вже прив'язаним
        .fullScreenCover(isPresented: $showCreateRecord) {
            CreateRecordCoordinator(preselectedProperty: property)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            
            Text("У цьому об'єкті ще немає звітів")
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textSecondary)
            
            Button(action: {
                showCreateRecord = true
            }) {
                Text("Створити перший звіт")
                    .font(AppTheme.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(AppTheme.primaryColor)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
    }
}
