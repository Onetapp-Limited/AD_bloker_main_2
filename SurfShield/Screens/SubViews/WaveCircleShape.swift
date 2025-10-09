import SwiftUI

struct WaveCircleShape: Shape {
    let waveCount: Int
    let waveHeight: CGFloat
    let progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let baseRadius = radius - waveHeight
        
        if waveCount == 0 {
            path.addArc(
                center: center,
                radius: baseRadius,
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
            path.closeSubpath()
            return path
        }
        
        let angleOffset = -CGFloat.pi / 2
        
        for i in stride(from: 0, through: 360, by: 0.5) {
            let angle = angleOffset + CGFloat(i) * .pi / 180
            let waveAdjustment = sin(CGFloat(i) * CGFloat(waveCount) * .pi / 90) * waveHeight * CGFloat(progress)
            let currentRadius = baseRadius + waveAdjustment
            
            let point = CGPoint(
                x: center.x + currentRadius * cos(angle),
                y: center.y + currentRadius * sin(angle)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        
        return path
    }
}

