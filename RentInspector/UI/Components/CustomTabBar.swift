internal import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarView.Tab
    @Namespace private var animationNamespace
    @AppStorage("selectedLanguage") private var language: String = "uk"
    private let allTabs = TabBarView.Tab.allCases
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabWidth = totalWidth / CGFloat(allTabs.count)
            
            HStack(spacing: 0) {
                ForEach(allTabs, id: \.self) { tab in
                    VStack(spacing: 2) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20))
                            .symbolVariant(selectedTab == tab ? .fill : .none)
                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                            .lineLimit(1)
                            .id(language)
                    }
                    .foregroundColor(selectedTab == tab ? AppTheme.primaryColor : AppTheme.textPrimary.opacity(0.7))
                    .frame(width: tabWidth)
                    .frame(maxHeight: .infinity)
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
                    .contentShape(Rectangle())
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let x = value.location.x
                        let index = min(max(Int(x / tabWidth), 0), allTabs.count - 1)
                        let newTab = allTabs[index]
                        
                        if newTab != selectedTab {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
                                selectedTab = newTab
                            }
                            generateHapticFeedback()
                        }
                    }
            )
        }
        .frame(height: 60)
        .padding(4)
        .background(
            Capsule()
                .fill(AppTheme.secondaryBackgroundColor)
                .shadow(color: AppTheme.shadowColor.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 30)
        .padding(.bottom, 4)
    }
    
    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
