//
//  Coordinator.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import SwiftUI

final class Coordinator: ObservableObject {
    @Published var tabsPaths = [NavigationPath(), NavigationPath(), NavigationPath()]
    @Published var mainPath = NavigationPath()
    @Published var presentedScreen: Screen? = nil
    
    func fullScreenCover(to screen: Screen) {
        presentedScreen = screen
    }
    
    func push(to screen: Screen) {
        mainPath.append(screen)
    }
    
    func pop() {
        mainPath.removeLast()
    }
    
    @ViewBuilder func build(screen: Screen) -> some View {
        switch screen {
        case .paywall:
            PaywallView()
        }
    }
}
