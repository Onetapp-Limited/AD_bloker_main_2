import Foundation
import Combine

class UserDefaultsObserver: ObservableObject {
    static let shared = UserDefaultsObserver()
    private var cancellables = Set<AnyCancellable>()
    let userDefaultsService = UserDefaultsService.shared
    
    @Published var webViewBlockedStatistics: ResourceAnalysisData = .init()
    // App settings
    @Published var appSettings: AppSettings = .default
    
    // Инициализируем из UserDefaults
    init() {
        self.webViewBlockedStatistics = userDefaultsService.load(ResourceAnalysisData.self, forKey: .webViewBlockedStatistics) ?? .init()
        self.appSettings = loadAppSettings()
    }
    
    func updateAdblockerState(_ isOn: Bool) {
        appSettings.advancedProtection = isOn
    }
    
    func updateAppSettings(_ settings: AppSettings) {
        self.appSettings = settings
        userDefaultsService.save(settings, forKey: .appSettings)
//        self.saveAppSettings()
    }
    
    func updateWebViewBlockedStatistics(_ statistics: ResourceAnalysisData) {
        var newStatistics: ResourceAnalysisData = webViewBlockedStatistics
        newStatistics.blockedCount += statistics.blockedCount
        newStatistics.totalLoadedResources += statistics.totalLoadedResources
        newStatistics.totalPageResources += statistics.totalPageResources
        
        webViewBlockedStatistics = newStatistics
        userDefaultsService.save(newStatistics, forKey: .webViewBlockedStatistics)
    }
    
    private func loadAppSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.appSettings.key),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    /// Сброс настроек к значениям по умолчанию
    func resetSettingsToDefault() {
        appSettings = .default
    }
}
