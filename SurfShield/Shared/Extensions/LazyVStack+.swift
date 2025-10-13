import SwiftUI

extension LazyVStack {
    init(alignment: HorizontalAlignment = .center, spacing: Layout.Padding, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.rawValue, content: content)
    }

    init(@ViewBuilder content: () -> Content) {
        self.init(alignment: .center, spacing: nil, content: content)
    }
}
