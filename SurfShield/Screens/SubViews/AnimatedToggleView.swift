import SwiftUI

struct AnimatedToggleView: View {
    let isActive: Bool
    let isWorking: Bool
    let waveFillProgress: Double
    let circleRotationAngle: Double
    let uniqueAnimationID: UUID
    let onActivationTap: () -> Void
    
    private let controlSize: CGFloat = 180
    
    var body: some View {
        ZStack {
            // Внешнее свечение при активности
            if isActive {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .tm.accent.opacity(0.6),
                                .tm.accentSecondary.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: controlSize * 0.3,
                            endRadius: controlSize * 0.8
                        )
                    )
                    .frame(width: controlSize * 1.5, height: controlSize * 1.5)
                    .blur(radius: 30)
                    .opacity(isWorking ? 0.6 : 1.0)
            }
            
            // Основная кнопка
            ZStack {
                // Фоновые слои с градиентами
                if isActive {
                    activeButtonBackground
                } else {
                    inactiveButtonBackground
                }
                
                // Иконка
                controlIconOverlay
            }
            .frame(width: controlSize, height: controlSize)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        isActive ?
                        LinearGradient(
                            colors: [.tm.accent.opacity(0.8), .tm.accentSecondary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [.tm.calm.opacity(0.3), .tm.calm.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .shadow(color: isActive ? .tm.accent.opacity(0.5) : .clear, radius: 10)
            )
            .shadow(
                color: isActive ? .tm.accentSecondary.opacity(0.6) : .black.opacity(0.2),
                radius: isActive ? 25 : 15,
                y: isActive ? 8 : 5
            )
            
            // Эффект пульсации при работе
            if isWorking {
                workingPulseEffect
            }
        }
        .scaleEffect(isWorking ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isWorking)
        .onTapGesture {
            onActivationTap()
        }
    }
    
    // Активный фон с динамичными градиентами
    @ViewBuilder
    private var activeButtonBackground: some View {
        ZStack {
            // Базовый слой
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .tm.accentSecondary.opacity(0.9),
                            .tm.accent
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Анимированные волны света
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .scaleEffect(1.0 + (Double(index) * 0.15))
                    .opacity(0.7 - (Double(index) * 0.2))
                    .rotationEffect(.degrees(circleRotationAngle * (index % 2 == 0 ? 1 : -1)))
                    .animation(
                        .linear(duration: 3.0 + Double(index))
                        .repeatForever(autoreverses: false),
                        value: circleRotationAngle
                    )
                    .id(uniqueAnimationID)
            }
            
            // Блики
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.3),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .offset(x: -20, y: -20)
        }
    }
    
    // Неактивный фон
    @ViewBuilder
    private var inactiveButtonBackground: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .tm.container,
                            .tm.container.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Тонкий блик
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.1),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 30,
                        endRadius: 90
                    )
                )
        }
    }
    
    @ViewBuilder
    private var controlIconOverlay: some View {
        ZStack {
            // Свечение за иконкой при активности
            if isActive && !isWorking {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .blur(radius: 20)
                    .scaleEffect(1.8)
            }
            
            // Основная иконка
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 45, weight: .bold))
                .foregroundStyle(
                    isActive ?
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    ) :
                    LinearGradient(
                        colors: [.tm.subTitle.opacity(0.7), .tm.subTitle.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(
                    color: isActive ? .black.opacity(0.3) : .clear,
                    radius: 5,
                    y: 2
                )
                .scaleEffect(isWorking ? 0.85 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isWorking)
        }
    }
    
    // Эффект пульсации при работе
    @ViewBuilder
    private var workingPulseEffect: some View {
        ForEach(0..<2, id: \.self) { index in
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .tm.accent.opacity(0.6),
                            .tm.accentSecondary.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: controlSize, height: controlSize)
                .scaleEffect(1.0 + (Double(index) * 0.2))
                .opacity(0.0)
                .animation(
                    .easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                    .delay(Double(index) * 0.75),
                    value: isWorking
                )
        }
    }
}
