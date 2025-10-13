import UIKit
import MobileCoreServices
import Foundation

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let mainURLWithRulles = RulesConverterService().getExtensionFileURLWithFallback(forType: .adBlock)
        let provider = NSItemProvider(contentsOf: mainURLWithRulles)!
        
        let mainItem = NSExtensionItem()
        mainItem.attachments = [provider]
        
        context.completeRequest(returningItems: [mainItem], completionHandler: nil)
    }
}
