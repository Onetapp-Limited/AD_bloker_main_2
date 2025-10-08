//
//  TabBarView.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import SwiftUI


struct TabBarView: View {
    @State var selection: Int = 0
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        content
    }
    
    var content: some View {
        tabView
    }
    
    
    var tabView: some View {
        TabView(selection: $selection,
                content:  {
            MainAdBlockerView()
                .tabItem { Label("Block Ads", systemImage: "shield.fill") }
                .tag(0)
            
            InternetBrowserView()
                .tabItem { Label("Browser", systemImage: "network") }
                .tag(1)
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(2)
        }
        )
        .tint(.tm.accentSecondary)
    }
}
