//
//  Colors.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import SwiftUI

enum ThemeColors: String {
    case accent = "Accent"
    case accentSecondary = "AccentSecondary"
    case accentTertiary = "AccentTertiary"
    case title = "Title"
    case subTitle = "Subtitle"
    case background = "Background"
    case container = "Container"
    case error = "Error"
    case success = "Success"
    case calm = "Calm"
    case calmSecondary = "CalmSecondary"
    
    // Тут будет дополнительное вычисляемое свойство для определения выбора темы из экрана настроек
    var color: Color {
        let name = self.rawValue
        return Color(name)
    }
}

struct Colors {
    var accent: Color { ThemeColors.accent.color }
    var accentSecondary: Color { ThemeColors.accentSecondary.color }
    var accentTertiary: Color { ThemeColors.accentTertiary.color }
    var background: Color { ThemeColors.background.color }
    var container: Color { ThemeColors.container.color }
    var error: Color { ThemeColors.error.color }
    var success: Color { ThemeColors.success.color }
    var title: Color { ThemeColors.title.color }
    var subTitle: Color { ThemeColors.subTitle.color }
    var calm: Color { ThemeColors.calm.color }
    var calmSecondary: Color { ThemeColors.calmSecondary.color }
}


// Расширение для ShapeStyle
extension ShapeStyle where Self == Color {
    static var tm: Colors {
        Colors()
    }
}

// Расширение для Color
extension Color {
    static var tm: Colors { Colors() }
    
    init(color: ThemeColors) {
        self = color.color
    }
}

// Расширение для использования в .foregroundStyle
extension ShapeStyle where Self == Color {
    static func fromColors(_ colors: ThemeColors) -> Self {
        return colors.color
    }
}
