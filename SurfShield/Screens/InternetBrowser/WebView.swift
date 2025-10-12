import SwiftUI
@preconcurrency import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var interactor: BrowserInternetInteractor
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        let redTextScript = interactor.getDarkThemeScript()
        let userScript = WKUserScript(
            source: redTextScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(userScript)
        
        let browserView = WKWebView(frame: .zero, configuration: config)
        
        browserView.isUserInteractionEnabled = true
        browserView.clipsToBounds = false
        browserView.scrollView.clipsToBounds = false
        browserView.scrollView.layer.masksToBounds = false
        browserView.allowsBackForwardNavigationGestures = true
        browserView.layer.masksToBounds = false
        browserView.scrollView.isScrollEnabled = true
        browserView.configuration.allowsInlineMediaPlayback = true
        browserView.isUserInteractionEnabled = true
        browserView.configuration.mediaTypesRequiringUserActionForPlayback = [.video]
        browserView.setAllMediaPlaybackSuspended(true)
        browserView.allowsBackForwardNavigationGestures = true

        browserView.scrollView.contentInsetAdjustmentBehavior = .never
        browserView.scrollView.keyboardDismissMode = .interactive
        
        context.coordinator.webView = browserView
        browserView.navigationDelegate = context.coordinator
        browserView.uiDelegate = context.coordinator
        
        context.coordinator.setupResourceMonitoring()
        
        browserView.backgroundColor = UIColor(named: "Container")
        browserView.isOpaque = true
        browserView.scrollView.backgroundColor = UIColor(named: "Container")
        
        browserView.load(URLRequest(url: interactor.googleUrl))
        
        browserView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.url), options: [.new], context: nil)
        browserView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoBack), options: [.new], context: nil)
        browserView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoForward), options: [.new], context: nil)
        browserView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [.new], context: nil)
        
        return browserView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Позволяем WebView автоматически определять тему
//        uiView.overrideUserInterfaceStyle = .unspecified
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.url))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoBack))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoForward))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, BrowserInternetNavigationDelegate, WKUIDelegate {
        var parent: WebView?
        weak var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            self.parent?.interactor.delegate = self
            self.addedContentRules()
        }
                
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {}
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            guard navigationAction.targetFrame == nil || !(navigationAction.targetFrame?.isMainFrame ?? false) else {
                return nil
            }

            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let webView = webView else { return }
            if keyPath == #keyPath(WKWebView.canGoBack) {
                parent?.interactor.setCanGoBack(webView.canGoBack)
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                parent?.interactor.setCanGoForward(webView.canGoForward)
            } else if keyPath == #keyPath(WKWebView.estimatedProgress) {
                parent?.interactor.updateLoadingProgress(webView.estimatedProgress)
            } else if  keyPath == #keyPath(WKWebView.url) {
                parent?.interactor.updateAddress(webView.url)
            }
        }
        
        func goBack() {
            webView?.goBack()
        }
        
        func goForward() {
            webView?.goForward()
        }
        
        func reload() {
            webView?.reload()
            addedContentRules()
        }
        
        func loadURL(_ url: URL) {
            webView?.load(URLRequest(url: url))
        }
                
        public func setupResourceMonitoring() {
            guard let webView = webView,
                  let resourceMonitor = parent?.interactor.getResourceMonitor() else { return }
            
            webView.configuration.userContentController.add(resourceMonitor, name: "resourceAnalysis")
            
            let analysisScript = WKUserScript(
                source: ResourceMonitor.buildResourceInfoJavascript(),
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            webView.configuration.userContentController.addUserScript(analysisScript)
        }
        
        func addedContentRules() {
            let contentRuleListStore = WKContentRuleListStore.default()
            let rules = parent?.interactor.loadAdBlockRules()
            let identifier = "AdBlockRules"
            
            contentRuleListStore!.compileContentRuleList(forIdentifier: identifier, encodedContentRuleList: rules) { ruleList, error in
                if let ruleList = ruleList {
                    self.webView?.configuration.userContentController.add(ruleList)
                }
            }
        }
    }
}


