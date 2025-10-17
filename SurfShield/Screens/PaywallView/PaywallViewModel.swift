import SwiftUI
import Combine
import AppsFlyerLib

enum ResurcesUrlsConstants {
    static let licenseAgreementURL: String = "https://docs.google.com/document/d/1Bui27Z99LoyQN86Kal7rI1S65T0x-UTrM619Kufuom4/edit?usp=sharing"
    static let privacyPolicyURL: String = "https://docs.google.com/document/d/1UgJhUk01_cvZK3x0626_x65HXoirR4mEU9RrJw_1ZLI/edit?usp=sharing"
    static let contactUsEmail: String = ""
}

final class PaywallViewModel: ObservableObject {
    private let isPresentedBinding: Binding<Bool>
    
    @Published var weekPrice: String = "N/A"
        
    init(isPresented: Binding<Bool>) {
        self.isPresentedBinding = isPresented
        
        Task {
            await updatePrices()
        }
    }
    
    @MainActor
    func continueTapped(with plan: SubscriptionPlan) {
        ApphudPurchaseService.shared.purchase(plan: plan) { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                print("Error during purchase: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if case .success = result {
                AppsFlyerLib.shared().logEvent("af_purchase", withValues: [
                    AFEventParamRevenue: weekPrice,
                    AFEventParamCurrency: ApphudPurchaseService.shared.currency,
                    AFEventParamContentId: PurchaseServiceProduct.week.rawValue
                ])
            }
            
            self.dismissPaywall()
        }
    }
    
    /// Handles the restore purchases button tap action.
    @MainActor
    func restoreTapped() {
        ApphudPurchaseService.shared.restore() { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                print("Error during restore: \(error?.localizedDescription ?? "Unknown error")")
                // Still dismiss the paywall on restore failure as per common UX
                self.dismissPaywall()
                return
            }
            
            self.dismissPaywall()
        }
    }
    
    func licenseAgreementTapped() {
        guard let url = URL(string: ResurcesUrlsConstants.licenseAgreementURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func privacyPolicyTapped() {
        guard let url = URL(string: ResurcesUrlsConstants.privacyPolicyURL) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Private Methods
    
    private func updatePrices() async {
        await MainActor.run {
            self.weekPrice = ApphudPurchaseService.shared.localizedPrice(for: .week) ?? "N/A"
        }
    }
    
    private func dismissPaywall() {
        isPresentedBinding.wrappedValue = false
    }
}

