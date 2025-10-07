//
//  BlockAdsView.swift
//  SufrShield
//
//  Created by Артур Кулик on 23.08.2025.
//

import SwiftUI
import Combine
import SafariServices
// MARK: - ViewModel
@MainActor
class BlockAdsViewModel: ObservableObject {
    
    @Published var waveProgress: Double = 0
    @Published var circleRotation: Double = 0
    @Published var isEnabled: Bool = false
    @Published var isProcess: Bool = false
    @Published var waveHeight: CGFloat = 0
    let rulesConverter = RulesConverter()
    let userDefaultsInteractor = UserDefaultsService.shared
    
    private var blockingTask: Task<Void, Never>?
    private var continuousAnimationTask: Task<Void, Never>?
    var animationID = UUID() // Для отслеживания текущей анимации
    
    init() {
        // Инициализируем блокировщик с сохраненным состоянием
        let isEnabled = userDefaultsInteractor.load(Bool.self, forKey: .adBlockerEnabled)
        self.isEnabled = isEnabled ?? false
    }
    
    func toggleBlocking() {
        if !isProcess {
            toggleAllBlocking()
        } else {
            cancelBlockingTask()
        }
    }
    
    private func toggleAllBlocking() {
        animate()
        
        // Сразу определяем новое состояние
        let newState = !isEnabled
        
        blockingTask = Task {
            if !newState {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            
            if !Task.isCancelled {
                // Применяем новое состояние через RulesConverter
                await rulesConverter.applyBlockingState(newState)
                userDefaultsInteractor.save(newState, forKey: .adBlockerEnabled)
                await MainActor.run {
                    // Обновляем состояние с анимацией
                    withAnimation(.bouncy(duration: 0.2)) {
                        isProcess = false
                        isEnabled = newState
                    }
                    
                    // Запускаем или останавливаем постоянную анимацию
                    if newState {
                        startContinuousAnimation()
                    } else {
                        stopContinuousAnimation()
                    }
                }
            }
        }
    }

    
    func animate() {
        animationID = UUID()

        // Disable previous animation
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            circleRotation = 0
            waveHeight = 0
            waveProgress = 0
        }

        withAnimation(.bouncy(duration: 0.2, extraBounce: 0.1)) {
            isProcess = true
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
            self.waveProgress = 1.0
        }
        
//        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            self.circleRotation = 360
//        }
    }
    
    func cancelBlockingTask() {
        blockingTask?.cancel()
        blockingTask = nil
        
        // Обновляем состояние
        withAnimation(.easeInOut(duration: 0.2)) {
            isProcess = false
        }
        
        // Если блокировка не включена, останавливаем анимацию
        if !isEnabled {
            stopContinuousAnimation()
        }
    }
    
    private func resetAnimations() {
        // Отменяем текущую анимацию
        animationID = UUID()
        
        // Отключаем анимацию для сброса
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            circleRotation = 0
            waveHeight = 0
            waveProgress = 0
        }
    }
    
    func startContinuousAnimation() {
        stopContinuousAnimation() // Останавливаем предыдущую анимацию если есть
        
        animationID = UUID()
        
        // Сбрасываем состояние
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            circleRotation = 0
            waveProgress = 0
        }
        
        // Запускаем постоянную анимацию
        withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
            self.waveProgress = 1.0
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            self.circleRotation = 360
        }
    }
    
    private func stopContinuousAnimation() {
        continuousAnimationTask?.cancel()
        continuousAnimationTask = nil
        
        // Сбрасываем анимации
        resetAnimations()
    }
    
    // MARK: - Extension Reload Methods
    func reloadExtension(bundleId: String) {
        Task {
            print("🔄 Перезагружаем расширение: \(bundleId)")
            do {
                try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundleId)
                print("✅ Расширение \(bundleId) успешно перезагружено")
            } catch {
                print("❌ Ошибка перезагрузки расширения \(bundleId): \(error.localizedDescription)")
            }
        }
    }
    
    func reloadAdBlocker() {
        reloadExtension(bundleId: "com.surfshield.app.adblocker")
    }
    
    func reloadPrivacy() {
        reloadExtension(bundleId: "com.surfshield.app.privacy")
    }
    
    func reloadBanners() {
        reloadExtension(bundleId: "com.surfshield.app.banners")
    }
    
    func reloadTrackers() {
        reloadExtension(bundleId: "com.surfshield.app.trackers")
    }
    
    func reloadAdvanced() {
        reloadExtension(bundleId: "com.surfshield.app.advanced")
    }
}



