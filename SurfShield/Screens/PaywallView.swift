//
//  PaywallView.swift
//  SufrShield
//
//  Created by Артур Кулик on 07.09.2025.
//

import SwiftUI

// MARK: - Models
struct SubscriptionPlan {
    let id: String
    let title: String
    let description: String
    let price: String
    let period: String
    let isPopular: Bool
    let features: [String]
    let discount: String?
}

// MARK: - Mock Data
extension SubscriptionPlan {
    static let mockPlans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: "weekly",
            title: "Weekly",
            description: "Trial period",
            price: "₽99",
            period: "/week",
            isPopular: false,
            features: [
                "Smart ad blocking",
                "Tracker protection",
                "Fast browser"
            ],
            discount: "Try first"
        ),
        SubscriptionPlan(
            id: "monthly",
            title: "Monthly",
            description: "Basic plan",
            price: "₽299",
            period: "/month",
            isPopular: false,
            features: [
                "Smart ad blocking",
                "Tracker protection",
                "Fast browser"
            ],
            discount: nil
        ),
        SubscriptionPlan(
            id: "yearly",
            title: "Yearly",
            description: "Popular",
            price: "₽1,999",
            period: "/year",
            isPopular: true,
            features: [
                "Advanced ad blocking",
                "Tracker protection",
                "Fast browser",
                "Synchronization"
            ],
            discount: "Save 44%"
        )
    ]
}

// MARK: - Components
struct SubscriptionCard: View {
    let plan: SubscriptionPlan
    @Binding var selectedPlan: String
    
    var isSelected: Bool {
        plan.id == selectedPlan
    }
    
    var body: some View {
        HStack {
            // Header
//            VStack(alignment: .leading, spacing: Layout.Padding.small) {
                Text(plan.title)
                    .font(.headline)
                    .foregroundColor(.tm.title)
//            }
            
            Spacer()
            
            // Price
            HStack(alignment: .center, spacing: .smallExt) {
                    Text(plan.price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.tm.title)
                    
                    Text(plan.period)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.tm.title.opacity(0.5))
                }
        }
        .padding(Layout.Padding.medium)
        .background(
            RoundedRectangle(cornerRadius: Layout.Radius.medium)
                .fill(.tm.title.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.Radius.medium)
                        .stroke(
                            isSelected ? 
                            LinearGradient(
                                gradient: Gradient(colors: [.tm.accentSecondary, .tm.success]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : 
                            LinearGradient(
                                gradient: Gradient(colors: [.clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onTapGesture {
            selectedPlan = plan.id
        }
    }
}


struct PricingView: View {
    @Binding var selectedPlan: String
    let plans: [SubscriptionPlan]
    
    var body: some View {
        VStack(spacing: .medium) {
            ForEach(plans, id: \.id) { plan in
                SubscriptionCard(plan: plan, selectedPlan: $selectedPlan)
            }
        }
    }
}

// MARK: - Main PaywallView
struct PaywallView: View {
    @State private var selectedPlan: String = "monthly"
    @Environment(\.dismiss) private var dismiss
    
    private let plans = SubscriptionPlan.mockPlans
    
    var body: some View {
        NavigationView {
            VStack(spacing: .extraLarge) {
                // Header
                VStack(spacing: Layout.Padding.regular) {
                    Text("SurfShield Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.tm.title)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: Layout.Padding.small) {
                        Text("Maximum ad protection")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.tm.title)
                            .multilineTextAlignment(.center)
                        
                        Text("Intelligent ad blocking, tracker protection and faster page loading")
                            .font(.subheadline)
                            .foregroundColor(.tm.title)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                .padding(.top, Layout.Padding.large)
                
                Spacer()
                // Pricing
                PricingView(selectedPlan: $selectedPlan, plans: plans)
                
                Spacer()
                
                // Subscribe Button
                Button(action: subscribeAction) {
                    Text("Subscribe")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Layout.Padding.medium)
                        .background(.tm.accentSecondary.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: Layout.Radius.regular))
                }
                .padding(.horizontal, Layout.Padding.medium)
                
                // Terms
                VStack(spacing: Layout.Padding.small) {
                    Text("Subscription renews automatically")
                        .font(.callout)
                        .foregroundColor(.tm.title.opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: Layout.Padding.small) {
                        Button("Terms") {
                            // Handle terms
                        }
                        .font(.callout)
                        .foregroundColor(.tm.accent)
                        
                        Text("•")
                            .font(.callout)
                            .foregroundColor(.tm.subTitle)
                        
                        Button("Privacy") {
                            // Handle privacy
                        }
                        .font(.callout)
                        .foregroundColor(.tm.accent)
                    }
                }
                .padding(.bottom, Layout.Padding.medium)
            }
            .padding(.horizontal, Layout.Padding.medium)
            .background(
                ZStack {
                    // Первый радиальный градиент - верхний левый
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .tm.accentSecondary.opacity(0.6),
                            .tm.accentSecondary.opacity(0.3),
                            .tm.accentSecondary.opacity(0.1)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 600
                    )
                    
                    // Второй радиальный градиент - нижний правый
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .tm.success.opacity(0.5),
                            .tm.success.opacity(0.25),
                            .tm.success.opacity(0.08)
                        ]),
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 700
                    )
                    
                    // Третий радиальный градиент - центр
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .tm.accentSecondary.opacity(0.4),
                            .tm.success.opacity(0.3),
                            .tm.accentSecondary.opacity(0.15)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 500
                    )
                    
                    // Базовый цвет фона - более светлый
                    Color.tm.background.opacity(0.1)
                }
                    .ignoresSafeArea(.all)
                    .background(Color.tm.background)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.bold)
                            .foregroundStyle(.background.opacity(0.6))
                    }
                    .foregroundColor(.tm.accent)
                }
            }
        }
    }
    
    private func subscribeAction() {
        // Handle subscription logic
        print("Subscription to plan: \(selectedPlan)")
    }
}

#Preview {
    PaywallView()
}
