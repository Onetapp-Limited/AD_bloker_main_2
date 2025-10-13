import SwiftUI

enum Layout {
    enum Radius {
        static let regular: CGFloat = 8
        static let medium: CGFloat = 16
    }
    
    enum Padding: CGFloat {
        /// 2
        case small = 2
        /// 4
        case smallExt = 4
        /// 8
        case regular = 8
        /// 12
        case regularExt = 12
        /// 16
        case medium = 16
        /// 20
        case mediumExt = 20
        /// 24
        case large = 24
        /// 32
        case extraLarge = 32
        
        var horizontalSpacing: CGFloat {
            Layout.Padding.medium.rawValue
        }
    }
}
