//
//  SettingsView.swift
//  SufrShield
//
//  Created by Артур Кулик on 26.08.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    
    // Statistics
    @State private var isInfoExpanded = false
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var content: some View {
        ZStack {
            // Таинственный темный фон
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.tm.container.opacity(0.1),
                    Color.black.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            BackgroundGradient()
                .ignoresSafeArea(.all)
                .opacity(0.7)

            ScrollView {
                LazyVStack(spacing: Layout.Padding.large) {
                    statisticsSection
                    adBlockerSection
                    browserSection
                    aboutSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Layout.Padding.mediumExt)
                .padding(.top, Layout.Padding.mediumExt)
            }
        }
    }

    var statisticsSection: some View {
        VStack(spacing: 0) {
            // Заголовок внутри секции
            HStack {
                Text("Browser Statistics")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.tm.title)
                
                Spacer()
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isInfoExpanded.toggle()
                    }
                }) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.tm.subTitle)
                }
            }
            .padding(.horizontal, Layout.Padding.medium)
            .padding(.vertical, Layout.Padding.medium)
            
            // Выпадающая информация
            if isInfoExpanded {
                VStack(alignment: .leading, spacing: .regular) {
                    Text("This statistics shows data about the app browser:")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.tm.subTitle.opacity(0.8))
                    
                    VStack(alignment: .leading, spacing: .regular) {
                        StatisticsInfoRow(
                            iconColor: .tm.accent,
                            title: "Blocked - ",
                            text: "number of blocked advertising and tracking resources"
                        )
                        
                        StatisticsInfoRow(
                            iconColor: .tm.accentSecondary,
                            title: "Allowed - ",
                            text: "number of allowed resources (images, styles, scripts)"
                        )
                        
                        StatisticsInfoRow(
                            iconColor: .tm.success,
                            title: "Efficiency - ",
                            text: "Efficiency - percentage of blocked resources from total amount"
                        )
                    }
                }
                .padding(.horizontal, Layout.Padding.medium)
                .padding(.bottom, Layout.Padding.medium)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
            
            // Разделитель между заголовком и строчками
            Divider()
                .background(Color.tm.subTitle.opacity(0.2))
                .padding(.horizontal, Layout.Padding.medium)
            
            // Строка 1: Заблокированные ресурсы
            StatisticsRow(
                icon: "shield.slash.fill",
                iconColor: .tm.accent,
                title: "Blocked",
                subtitle: "Blocked resources",
                value: "\(viewModel.resourceStatistics.blockedCount.formatted())"
            )
            
            // Разделитель
            Divider()
                .background(Color.tm.subTitle.opacity(0.2))
                .padding(.horizontal, Layout.Padding.medium)
            
            // Строка 2: Разрешенные ресурсы
            StatisticsRow(
                icon: "checkmark.shield.fill",
                iconColor: .tm.accentSecondary,
                title: "Allowed",
                subtitle: "Allowed resources",
                value: "\(viewModel.resourceStatistics.totalLoadedResources.formatted())"
            )
            
            // Разделитель
            Divider()
                .background(Color.tm.subTitle.opacity(0.2))
                .padding(.horizontal, Layout.Padding.medium)
            
            // Строка 3: Эффективность
            StatisticsRow(
                icon: "chart.pie.fill",
                iconColor: .tm.success,
                title: "Efficiency",
                subtitle: "Block percentage",
                value: "\(Int(viewModel.resourceStatistics.blockedPercentage))%"
            )
        }
        .clipped()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tm.container.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.tm.accent.opacity(0.1),
                                    Color.tm.accentSecondary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        )
    }
    
    var adBlockerSection: some View {
        ModernSectionCard(
            title: "Protection & Blocking",
            subtitle: "Content blocking management",
            icon: "shield.checkered",
            accentColor: .calmSecondary
        ) {
            VStack(spacing: Layout.Padding.medium) {
                ModernToggleRow(
                    title: "Advanced Protection",
                    subtitle: "Enhanced security features",
                    icon: "shield.lefthalf.filled",
                    isOn: $viewModel.appSettings.advancedProtection,
                    accentColor: .calmSecondary
                )
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ModernToggleRow(
                    title: "Banner Blocking",
                    subtitle: "Remove advertising banners",
                    icon: "rectangle.slash",
                    isOn: $viewModel.appSettings.blockAds,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.appSettings.advancedProtection
                )
                
                ModernToggleRow(
                    title: "Basic Protection",
                    subtitle: "Essential security measures",
                    icon: "shield",
                    isOn: $viewModel.appSettings.basicBlock,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.appSettings.advancedProtection
                )
                
                ModernToggleRow(
                    title: "Privacy Guard",
                    subtitle: "Protect personal information",
                    icon: "hand.raised.fill",
                    isOn: $viewModel.appSettings.blockPopups,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.appSettings.advancedProtection
                )
                
                ModernToggleRow(
                    title: "Security Shield",
                    subtitle: "Advanced threat protection",
                    icon: "lock.shield",
                    isOn: $viewModel.appSettings.security,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.appSettings.advancedProtection
                )
                
                ModernToggleRow(
                    title: "Tracker Blocker",
                    subtitle: "Block tracking scripts",
                    icon: "eye.slash",
                    isOn: $viewModel.appSettings.blockTrackers,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.appSettings.advancedProtection
                )
            }
        }
    }
    
    var browserSection: some View {
        ModernSectionCard(
            title: "Browser & Interface",
            subtitle: "Application behavior settings",
            icon: "safari",
            accentColor: .calm
        ) {
            VStack(spacing: Layout.Padding.medium) {
//                ModernToggleRow(
//                    title: "JavaScript",
//                    subtitle: "Script execution",
//                    icon: "curlybraces",
//                    isOn: $enableJavaScript,
//                    accentColor: .calm
//                )
                
                ModernToggleRow(
                    title: "Browser History",
                    subtitle: "Save previous session",
                    icon: "clock.arrow.circlepath",
                    isOn: $viewModel.appSettings.enableBrowserHistory,
                    accentColor: .calm
                )
                
                // Start page input - показывается только если история выключена
                if !viewModel.appSettings.enableBrowserHistory {
                    VStack(alignment: .leading, spacing: Layout.Padding.small) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.calm)
                                .frame(width: 20)
                            
                            Text("Start Page")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.tm.title)
                            
                            Spacer()
                        }
                        
                        TextField("Enter start page URL", text: $viewModel.appSettings.startPage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 14))
                            .padding(.leading, 24)
                    }
                    .padding(.vertical, Layout.Padding.small)
                    .padding(.horizontal, Layout.Padding.medium)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.tm.container.opacity(0.3))
                    )
                }
                
                ModernToggleRow(
                    title: "Cookies",
                    subtitle: "Website data storage",
                    icon: "externaldrive.connected.to.line.below",
                    isOn: $viewModel.appSettings.enableCookies,
                    accentColor: .calm
                )
                
                ModernToggleRow(
                    title: "Dark Theme",
                    subtitle: "Night mode browser",
                    icon: "moon.fill",
                    isOn: $viewModel.appSettings.enableBrowserDarkMode,
                    accentColor: .calm
                )
