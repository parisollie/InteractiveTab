//
//  ContentView.swift
//  InteractiveTab
//
//  Created by Paul F on 22/03/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Stick to Bottom") {
                    TabBar1()
                }
                
                NavigationLink("Floating") {
                    TabBar2()
                }
            }
            .navigationTitle("Interactive Tab Bar")
        }
    }
}


enum TabItem: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case notifications = "Notifications"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .notifications: "bell"
        case .settings: "gearshape"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

#Preview {
    ContentView()
}
