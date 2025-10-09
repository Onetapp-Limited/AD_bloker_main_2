import SwiftUI

final class AppState: ObservableObject {
    
    private let userDefaultsService = UserDefaultsService.shared
    
    @Published var viewState: AppViewState
    var isFirstLoad: Bool = false
    
    enum AppViewState {
        case onboarding
        case main
    }
    
    init() {
        let isOnboardingShown = userDefaultsService.load(Bool.self, forKey: .onboardingCompleted) ?? false
        self.viewState = isOnboardingShown ? .main : .onboarding
    }
    
    
    public func onboardingCompleted() {
        userDefaultsService.save(true, forKey: .onboardingCompleted)
        withAnimation(.easeIn(duration: 0.3)) {
            viewState = .main
        }
    }
    
    private func initialState() {
        let isOnboardingShown = userDefaultsService.load(Bool.self, forKey: .onboardingCompleted) ?? false
        self.viewState = isOnboardingShown ? .main : .onboarding
    }
}
