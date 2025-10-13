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
    
    var color: Color {
        let name = self.rawValue
        return Color(name)
    }
}
