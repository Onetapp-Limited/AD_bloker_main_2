import Foundation
import Combine

final class SettingsMainViewModel: ObservableObject {
    
    let udObserver = UserDefaultsObserver.shared
    
    @Published var statisticsData: ResourceAnalysisData = .init()
    @Published var globalAppSettings: AppSettings = .default {
        didSet {
            udObserver.updateAppSettings(globalAppSettings)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setDefaultState()
        startObserve()
    }
    
    private func setDefaultState() {
        globalAppSettings = udObserver.appSettings
    }
    
    private func startObserve() {
        udObserver.$webViewBlockedStatistics
            .receive(on: DispatchQueue.main)
            .assign(to: \.statisticsData, on: self)
            .store(in: &cancellables)
    }
}
