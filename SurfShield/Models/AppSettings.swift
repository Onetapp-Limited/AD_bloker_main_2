import Foundation

/// Структура для хранения всех настроек приложения
struct AppSettings: Codable {
    
    // MARK: - AdBlocker Settings
    var advancedProtection = false
    var basicBlock: Bool = false
    var blockAds: Bool = false
    var blockTrackers: Bool = false
    var blockPopups: Bool = false
    var security: Bool = false
    
    // MARK: - Browser Settings
    var enableCookies: Bool = false
    var enableBrowserDarkMode: Bool = false
    var enableBrowserHistory: Bool = true
    var startPage: String = "https://www.google.com"
    
    // MARK: - Default Settings
    static let `default` = AppSettings()
    
}
