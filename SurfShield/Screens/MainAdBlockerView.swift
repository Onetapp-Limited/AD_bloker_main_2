import SwiftUI
import Combine
import SafariServices

/**
 Основной экран для управления функцией оптимизации контента.
 */
struct MainAdBlockerView: View {
    @StateObject private var screenModel = MainAdBlockerViewModel()
    @State private var isShowingSettingsSheet: Bool = false
    
    var body: some View {
        mainContentArea
            .sheet(isPresented: $isShowingSettingsSheet) {
                 SettingsMainView()
            }
    }
    
    var mainContentArea: some View {
        VStack {
            ZStack {
                MainGradient(isHighlight: screenModel.isEnabled)
                    .ignoresSafeArea()
                
                FloatingElementsView()
                    .opacity(0.3)
                
                VStack {
                    HStack {
                        Spacer()
                        settingsGearButton
                            .padding(.top, 15)
                            .padding(.trailing, 25)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 40) {
                        optimizationToggleButton
                        
                        VStack(spacing: 8) {
                            Text(statusMessageForButton)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(screenModel.isEnabled ? .tm.accent : .tm.title)
                                .opacity(screenModel.isProcess ? 0.8 : 1.0)
                                .shadow(color: .tm.accentSecondary.opacity(screenModel.isEnabled ? 0.4 : 0), radius: 10)
                            
                            ProgressIndicatorView()
                                .transition(.scale.combined(with: .opacity))
                                .opacity(screenModel.isProcess ? 1 : 0)
                        }
                        .id(screenModel.animationID)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Online Content Filter")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundStyle(.tm.accentSecondary)
                        
                        Text("Tap the central control to seamlessly activate or deactivate content optimization in your Safari web browser.")
                            .font(.subheadline)
                            .foregroundColor(.tm.subTitle.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            if screenModel.isEnabled { screenModel.startContinuousAnimation() }
        }
        .onDisappear {
            screenModel.cancelBlockingTask()
        }
    }
    
    @ViewBuilder
    var optimizationToggleButton: some View {
        AnimatedToggleView(
            isActive: screenModel.isEnabled,
            isWorking: screenModel.isProcess,
            waveFillProgress: screenModel.waveProgress,
            circleRotationAngle: screenModel.circleRotation,
            uniqueAnimationID: screenModel.animationID,
            onActivationTap: {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                screenModel.toggleBlocking()
            }
        )
    }
    
    @ViewBuilder
    var settingsGearButton: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
            isShowingSettingsSheet = true
        }) {
            Image(systemName: "slider.horizontal.3")
                .font(.title)
                .foregroundStyle(screenModel.isEnabled ? .tm.accentSecondary : .tm.calm)
                .contentShape(Rectangle())
        }
    }
    
    private var statusMessageForButton: String {
        if screenModel.isProcess {
            return screenModel.isEnabled ? "Deactivating..." : "Activating..."
        } else {
            return screenModel.isEnabled ? "Active" : "Inactive"
        }
    }
}
