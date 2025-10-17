import StoreKit
import ApphudSDK
import Combine

// MARK: - App Constants and Types

enum PurchaseServiceProduct: String, CaseIterable {
    case week = "week_899_3dtrial"
}

enum PurchaseServiceResult {
    case success
    case failure(Error?)
}

enum PurchaseError: Error {
    case cancelled
    case noProductsFound
    case productNotFound(String)
    case purchaseFailed
    case noActiveSubscription
}

public extension SKProduct {
    var localizedPrice: String? {
         let formatter = NumberFormatter()
         formatter.numberStyle = .currency
         formatter.locale = self.priceLocale
         return formatter.string(from: self.price)
     }

     var currency: String {
         return self.priceLocale.currencySymbol ?? ""
     }

    private struct PriceFormatter {
        static let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            return formatter
        }()
    }
}

final class ApphudPurchaseService {
    
    typealias PurchaseCompletion = (PurchaseServiceResult) -> Void
        
    private var availableProducts: [ApphudProduct] = []

    var hasActiveSubscription: Bool {
//        true // todo test111
        Apphud.hasActiveSubscription()
    }
    
    static var shared = ApphudPurchaseService()

    
    private init() {
        Task {
            await fetchProducts()
        }
    }
    
    @MainActor
    func purchase(plan: SubscriptionPlan, completion: @escaping PurchaseCompletion) {
        guard let productId = getProductId(for: plan) else {
            completion(.failure(PurchaseError.noProductsFound))
            return
        }

        guard let product = getProduct(with: productId) else {
            completion(.failure(PurchaseError.productNotFound(productId)))
            return
        }

        Apphud.purchase(product) { [weak self] result in
            self?.handlePurchaseResult(result, completion: completion)
        }
    }
    
    @MainActor
    func restore(completion: @escaping PurchaseCompletion) {
        Apphud.restorePurchases { _ in }
    }
    
    func price(for product: PurchaseServiceProduct) -> Double? {
        guard let skProduct = getSKProduct(for: product) else { return nil }
        return skProduct.price.doubleValue
    }
    
    func localizedPrice(for product: PurchaseServiceProduct) -> String? {
        guard let skProduct = getSKProduct(for: product) else {
            return ""
        }
        return skProduct.localizedPrice
    }
    
    func currency(for product: PurchaseServiceProduct) -> String? {
        guard let skProduct = getSKProduct(for: product) else { return nil }
        return skProduct.currency
    }

    func perDayPrice(for product: PurchaseServiceProduct) -> String {
        let defaultPerDayPrice = "" // Updated fallback per-day price
        
        guard let priceValue = price(for: product),
              let currencySymbol = currency(for: product) else {
            return defaultPerDayPrice
        }
        
        var days: Double
        switch product {
        case .week:
            days = 7.0
        }
        
        let perDay = priceValue / days
        
        return String(format: "%.2f%@", perDay, currencySymbol)
    }

    private func getProductId(for plan: SubscriptionPlan) -> String? {
        switch plan {
        case .weekly:
            return PurchaseServiceProduct.week.rawValue
        }
    }

    private func getProduct(with id: String) -> ApphudProduct? {
        return availableProducts.first(where: { $0.productId == id })
    }

    private func getSKProduct(for product: PurchaseServiceProduct) -> SKProduct? {
        return getProduct(with: product.rawValue)?.skProduct
    }
    
    private func handlePurchaseResult(_ result: ApphudPurchaseResult, completion: @escaping PurchaseCompletion) {
        if let error = result.error {
            print("Apphud: Purchase failed with error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        if let subscription = result.subscription, subscription.isActive() || result.nonRenewingPurchase != nil {
            print("Apphud: Purchase successful.")
            completion(.success)
        } else {
            print("Apphud: Purchase failed - unknown reason.")
            completion(.failure(PurchaseError.purchaseFailed))
        }
    }

    private func handleRestoreResult(subscriptions: [ApphudSubscription]?, error: Error?, completion: @escaping PurchaseCompletion) {
        if let restoreError = error {
            completion(.failure(restoreError))
            return
        }
        
        if subscriptions?.first(where: { $0.isActive() }) != nil {
            print("Apphud: Restore successful - active subscription found.")
            completion(.success)
        } else {
            print("Apphud: Restore completed, but no active subscription found.")
            completion(.failure(PurchaseError.noActiveSubscription))
        }
    }
    
    func fetchProducts() async {
        let placements = await Apphud.placements(maxAttempts: 3)
        guard let paywall = placements.first?.paywall, !paywall.products.isEmpty else {
            print("Apphud: No products found on paywall.")
            return
        }
        
        self.availableProducts = paywall.products
        print("Apphud: Fetched products with IDs: \(self.availableProducts.map { $0.productId })")
        print()
    }
}

