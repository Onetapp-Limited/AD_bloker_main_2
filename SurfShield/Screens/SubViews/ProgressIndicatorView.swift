import SwiftUI

struct ProgressIndicatorView: View {
    @State private var isAnimating: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .tm.accent,
                                .tm.accentSecondary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 6, height: 20)
                    .scaleEffect(
                        x: 1.0,
                        y: isAnimating ? 1.5 : 0.5,
                        anchor: .center
                    )
                    .opacity(isAnimating ? 1.0 : 0.4)
                    .shadow(
                        color: .tm.accent.opacity(isAnimating ? 0.6 : 0.2),
                        radius: 4
                    )
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