// MARK: - View
struct BlockAdsView: View {
    @StateObject private var viewModel = BlockAdsViewModel()
    
    var body: some View {
        content
    }
    

    let id = UUID()
    var content: some View {
        ZStack {
            // Анимированный фон с градиентом
            BackgroundGradient(isHighlight: viewModel.isEnabled)
                .ignoresSafeArea()
            
            // Анимированные частицы на фоне
            ParticlesView()
                .opacity(0.3)
            
            VStack {
                Spacer()
                
                VStack(spacing: 32) {
                    blockAdsButton
//                    testButton
                    // Статус кнопки с лоадером
                    VStack(spacing: 12) {
                        Text(buttonStatusTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(viewModel.isEnabled ? .tm.accentSecondary : .tm.title)
                            .opacity(viewModel.isProcess ? 0.7 : 1.0)
                            .shadow(color: .tm.accentSecondary.opacity(viewModel.isEnabled ? 0.3 : 0), radius: 8)
                        
                        // Красивый лоадер для процесса
                        ProcessLoader()
                            .transition(.scale.combined(with: .opacity))
                            .opacity(viewModel.isProcess ? 1 : 0)
                    }
                    .id(viewModel.animationID)
                }
                
                Spacer()
                
                // Описание приложения
                VStack(spacing: 16) {
                    Text("Blocking advertising")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.tm.accentSecondary)
                    
                    Text("Click the button to activate or deactivate advertising blocking in Safari and App Browser")
                        .font(.body)
                        .foregroundColor(.tm.subTitle.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            if viewModel.isEnabled { viewModel.startContinuousAnimation() }
        }
        .onDisappear {
            viewModel.cancelBlockingTask()
        }
    }

    @ViewBuilder
    var blockAdsButton: some View {
        AnimatedBlockButton(
            isEnabled: viewModel.isEnabled,
            isProcess: viewModel.isProcess,
            waveProgress: viewModel.waveProgress,
            circleRotation: viewModel.circleRotation,
            animationID: viewModel.animationID,
            onTap: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                viewModel.toggleBlocking()
            }
        )
    }
    
    private var buttonStatusTitle: String {
        if viewModel.isProcess {
            return viewModel.isEnabled ? "Disabling..." : "Enabling..."
        } else {
            return viewModel.isEnabled ? "Enabled" : "Disabled"
        }
    }
}

// MARK: - Animated Block Button
struct AnimatedBlockButton: View {
    let isEnabled: Bool
    let isProcess: Bool
    let waveProgress: Double
    let circleRotation: Double
    let animationID: UUID
    let onTap: () -> Void
    
    private let waveSize: CGFloat = 160
    private let waveCount = 6
    private let waveHeight: CGFloat = 2
    
    var body: some View {
        ZStack {
            // Основная кнопка с дугой загрузки
            if isEnabled {
                makeEnabledStateButton()
            } else {
                makeDisabledStateButton()
            }
            
            // Overlay с иконкой и состоянием
            buttonContentOverlay
        }
        .onTapGesture {
            onTap()
        }
        .scaleEffect(isProcess ? 0.94 : 1.0)
        .background {
            if isProcess {
                ForEach(0..<8) { index in
                    ParticleView(index: index, isActive: isProcess)
                        .opacity(0.6)
                }
            }
        }
    }
    
    @ViewBuilder
    private var buttonContentOverlay: some View {
        ZStack {
            // Дополнительное свечение для включенного состояния
            if isEnabled && !isProcess {
                Image(systemName: iconName)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.tm.accent.opacity(0.3))
                    .scaleEffect(2.15)
                    .blur(radius: 20)
            }

                Image(systemName: iconName)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(iconColor)
                    .shadow(color: iconShadow, radius: iconShadowRadius)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.2), value: isProcess)
        }
    }
    
    private var iconName: String {
        return "power"
    }
    
    private var iconColor: Color {
        if isEnabled {
            // Для включенного состояния - белый с легким свечением
            return .white
        } else {
            // Для выключенного состояния - приглушенный белый
            return .white.opacity(0.7)
        }
    }
    
    private var iconShadow: Color {
        if isEnabled {
            // Красивое свечение для включенного состояния
            return .tm.accent
        } else {
            return .clear
        }
    }
    
    private var iconShadowRadius: CGFloat {
        if isEnabled && !isProcess {
            return 20
        } else {
            return 0
        }
    }
    
    private func makeDisabledStateButton() -> some View {
        WaveShape(waveCount: 0, waveHeight: 0, progress: waveProgress)
            .fill(
                LinearGradient(
                    colors: [.tm.container, .tm.container.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 160, height: 160)
            .scaleEffect(isProcess ? 0.94 : 1.0)
    }
    
    private func makeEnabledStateButton() -> some View {
        ForEach(1..<12) { index in
            makeWaveCircle(
                duration: 3 + Double(index) / 4,
                opacity: Double(index) / 20,
                rotationVector: index % 2 == 0,
                colors: [.tm.accentSecondary, .tm.accent]
            )
            .scaleEffect(CGSize(width: 1 - (Double(index) * 0.006), height: 1 - (Double(index) * 0.006)) )
        }
    }
    
    private func makeWaveCircle(duration: Double, opacity: CGFloat, rotationVector: Bool, colors: [Color]) -> some View {
        WaveShape(waveCount: waveCount, waveHeight: waveHeight, progress: waveProgress)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: waveSize, height: waveSize)
            .rotationEffect(.degrees(opacity * 140)) // Сдвиг по часовой стрелке чтобы анимация начиналась не с нулевого положения
            .rotationEffect(.degrees(rotationVector ? -circleRotation : circleRotation))
            .opacity(opacity)
            .animation(.linear(duration: duration).repeatForever(autoreverses: false), value: circleRotation)
            .id(animationID)
    }
}

