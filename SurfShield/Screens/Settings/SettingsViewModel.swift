import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    
    let userDefaultsObserver = UserDefaultsObserver.shared
    
    @Published var resourceStatistics: ResourceAnalysisData = .init()
    @Published var appSettings: AppSettings = .default {
        didSet {
            userDefaultsObserver.updateAppSettings(appSettings)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        initialState()
        subscribe()
    }
    
    private func initialState() {
        appSettings = userDefaultsObserver.appSettings
    }
    
    private func subscribe() {
        userDefaultsObserver.$webViewBlockedStatistics
            .receive(on: DispatchQueue.main)
            .assign(to: \.resourceStatistics, on: self)
            .store(in: &cancellables)
    }
}
