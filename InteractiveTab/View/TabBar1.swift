import SwiftUI

struct TabBar1: View {
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
            
            InteractiveTabBar(activeTab: $activeTab)
        }
    }
}

/// Interactive Tab Bar
struct InteractiveTabBar: View {
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
        .frame(height: 70)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .background {
            Rectangle()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
                .ignoresSafeArea()
                .padding(.top, 20)
        }
        .coordinateSpace(.named("TABBAR"))
    }
    
    /// Each Individual Tab Button View
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab
        
        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .symbolVariant(.fill)
                .frame(width: isActive ? 50 : 25, height: isActive ? 50 : 25)
                .background {
                    if isActive {
                        Circle()
                            .fill(.blue.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
                /// This gives us the elevation we needed to push the active tab
                .frame(width: 25, height: 25, alignment: .bottom)
                .foregroundStyle(isActive ? .white : .primary)
            
            Text(tab.rawValue)
                .font(.caption2)
                .foregroundStyle(isActive ? .blue : .gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .contentShape(.rect)
        .padding(.top, isActive ? 0 : 20)
        .onGeometryChange(for: CGRect.self, of: {
            $0.frame(in: .named("TABBAR"))
        }, action: { newValue in
            tabButtonLocations[tab.index] = newValue
        })
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

#Preview {
    ContentView()
}
