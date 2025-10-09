import SwiftUI

struct FlareParticleView: View {
    let index: Int
    let isEmitting: Bool
    
    @State private var isScaling: Bool = false
    
    var body: some View {
        Circle()
            .fill(.tm.accentTertiary.opacity(0.9))
            .frame(width: 5, height: 5)
            .scaleEffect(isScaling ? 0.05 : 1.2)
            .opacity(isScaling ? 0 : 1.0)
            .position(
                x: 90 + cos(Double(index) * .pi / 5) * 110,
                y: 90 + sin(Double(index) * .pi / 5) * 110
            )
            .animation(
                .easeOut(duration: 1.8)
                .repeatForever(autoreverses: false)
                .delay(Double(index) * 0.15),
                value: isScaling
            )
            .onAppear {
                if isEmitting {
                    isScaling = true
                }
            }
    }
}
