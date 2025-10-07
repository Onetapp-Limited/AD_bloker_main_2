//
//  ContentBlockerRequestHandler.swift
//  sequrity
//
//  Created by Артур Кулик on 25.08.2025.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let rulesURL = RulesConverter().getExtensionFileURLWithFallback(forType: .sequrity)
        let attachment = NSItemProvider(contentsOf: rulesURL)!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
}
