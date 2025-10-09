import SwiftUI

struct FloatingElementsView: View {
    @State private var shouldAnimate: Bool = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .tm.accent.opacity(0.3),
                                .tm.accent.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: 8
                        )
                    )
                    .frame(
                        width: CGFloat.random(in: 4...12),
                        height: CGFloat.random(in: 4...12)
                    )
                    .position(
                        x: shouldAnimate ?
                            CGFloat.random(in: 0...UIScreen.main.bounds.width) :
                            CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: shouldAnimate ?
                            CGFloat.random(in: 0...UIScreen.main.bounds.height) :
                            CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: CGFloat.random(in: 1...3))
                    .animation(
                        .linear(duration: Double.random(in: 8...15))
                        .repeatForever(autoreverses: true),
                        value: shouldAnimate
                    )
            }
        }
        .onAppear {
            shouldAnimate.toggle()
        }
    }
}
