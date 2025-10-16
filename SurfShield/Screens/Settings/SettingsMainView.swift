import SwiftUI
import StoreKit

struct SettingsMainView: View {
    
    @StateObject var viewModel = SettingsMainViewModel()
    
    @State private var isInfoExpanded = false
    
    @Environment(\.requestReview) var requestReview

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Configuration")
                .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var content: some View {
        ZStack {
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
            
            MainGradient()
                .ignoresSafeArea(.all)
                .opacity(0.7)

            ScrollView {
                LazyVStack(spacing: Layout.Padding.large) {
                    optimizationMetricsSection
                    contentFilterSection
                    interfaceSection
                    infoSupportSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Layout.Padding.mediumExt)
                .padding(.top, Layout.Padding.mediumExt)
            }
        }
    }

    var optimizationMetricsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Metrics")
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
            
            if isInfoExpanded {
                VStack(alignment: .leading, spacing: .regular) {
                    Text("Metrics display resource optimization in the integrated browser:")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.tm.subTitle.opacity(0.8))
                    
                    VStack(alignment: .leading, spacing: .regular) {
                        InfoStatisticRow(
                            iconColor: .tm.accent,
                            title: "Optimized - ",
                            text: "Total resources filtered to improve loading speed"
                        )
                        
                        InfoStatisticRow(
                            iconColor: .tm.accentSecondary,
                            title: "Loaded - ",
                            text: "Essential resources successfully loaded (images, scripts, styles)"
                        )
                        
                        InfoStatisticRow(
                            iconColor: .tm.success,
                            title: "Ratio - ",
                            text: "Percentage of content optimization for faster surfing"
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
            
            Divider()
                .background(Color.tm.subTitle.opacity(0.2))
                .padding(.horizontal, Layout.Padding.medium)
            
            StatisticResultsRow(
                icon: "sparkles",
                iconColor: .tm.accent,
                title: "Optimized",
                subtitle: "Resources filtered",
                value: "\(viewModel.statisticsData.blockedCount.formatted())"
            )
            
            Divider()
                .background(Color.tm.subTitle.opacity(0.2))
                .padding(.horizontal, Layout.Padding.medium)
            
            StatisticResultsRow(
                icon: "arrow.down.circle.fill",
                iconColor: .tm.accentSecondary,
                title: "Loaded",
                subtitle: "Essential content",
                value: "\(viewModel.statisticsData.totalLoadedResources.formatted())"
            )
            
            Divider()
                .background(Color.tm.subTitle.opacity(0.2))
                .padding(.horizontal, Layout.Padding.medium)
            
            StatisticResultsRow(
                icon: "speedometer",
                iconColor: .tm.success,
                title: "Optimization Ratio",
                subtitle: "Filter percentage",
                value: "\(Int(viewModel.statisticsData.blockedPercentage))%"
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
    
    var contentFilterSection: some View {
        NewDesignSectionMainCard(
            title: "Content Filtering",
            subtitle: "Optimize your browsing content",
            icon: "slider.horizontal.3",
            accentColor: .calmSecondary
        ) {
            VStack(spacing: Layout.Padding.medium) {
                ToggleMainRow(
                    title: "Enhanced Optimization",
                    subtitle: "Comprehensive content processing",
                    icon: "wand.and.stars",
                    isOn: $viewModel.globalAppSettings.advancedProtection,
                    accentColor: .calmSecondary
                )
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ToggleMainRow(
                    title: "Ad Space Removal",
                    subtitle: "Clear visual clutter from pages",
                    icon: "rectangle.compress.vertical",
                    isOn: $viewModel.globalAppSettings.blockAds,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.globalAppSettings.advancedProtection
                )
                
                ToggleMainRow(
                    title: "Standard Filtering",
                    subtitle: "Core resource management",
                    icon: "line.3.horizontal.decrease",
                    isOn: $viewModel.globalAppSettings.basicBlock,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.globalAppSettings.advancedProtection
                )
                
                ToggleMainRow(
                    title: "Pop-up Management",
                    subtitle: "Control intrusive new windows",
                    icon: "square.on.square",
                    isOn: $viewModel.globalAppSettings.blockPopups,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.globalAppSettings.advancedProtection
                )
                
                ToggleMainRow(
                    title: "Network Security Check",
                    subtitle: "Verify resource integrity",
                    icon: "link.icloud.fill",
                    isOn: $viewModel.globalAppSettings.security,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.globalAppSettings.advancedProtection
                )
                
                ToggleMainRow(
                    title: "Telemetry Opt-Out",
                    subtitle: "Limit data collection scripts",
                    icon: "eye.slash.fill",
                    isOn: $viewModel.globalAppSettings.blockTrackers,
                    accentColor: .calmSecondary,
                    isDisabled: !viewModel.globalAppSettings.advancedProtection
                )
            }
        }
    }
    
    var interfaceSection: some View {
        NewDesignSectionMainCard(
            title: "Browser & UX",
            subtitle: "Personalize your application experience",
            icon: "square.grid.2x2",
            accentColor: .calm
        ) {
            VStack(spacing: Layout.Padding.medium) {
                ToggleMainRow(
                    title: "Session History",
                    subtitle: "Retain previous browsing data",
                    icon: "clock.fill",
                    isOn: $viewModel.globalAppSettings.enableBrowserHistory,
                    accentColor: .calm
                )
                
                if !viewModel.globalAppSettings.enableBrowserHistory {
                    VStack(alignment: .leading, spacing: Layout.Padding.small) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.calm)
                                .frame(width: 20)
                            
                            Text("Homepage URL")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.tm.title)
                            
                            Spacer()
                        }
                        
                        TextField("Set the default starting web address", text: $viewModel.globalAppSettings.startPage)
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
                
                ToggleMainRow(
                    title: "Local Storage",
                    subtitle: "Enable website data persistence",
                    icon: "internaldrive.fill",
                    isOn: $viewModel.globalAppSettings.enableCookies,
                    accentColor: .calm
                )
                
                ToggleMainRow(
                    title: "Appearance Mode",
                    subtitle: "Toggle night mode for app interface",
                    icon: "sun.max.fill",
                    isOn: $viewModel.globalAppSettings.enableBrowserDarkMode,
                    accentColor: .calm
                )
            }
        }
    }
    
    var infoSupportSection: some View {
        NewDesignSectionMainCard(
            title: "Information & Help",
            subtitle: "App details and resources",
            icon: "questionmark.circle",
            accentColor: .tm.accentTertiary
        ) {
            VStack(spacing: Layout.Padding.regular) {
                PrivacyRow(
                    title: "Leave a Review",
                    subtitle: "Share your feedback with us",
                    icon: "heart.fill",
                    accentColor: .tm.success
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    requestReview() 
                }
                
                PrivacyRow(
                    title: "Technical Support",
                    subtitle: "Request assistance or report issues",
                    icon: "lifepreserver.fill",
                    accentColor: .tm.accent
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                PrivacyRow(
                    title: "Data Policy",
                    subtitle: "Learn how your information is handled",
                    icon: "doc.text.magnifyingglass",
                    accentColor: .tm.accentSecondary
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: Layout.Padding.small) {
                        Text("Client Version 1.0.0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.tm.title.opacity(0.8))
                        
                        Text("Release Build 2025.1")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.tm.subTitle.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("🚀")
                        .font(.system(size: 20))
                }
                .padding(.top, Layout.Padding.regular)
            }
        }
    }
}
