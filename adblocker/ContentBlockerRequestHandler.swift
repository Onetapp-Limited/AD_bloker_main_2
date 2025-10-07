//
//  ContentBlockerRequestHandler.swift
//  adblocker
//
//  Created by Артур Кулик on 24.08.2025.
//

import UIKit
import MobileCoreServices
import Foundation

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let rulesURL = RulesConverter().getExtensionFileURLWithFallback(forType: .adBlock)
        let attachment = NSItemProvider(contentsOf: rulesURL)!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
}
