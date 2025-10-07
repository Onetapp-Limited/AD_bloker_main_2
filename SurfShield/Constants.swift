//
//  Constants.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//

import Foundation


enum Constants {
    static var adblockGroupId = "group.surfshield.app.adblocker"
    
    enum BlockExtenesionBundleIds: String, CaseIterable {
        case adblocker = "com.surfshield.app.adblocker"
        case privacy = "com.surfshield.app.privacy"
        case banners = "com.surfshield.app.banners"
        case trackers = "com.surfshield.app.trackers"
        case advanced = "com.surfshield.app.advanced"
        case secure = "com.surfshield.app.secure"
        case basic = "com.surfshield.app.basic"
        
        static var all: [String] {
            BlockExtenesionBundleIds.allCases.map { $0.rawValue }
        }
    }
}
