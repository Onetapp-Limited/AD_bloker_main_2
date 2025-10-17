import SwiftUI

@main
struct SurfShieldApp: App {
    
    init() {
        _ = ApphudPurchaseService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
    }
}