// MARK: - Custom Shape
// Кастомная волнистая форма
struct WaveShape: Shape {
    let waveCount: Int
    let waveHeight: CGFloat
    let progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let adjustedRadius = radius - waveHeight
        
        // Если progress == 0, рисуем обычный круг
        if progress == 0 {
            path.addArc(
                center: center,
                radius: adjustedRadius,
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
            path.closeSubpath()
            return path
        }
        
        // Начинаем с верхней точки
        let startAngle = -CGFloat.pi / 2
        
        // Рисуем волнистую окружность
        for i in stride(from: 0, through: 360, by: 1) {
            let angle = startAngle + CGFloat(i) * .pi / 180
            let waveOffset = sin(CGFloat(i) * CGFloat(waveCount) * .pi / 180) * waveHeight * CGFloat(progress)
            let currentRadius = adjustedRadius + waveOffset
            
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
        
        // Замыкаем путь
        path.closeSubpath()
        
        return path
    }
}


// MARK: - Custom Loaders

// Лоадер с вращающимися точками
struct RotatingDotsLoader: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                Circle()
                    .fill(.white.opacity(0.9))
                    .frame(width: 3, height: 3)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(getOpacity(for: index))
                    .scaleEffect(getScale(for: index))
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
    
    private func getOpacity(for index: Int) -> Double {
        let progress = (rotation / 360.0).truncatingRemainder(dividingBy: 1.0)
        let dotProgress = (progress * 8 + Double(index)).truncatingRemainder(dividingBy: 8.0)
        return max(0.2, 1.0 - dotProgress / 8.0)
    }
    
