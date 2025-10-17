import SwiftUI

enum SubscriptionPlan {
    case weekly
}

struct PaywallView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: PaywallViewModel

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: PaywallViewModel(isPresented: isPresented))
    }

    var body: some View {
        ZStack {
            Color.tm.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                PaywallHeaderView()
                    .padding(.top, 60)
                
                PaywallIconsBlockView()
                    .padding(.top, 20)
                
                PaywallFeaturesTagView()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                VStack(spacing: 8) {
                    Text("100% FREE FOR 3 DAYS")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.tm.accentSecondary)
                    
                    Text("ZERO FEE WITH RISK FREE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.tm.accentSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("NO EXTRA COST")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.tm.accentSecondary.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Text("Try 3 days free, after \(viewModel.weekPrice)/week\nCancel anytime")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.tm.title.opacity(0.4)) // secondaryText -> subTitle
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                PaywallContinueButton(action: {
                    viewModel.continueTapped(with: .weekly)
                })
                .padding(.horizontal, 20)
                .padding(.top, 10)

                PaywallBottomLinksView(isPresented: $isPresented, viewModel: viewModel)
                    .padding(.vertical, 10)
            }
            .padding(.bottom, 20)
            
            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.tm.subTitle.opacity(0.5)) // secondaryText -> subTitle
                            .padding(10)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 15)
            .padding(.leading, 10)
        }
    }
}

struct PaywallHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Premium Free")
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(Color.tm.accentSecondary)
            
            Text("for 3 days")
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(.tm.title)
        }
    }
}

struct PaywallIconsBlockView: View {
    var body: some View {
        HStack(spacing: 20) {
            IconWithText(imageName: "PayWallImege1", text: "Remove\nadvertising")
            IconWithText(imageName: "PayWallImege2", text: "Block\ntracking")
            IconWithText(imageName: "PayWallImege3", text: "Stop\nmining")
        }
    }
}

struct IconWithText: View {
    let imageName: String
    let text: String
    
    var iconSize: CGFloat {
        return 72
    }
            
    var body: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(Color.tm.accent)
            
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.tm.title)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
    }
}

struct PaywallFeaturesTagView: View {
    let features = [
        "Enjoy a fast and safe Internet experience",
        "Get rid of intrusive floating videos, pop-up newsletters, and other distracting ads",
        "Don't let advertisers track you online",
        "Speed up image loading and reduce mobile data transfer expenses"
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            FeatureTagView(text: features[0])
            FeatureTagView(text: features[1])
            FeatureTagView(text: features[2])
            FeatureTagView(text: features[3])
        }
    }
}

private struct FeatureTagView: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .lineLimit(2) // Указываем, что нужно 2 строки
                .multilineTextAlignment(.leading) // Выравнивание для многострочного текста
                // Этот модификатор заставит Text занять необходимую высоту (для 2 строк),
                // но не даст ему занять всю доступную ширину.
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.tm.title)
            
            Spacer() // Разделяет текст и галочку
            
            Text("✓")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .cornerRadius(8)
                .foregroundColor(Color.tm.accentSecondary)
        }
    }
}

struct PaywallContinueButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Continue")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.tm.title)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.tm.accent, Color.tm.accentSecondary]),
                        startPoint: .leading, // You can choose .top, .leading, etc.
                        endPoint: .trailing     // You can choose .bottom, .trailing, etc.
                    )
                )
                .cornerRadius(15)
        }
    }
}

struct PaywallBottomLinksView: View { // ВОССТАНОВЛЕНО
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: PaywallViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            Button("Privacy Policy") {
                viewModel.privacyPolicyTapped()
            }
            
            Spacer()
            
            Button("Restore") {
                viewModel.restoreTapped()
            }
            
            Spacer()
            
            Button("Terms of Use") {
                viewModel.licenseAgreementTapped()
            }
        }
        .font(.system(size: 12))
        .foregroundColor(Color.tm.subTitle) // secondaryText -> subTitle
        .padding(.horizontal, 40)
    }
}
