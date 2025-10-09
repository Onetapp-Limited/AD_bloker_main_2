import SwiftUI

struct InternetBrowserView: View {
    @StateObject var interactor = WebViewInteractor()
    
    private let panelHeight: CGFloat = 56
    
    var body: some View {
        browser
    }
    
    @ViewBuilder
    var browser: some View {
        ZStack(alignment: .top) {
            // WebView занимает весь экран
            WebView(interactor: interactor)
                .padding(.top, panelHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Панель навигации поверх WebView
            WebViewPanel(
                observables: interactor,
                onGoBack: {
                    print("Назад")
                    interactor.goBack(true)
                    // TODO: Реализовать навигацию назад
                },
                onGoForward: {
                    print("Вперед")
                    interactor.goForward(true)
                    // TODO: Реализовать навигацию вперед
                },
                onRefresh: {
                    interactor.refreshPage()
                    print("Обновление страницы")
                    // TODO: Реализовать обновление страницы
                },
                onGoToURL: { url in
                
                    interactor.goToUrl(string: url)
                    print("Переход к URL: \(url)")
                    // TODO: Реализовать переход по URL
                },
                onShare: { url in
                    print("Sharing: \(url)")
                    // TODO: Реализовать функциональность поделиться
                }
            )
            .zIndex(1) // Панель всегда поверх WebView
        }
    }
    
    
}