//                
//                Divider()
//                    .background(Color.tm.subTitle.opacity(0.2))
//                
//                ModernToggleRow(
//                    title: "Auto-Clear Cache",
//                    subtitle: "Clear cache on exit",
//                    icon: "trash.circle",
//                    isOn: $clearCacheOnExit,
//                    accentColor: .calm
//                )
//                
//                ModernToggleRow(
//                    title: "Notifications",
//                    subtitle: "Push notifications",
//                    icon: "bell.fill",
//                    isOn: $showNotifications,
//                    accentColor: .calm
//                )
            }
        }
    }
    
    var aboutSection: some View {
        ModernSectionCard(
            title: "About & Support",
            subtitle: "App information and help",
            icon: "info.circle",
            accentColor: .tm.accentTertiary
        ) {
            VStack(spacing: Layout.Padding.regular) {
                ActionRow(
                    title: "Rate App",
                    subtitle: "Share your experience",
                    icon: "star.fill",
                    accentColor: .tm.success
                ) {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                
                ActionRow(
                    title: "Contact Support",
                    subtitle: "Get help and assistance",
                    icon: "envelope.fill",
                    accentColor: .tm.accent
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ActionRow(
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    icon: "hand.raised.fill",
                    accentColor: .tm.accentSecondary
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: Layout.Padding.small) {
                        Text("Version 1.0.0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.tm.title.opacity(0.8))
                        
                        Text("Build 2025.1")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.tm.subTitle.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("🛡️")
                        .font(.system(size: 20))
                }
                .padding(.top, Layout.Padding.regular)
            }
        }
    }
}

// MARK: - Statistics Components

struct StatisticsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String
    
    var body: some View {
        HStack(spacing: Layout.Padding.medium) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.tm.title)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.tm.subTitle.opacity(0.7))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.tm.subTitle)
        }
        .padding(.horizontal, Layout.Padding.medium)
        .padding(.vertical, Layout.Padding.medium)
    }
}

