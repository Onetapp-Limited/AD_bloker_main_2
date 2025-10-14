import SwiftUI

struct OnboardingView: View {
    @State private var pageIndex = 0
    @State private var isScaleAnimating = false
    @State private var needShowMainContent = false
    @State private var stringsOffset: CGFloat = 0
    @State private var isGoingForward = true
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentState: AppState
    
    private let onboardingItems: [OnboardingItemModel] = [
        OnboardingItemModel(
            id: 0,
            title: "Welcome to NetFlow",
            subtitle: "Your enhanced browsing companion",
            description: "Experience faster loading and a cleaner web by eliminating digital clutter",
            icon: "hand.raised.fill",
            color: .tm.accent
        ),
        OnboardingItemModel(
            id: 1,
            title: "Private Navigation",
            subtitle: "Browse the web on your terms",
            description: "Our integrated browser prioritizes your privacy and monitors data usage efficiently",
            icon: "magnifyingglass.circle.fill",
            color: .tm.accentSecondary
        ),
        OnboardingItemModel(
            id: 2,
            title: "Activity Insights",
            subtitle: "See where your data goes",
            description: "Visualize network requests and analyze traffic patterns for better control",
            icon: "waveform.path.ecg",
            color: .tm.accentTertiary
        ),
        OnboardingItemModel(
            id: 3,
            title: "Optimization Complete",
            subtitle: "Unlock a smoother internet experience",
            description: "Set your preferences and start enjoying a more streamlined and private connection",
            icon: "sparkles",
            color: .tm.success
        )
    ]
    
    var body: some View {
        ZStack {
            modernBackground
                .ignoresSafeArea()
            
            FloatingElementsView()
                .opacity(0.3)
            
            VStack(spacing: 0) {
                currentPageItemView
                    .padding(.bottom, 60)
                
                itemIndicator
                
                actionsButtonView
            }
        }
        .onAppear {
            startDefaultAnimation()
        }
    }
    
    @ViewBuilder
    private var modernBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    onboardingItems[pageIndex].color.opacity(0.8),
                    onboardingItems[pageIndex].color.opacity(0.4),
                    .tm.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 0.8), value: pageIndex)
            
            Circle()
                .fill(onboardingItems[pageIndex].color.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .scaleEffect(isScaleAnimating ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isScaleAnimating)
            
            Circle()
                .fill(onboardingItems[pageIndex].color.opacity(0.05))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: 300)
                .scaleEffect(isScaleAnimating ? 0.8 : 1.2)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5), value: isScaleAnimating)
        }
        .background(Color.background)
    }
    
    @ViewBuilder
    private var currentPageItemView: some View {
        VStack(spacing: 60) {
            Spacer()
            
            mainIcon
            Spacer()
            VStack(spacing: 16) {
                Text(onboardingItems[pageIndex].title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.tm.title)
                    .multilineTextAlignment(.center)
                
                Text(onboardingItems[pageIndex].subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.tm.subTitle)
                    .multilineTextAlignment(.center)
                
                Text(onboardingItems[pageIndex].description)
                    .font(.body)
                    .foregroundStyle(.tm.subTitle.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .animation(.easeInOut(duration: 0.5), value: pageIndex)
            .id(pageIndex)
            .transition(
                AnyTransition.asymmetric(
                    insertion: isGoingForward ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity),
                    removal: isGoingForward ? .move(edge: .leading).combined(with: .opacity) : .move(edge: .trailing).combined(with: .opacity)
                )
            )
        }
    }
    
    @ViewBuilder
    private var mainIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            onboardingItems[pageIndex].color.opacity(0.3),
                            onboardingItems[pageIndex].color.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(isScaleAnimating ? 1.3 : 1.0)
                .opacity(isScaleAnimating ? 0.4 : 0.7)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isScaleAnimating)
            
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                onboardingItems[pageIndex].color.opacity(0.6),
                                onboardingItems[pageIndex].color.opacity(0.2),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                    .scaleEffect(isScaleAnimating ? 1.1 : 0.9)
                    .opacity(isScaleAnimating ? 0.3 : 0.6)
                    .animation(
                        .easeInOut(duration: 2.5 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: isScaleAnimating
                    )
            }
            
            Image(systemName: onboardingItems[pageIndex].icon)
                .frame(width: 45, height: 45, alignment: .center)
                .font(.system(size: 45, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            onboardingItems[pageIndex].color,
                            .white.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isScaleAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isScaleAnimating)
        }
        .opacity(needShowMainContent ? 1 : 0)
        .scaleEffect(needShowMainContent ? 1 : 0.9)
        .animation(.easeOut(duration: 0.6), value: needShowMainContent)
    }
    
    
    @ViewBuilder
    private var itemIndicator: some View {
        HStack(spacing: 12) {
            ForEach(0..<onboardingItems.count, id: \.self) { index in
                Circle()
                    .fill(
                        index == pageIndex 
                        ? LinearGradient(
                            colors: [
                                onboardingItems[index].color,
                                onboardingItems[index].color.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                .tm.subTitle.opacity(0.3),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: index == pageIndex ? 12 : 8, height: index == pageIndex ? 12 : 8)
                    .scaleEffect(index == pageIndex ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pageIndex)
            }
        }
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    private var actionsButtonView: some View {
        HStack(spacing: 16) {
            if pageIndex > 0 {
                Button("Back") {
                    isGoingForward = false
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        
                        pageIndex = max(0, pageIndex - 1)
                        resetCurrentAnimations()
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            Button(pageIndex == onboardingItems.count - 1 ? "Start" : "Next") {
                if pageIndex == onboardingItems.count - 1 {
                    currentState.onboardingCompleted()
                } else {
                    isGoingForward = true
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        pageIndex = min(onboardingItems.count - 1, pageIndex + 1)
                        resetCurrentAnimations()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(color: onboardingItems[pageIndex].color))
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }
    
    private func startDefaultAnimation() {
        stringsOffset = UIScreen.main.bounds.width
        
        withAnimation(.easeOut(duration: 0.5)) {
            stringsOffset = 0
            needShowMainContent = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isScaleAnimating = true
        }
    }
    
    private func resetCurrentAnimations() {
        withAnimation(.easeInOut(duration: 0.4)) {
            stringsOffset = -UIScreen.main.bounds.width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            stringsOffset = UIScreen.main.bounds.width
            
            withAnimation(.easeInOut(duration: 0.4)) {
                stringsOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isScaleAnimating = true
            }
        }
    }
}
