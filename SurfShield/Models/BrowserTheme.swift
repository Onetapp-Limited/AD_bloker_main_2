//
//  BrowserTheme.swift
//  SurfShield
//
//  Created by AI Assistant on 09.09.2025.
//

import Foundation

/// Типы тем для браузера
enum BrowserTheme: String, CaseIterable, Codable {
    case auto = "auto"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .auto:
            return "Автоматически"
        case .light:
            return "Светлая"
        case .dark:
            return "Темная"
        }
    }
    
    var iconName: String {
        switch self {
        case .auto:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
    
    /// Возвращает CSS-свойство для принудительной установки темы
    var cssThemeValue: String {
        switch self {
        case .auto:
            return "auto"
        case .light:
            return "light"
        case .dark:
            return "dark"
        }
    }
    
    /// Возвращает следующую тему в цикле
    func next() -> BrowserTheme {
        let themes = BrowserTheme.allCases
        if let currentIndex = themes.firstIndex(of: self) {
            let nextIndex = (currentIndex + 1) % themes.count
            return themes[nextIndex]
        }
        return .auto
    }
}