    private func getScale(for index: Int) -> Double {
        let progress = (rotation / 360.0).truncatingRemainder(dividingBy: 1.0)
        let dotProgress = (progress * 8 + Double(index)).truncatingRemainder(dividingBy: 8.0)
        return max(0.6, 1.0 - dotProgress / 12.0)
    }
}

// Лоадер с пульсирующими кольцами
struct PulsingRingsLoader: View {
    @State private var scale1: CGFloat = 0.5
    @State private var scale2: CGFloat = 0.5
    @State private var scale3: CGFloat = 0.5
    @State private var opacity1: Double = 1.0
    @State private var opacity2: Double = 1.0
    @State private var opacity3: Double = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.8), lineWidth: 1.5)
                .frame(width: 20, height: 20)
                .scaleEffect(scale1)
                .opacity(opacity1)
            
            Circle()
                .stroke(.white.opacity(0.6), lineWidth: 1.2)
                .frame(width: 20, height: 20)
                .scaleEffect(scale2)
                .opacity(opacity2)
            
            Circle()
                .stroke(.white.opacity(0.4), lineWidth: 1.0)
                .frame(width: 20, height: 20)
                .scaleEffect(scale3)
                .opacity(opacity3)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
            scale1 = 1.8
            opacity1 = 0.0
        }
        
        withAnimation(.easeInOut(duration: 1.2).repeatForever().delay(0.4)) {
            scale2 = 1.8
            opacity2 = 0.0
        }
        
        withAnimation(.easeInOut(duration: 1.2).repeatForever().delay(0.8)) {
            scale3 = 1.8
            opacity3 = 0.0
        }
    }
}

// Лоадер со спиральной анимацией
struct SpiralLoader: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(.white.opacity(0.9))
                    .frame(width: 2, height: 8)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .opacity(getOpacity(for: index))
                    .scaleEffect(getScale(for: index))
            }
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
    
    private func getOpacity(for index: Int) -> Double {
        let progress = (rotation / 360.0).truncatingRemainder(dividingBy: 1.0)
        let barProgress = (progress * 12 + Double(index)).truncatingRemainder(dividingBy: 12.0)
        return max(0.1, 1.0 - barProgress / 12.0)
    }
    
    private func getScale(for index: Int) -> Double {
        let progress = (rotation / 360.0).truncatingRemainder(dividingBy: 1.0)
        let barProgress = (progress * 12 + Double(index)).truncatingRemainder(dividingBy: 12.0)
        return max(0.4, 1.0 - barProgress / 24.0)
    }
}

// Современный минималистичный лоадер
struct ModernLoader: View {
    @State private var rotation: Double = 0
    @State private var trimEnd: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Фоновый круг
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            // Анимированная дуга
            Circle()
                .trim(from: 0, to: trimEnd)
                .stroke(.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotation)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: trimEnd)
        }
        .onAppear {
            rotation = 360
            trimEnd = 0.1
        }
    }
}

// MARK: - Process Loader
struct ProcessLoader: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.tm.accentSecondary.opacity(0.8))
                    .frame(width: 6, height: 6)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.4)
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


#Preview {
    BlockAdsView()
}

struct ParticlesView: View {
    @State private var animation = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { index in
                Circle()
                    .fill(.tm.accentTertiary.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true),
                        value: animation
                    )
            }
        }
        .onAppear {
            animation.toggle()
        }
    }
}

// MARK: - Individual Particle
struct ParticleView: View {
    let index: Int
    let isActive: Bool
    
    @State private var animation = false
    
    var body: some View {
        Circle()
            .fill(.tm.accentSecondary)
            .frame(width: 4, height: 4)
            .scaleEffect(animation ? 0.1 : 1.0)
            .opacity(animation ? 0 : 0.8)
            .position(
                x: 80 + cos(Double(index) * .pi / 4) * 100,
                y: 80 + sin(Double(index) * .pi / 4) * 100
            )
            .animation(
                .easeOut(duration: 1.5)
                .repeatForever(autoreverses: false)
                .delay(Double(index) * 0.1),
                value: animation
            )
            .onAppear {
                if isActive {
                    animation.toggle()
                }
            }
    }
}

