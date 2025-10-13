import SwiftUI

extension View {
    func padding(_ padding: Layout.Padding) -> some View {
        self.padding(padding.rawValue)
    }

    func padding(_ edges: Edge.Set = .all, _ padding: Layout.Padding) -> some View {
        self.padding(edges, padding.rawValue)
    }
}