struct StatisticsInfoRow: View {
    let iconColor: Color
    let title: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: .smallExt) {
            Text("•")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(iconColor)

            
            Text(title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.tm.title)
            +
            Text(text)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.tm.subTitle.opacity(0.7))
        }
    }
}

// MARK: - Modern Components

struct ModernSectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let content: Content
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        accentColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: Layout.Padding.regularExt) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            accentColor.opacity(0.15)
                        )
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: accentColor.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: Layout.Padding.small) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.tm.title)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tm.subTitle.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.bottom, Layout.Padding.mediumExt)
            
            // Content
            VStack(spacing: 0) {
                content
            }
            .padding(Layout.Padding.mediumExt)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.tm.container.opacity(1.0),
                                Color.tm.container.opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(0.5),
                        radius: 35,
                        x: 0,
                        y: 18
                    )
                    .shadow(
                        color: accentColor.opacity(0.1),
                        radius: 45,
                        x: 0,
                        y: 25
                    )
            )
            .opacity(0.8)
        }
        .padding(.horizontal, Layout.Padding.smallExt)
    }
}

struct ModernToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    let accentColor: Color
    let isDisabled: Bool
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        isOn: Binding<Bool>,
        accentColor: Color,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self._isOn = isOn
        self.accentColor = accentColor
        self.isDisabled = isDisabled
    }
    
    var body: some View {
//        HStack(spacing: Layout.Padding.medium) {
        HStack(spacing: .zero) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        .white.opacity(0.1)
                    )
                    .frame(width: 46, height: 46)
                    .shadow(
                        color: accentColor.opacity(isDisabled ? 0.1 : 0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(isDisabled ? .tm.subTitle.opacity(0.4) : accentColor)
            }
            .padding(.trailing, .medium)
            
            // Text content
            VStack(alignment: .leading, spacing: Layout.Padding.small) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isDisabled ? .tm.title.opacity(0.5) : .tm.title)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(isDisabled ? .tm.subTitle.opacity(0.4) : .tm.subTitle.opacity(0.7))
            }
            
            Spacer()
            
            // Custom Toggle
            ModernToggle(isOn: $isOn, accentColor: accentColor, isDisabled: isDisabled)
        }
        .padding(.vertical, Layout.Padding.smallExt)
        .contentShape(Rectangle())
                        .onTapGesture {
            if !isDisabled {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

struct ModernToggle: View {
    @Binding var isOn: Bool
    let accentColor: Color
    let isDisabled: Bool
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isOn && !isDisabled ?
                    accentColor.opacity(0.8) :
                            .title.opacity(0.2)
                )
                .frame(width: 50, height: 30)
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            
            // Thumb
            Circle()
                .fill(Color.white)
                .frame(width: 26, height: 26)
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                .offset(x: isOn ? 10 : -10)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Additional Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Layout.Padding.regular) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(
                        color: color.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: Layout.Padding.small) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.tm.title)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tm.subTitle.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.Padding.medium)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tm.container.opacity(0.8))
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
    }
}

struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Padding.medium) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(accentColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: Layout.Padding.small) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.tm.title)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.tm.subTitle.opacity(0.7))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.tm.subTitle.opacity(0.5))
            }
            .padding(.vertical, Layout.Padding.smallExt)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
