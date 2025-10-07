//
//  AppSettings.swift
//  SufrShield
//
//  Created by Артур Кулик on 08.09.2025.
//

import Foundation

/// Структура для хранения всех настроек приложения
struct AppSettings: Codable {
    
    // MARK: - AdBlocker Settings
    var advancedProtection: Bool = false
    var basicBlock: Bool = false
    var blockAds: Bool = false
    var blockTrackers: Bool = false
    var blockPopups: Bool = false
    var security: Bool = false
    
    // MARK: - Browser Settings
    var enableCookies: Bool = false
    var enableBrowserDarkMode: Bool = true
    var enableBrowserHistory: Bool = true
    var startPage: String = "https://www.google.com"
    
    // MARK: - Default Settings
    static let `default` = AppSettings()
    
    // MARK: - Computed Properties
    
    /// Получение всех настроек блокировки в виде массива
    var blockingSettings: [(String, Bool)] {
        return [
            ("Basic Protection", basicBlock),
            ("Banner Blocking", blockAds),
            ("Tracker Blocker", blockTrackers),
            ("Privacy Guard", blockPopups),
            ("Security Shield", security)
        ]
    }
    
    /// Получение всех настроек браузера в виде массива
    var browserSettings: [(String, Bool)] {
        return [
            ("Browser History", enableBrowserHistory),
            ("Cookies", enableCookies),
            ("Dark Theme", enableBrowserDarkMode)
        ]
    }
}
