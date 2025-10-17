import SwiftUI

struct MainView: View {
    @StateObject var coordinator = Coordinator()
    @StateObject var appState = AppState()
    @State private var isPaywallPresented: Bool = false

    var body: some View {
        content
            .environmentObject(appState)
            .environmentObject(coordinator)
            .fullScreenCover(item: $coordinator.presentedScreen) { screen in
                coordinator.build(screen: screen)
            }
    }
    
    
    @ViewBuilder
    var content: some View {
        switch appState.viewState {
        case .onboarding:
            OnboardingView()
        case .main:
            mainContent
        }
    }
    
    var mainContent: some View {
        NavigationStack(path: $coordinator.mainPath) {
            TabBarView()
                .navigationDestination(for: Screen.self) { screen in
                    coordinator.build(screen: screen)
                }
                .onAppear {
                    if !appState.isPaywallFirstTimeShown {
                        isPaywallPresented = true
                    }
                }
                .fullScreenCover(isPresented: $isPaywallPresented) {
                    PaywallView(isPresented: $isPaywallPresented)
                        .onDisappear {
                            appState.setPayWallShown()
                        }
                }
        }
    }
}
