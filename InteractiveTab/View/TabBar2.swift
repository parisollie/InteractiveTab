import SwiftUI

struct TabBar2: View {
    @State private var activeTab: TabItem = .home
    var body: some View {
        /// This Project supports iOS 17 as well
        ZStack(alignment: .bottom) {
            if #available(iOS 18, *) {
                TabView(selection: $activeTab) {
                    /// Replace with your Tab view's
                    ForEach(TabItem.allCases, id: \.rawValue) { tab in
                        Tab.init(value: tab) {
                            Text(tab.rawValue)
                                /// Must hide the native tab bar
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                }
            } else {
                TabView(selection: $activeTab) {
                    /// Replace with your Tab view's
                    ForEach(TabItem.allCases, id: \.rawValue) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                            /// Must hide the native tab bar
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            
            InteractiveTabBar1(activeTab: $activeTab)
        }
    }
}

/// You can also create this as a floating tab bar in a few simple steps
/// Interactive Tab Bar
struct InteractiveTabBar1: View {
    @Binding var activeTab: TabItem
    /// View Properties
    @Namespace private var animation
    /// Storing the locations of the Tab buttons so that they can be used to identify the currently dragged tab
    @State private var tabButtonLocations: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    /// By using this, we can animate the changes in the tab bar without animating the actual tab view. When the gesture is released, the changes are pushed to the tab view
    @State private var activeDraggingTab: TabItem?
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 40)
        .padding(5)
        .background {
            Capsule()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
        }
        .coordinateSpace(.named("TABBAR"))
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    /// Each Individual Tab Button View
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab
        
        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .symbolVariant(.fill)
                .foregroundStyle(isActive ? .white : .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if isActive {
                Capsule()
                    .fill(.blue.gradient)
                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
            }
        }
        .onGeometryChange(for: CGRect.self, of: {
            $0.frame(in: .named("TABBAR"))
        }, action: { newValue in
            tabButtonLocations[tab.index] = newValue
        })
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.snappy) {
                activeTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("TABBAR"))
                .onChanged { value in
                    let location = value.location
                    /// Checking if the location falls within any stored locations; if so, switching to the appropriate index
                    if let index = tabButtonLocations.firstIndex(where: { $0.contains(location) }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[index]
                        }
                    }
                }.onEnded { _ in
                    /// Pushing changes to the actual tab view
                    if let activeDraggingTab {
                        activeTab = activeDraggingTab
                    }
                    
                    activeDraggingTab = nil
                },
            ///  This will immediately become false once the tab is moved, so change this to check the actual tab value instead of the dragged value
            isEnabled: activeTab == tab
        )
    }
}
