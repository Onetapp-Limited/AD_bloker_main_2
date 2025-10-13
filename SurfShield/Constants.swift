import Foundation

enum Constants {
    static var adblockGroupId = "group.adBloker.main.app.adblocker"
    
    enum BundleAdsBlockerExtenesionIds: String, CaseIterable {
        case adblocker = "com.adBloker.main.app.adblocker"
        case privacy = "com.adBloker.main.app.privacy"
        case banners = "com.adBloker.main.app.banners"
        case trackers = "com.adBloker.main.app.trackers"
        case advanced = "com.adBloker.main.app.advanced"
        case secure = "com.adBloker.main.app.secure"
        case basic = "com.adBloker.main.app.basic"
    }
}
