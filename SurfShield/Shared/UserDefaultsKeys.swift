import Foundation

/// Enum для ключей UserDefaults
enum UserDefaultsKeys: String, CaseIterable {
    case resourceAnalysis = "resource_analysis"
    case blockedResources = "blocked_resources"
    case loadedResources = "loaded_resources"
    case pageResources = "page_resources"
    case trafficStatistics = "traffic_statistics"
    case adBlockRules = "ad_block_rules"
    case appSettings = "user_settings"
    case adBlockerEnabled = "adBlockerEnabled"
    case webViewBlockedStatistics = "webViewBlockedStatistics"
    case onboardingCompleted = "onboardingCompleted"
    case isPaywallFirstTimeShown = "isPaywallFirstTimeShown"

    // Settings keys
    case basicBlock = "basicBlock"
    case blockAds = "blockAds"
    case blockTrackers = "blockTrackers"
    case blockPopups = "blockPopups"
    case security = "security"
    case enableCookies = "enableCookies"
    case enableBrowserDarkMode = "enableBrowserDarkMode"
    case enableBrowserHistory = "enableBrowserHistory"
    case startPage = "startPage"
    
    var key: String {
        return self.rawValue
    }
}
