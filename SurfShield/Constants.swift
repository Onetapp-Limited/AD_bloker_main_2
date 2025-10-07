//
//  Constants.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//

import Foundation


enum Constants {
    static var adblockGroupId = "group.adBloker.main.app.adblocker"
    
    enum BlockExtenesionBundleIds: String, CaseIterable {
        case adblocker = "com.adBloker.main.app.adblocker"
        case privacy = "com.adBloker.main.app.privacy"
        case banners = "com.adBloker.main.app.banners"
        case trackers = "com.adBloker.main.app.trackers"
        case advanced = "com.adBloker.main.app.advanced"
        case secure = "com.adBloker.main.app.secure"
        case basic = "com.adBloker.main.app.basic"
        
        static var all: [String] {
            BlockExtenesionBundleIds.allCases.map { $0.rawValue }
        }
    }
}
