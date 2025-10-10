import Foundation

protocol BrowserInternetObservables {
    var googleUrl: URL { get }
    var needBackGo: Bool { get }
    var goBack: Bool { get }
    var needForwardGo: Bool { get }
    var goForward: Bool { get }
    var needRefresh: Bool { get }
    var currentProgress: Double { get }
}
