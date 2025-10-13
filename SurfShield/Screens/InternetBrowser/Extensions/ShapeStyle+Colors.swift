import SwiftUI

extension ShapeStyle where Self == Color {
    static var tm: Colors {
        Colors()
    }
}

extension Color {
    static var tm: Colors { Colors() }
    
    init(color: ThemeColors) {
        self = color.color
    }
}

extension ShapeStyle where Self == Color {
    static func fromColors(_ colors: ThemeColors) -> Self {
        return colors.color
    }
}
