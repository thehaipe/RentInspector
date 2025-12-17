internal import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarView.Tab
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabBarView.Tab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20))
                            .symbolVariant(selectedTab == tab ? .fill : .none)
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                            .lineLimit(1)
                    }
                    .foregroundColor(selectedTab == tab ? AppTheme.primaryColor : AppTheme.textPrimary.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(AppTheme.primaryColor.opacity(0.15))
                                    .matchedGeometryEffect(id: "activeTab", in: animationNamespace)
                            }
                        }
                    )
                }
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(AppTheme.secondaryBackgroundColor)
                .shadow(color: AppTheme.shadowColor.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 30)
        .padding(.bottom, 4)
    }
}

