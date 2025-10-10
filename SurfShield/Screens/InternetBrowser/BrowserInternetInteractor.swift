import Foundation

class BrowserInternetInteractor: BrowserInternetObservables, ObservableObject {
    
    @Published private(set) var goBack: Bool = false
    @Published private(set) var goForward: Bool = false
    @Published private(set) var googleUrl: URL = URL(string: "https://google.com")!
    @Published private(set) var needBackGo: Bool = false
    @Published private(set) var needForwardGo: Bool = false
    @Published private(set) var needRefresh: Bool = false
    @Published private(set) var currentProgress: Double = 0
    
    weak var navigationDelegate: BrowserInternetNavigationDelegate?
    
    // MARK: - Resource Analysis
    @Published var resourceAnalysis: ResourceAnalysisData?
    
    
    private let rulesConverter = RulesConverter()
    // MARK: - Resource Monitor
    private var resourceMonitor: ResourceMonitor?
    let userDefaultsObserver = UserDefaultsObserver.shared
    
    init() {
        setupResourceMonitor()
    }
    
    private func setupResourceMonitor() {
        resourceMonitor = ResourceMonitor()
        resourceMonitor?.delegate = self
    }
    
    func updateAddress(_ url: URL?) {
        guard let url = url else { return }
        self.googleUrl = url
    }
    
    func goToUrl(string: String) {
        let processedURLString = processURLString(string)
        
        guard let url = URL(string: processedURLString) else {
            return
        }
        
        navigationDelegate?.loadURL(url)
    }
    
    private func processURLString(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "https://google.com"
        }
        
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return trimmed
        }
        
        if trimmed.range(of: #"^\d+\.\d+\.\d+\.\d+(:\d+)?$"#, options: .regularExpression) != nil {
            return "http://\(trimmed)"
        }
        
        if trimmed.contains(".") {
            return "https://\(trimmed)"
        }
        
        let encodedQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
        return "https://google.com/search?q=\(encodedQuery)"
    }
    
    func refreshPage() {
        navigationDelegate?.reload()
    }
    
    func goBack(_ isGo: Bool) {
        navigationDelegate?.goBack()
    }
    
    func goForward(_ isGo: Bool) {
        navigationDelegate?.goForward()
    }
    
    func setCanGoBack(_ isAvailable: Bool) {
        self.needBackGo = isAvailable
    }
    
    func setCanGoForward(_ isAvailable: Bool) {
        self.needForwardGo = isAvailable
    }
    
    func updateLoadingProgress(_ progress: Double) {
        self.currentProgress = progress
    }
    
    func resetCommands() {
        needBackGo = false
        needForwardGo = false
        needRefresh = false
    }
    
    // MARK: - Rules Loading
    
    func loadAdBlockRules() -> String? {
        
        guard let rulesURL = rulesConverter.getExtensionFileURLWithFallback(forType: .adBlock) else {
            print("❌ Не удалось получить URL для типа ")
            return nil
        }
        
        print("🔍 Загружаем правила из: \(rulesURL.path)")
        
        do {
            let content = try String(contentsOf: rulesURL, encoding: .utf8)
            return content
        } catch {
            print("❌ Ошибка загрузки правил : \(error)")
            return nil
        }
    }
    
    // MARK: - Traffic Statistics Methods
    
//    /// Получает текущую статистику трафика
//    func getTrafficStatistics() -> TrafficStatistics {
//        return trafficStatistics
//    }
//    
//    /// Сбрасывает статистику трафика
//    func resetTrafficStatistics() {
//        trafficStatistics = TrafficStatistics()
//    }
    
    /// Получает ResourceMonitor для настройки WebView
    func getResourceMonitor() -> ResourceMonitor? {
        return resourceMonitor
    }

    /// Получает данные анализа ресурсов
    func getResourceAnalysis() -> ResourceAnalysisData? {
        return resourceAnalysis
    }
    
    /// Сбрасывает данные анализа ресурсов
    func resetResourceAnalysis() {
        resourceAnalysis = nil
    }
    
    // MARK: - Dark Theme Override
    
    /// Возвращает JavaScript код для белого текста и черных фонов
    func getDarkThemeScript() -> String {
        return """
        (function() {
            'use strict';

            console.log('🎨 SurfShield: Запуск упрощенного скрипта темной темы...');

            // Функция для проверки, светлый ли цвет
            function isLightColor(color) {
                if (!color || color === 'transparent' || color === 'rgba(0, 0, 0, 0)') {
                    return false;
                }
                
                const rgbMatch = color.match(/rgba?\\((\\d+),\\s*(\\d+),\\s*(\\d+)/);
                if (!rgbMatch) return false;
                
                const r = parseInt(rgbMatch[1], 10);
                const g = parseInt(rgbMatch[2], 10);
                const b = parseInt(rgbMatch[3], 10);

                // Вычисляем яркость (luminance)
                const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

                // Считаем цвет светлым, если яркость больше 0.7 (70%)
                return luminance > 0.7;
            }

            // Применяем темную тему к фону, сохраняя цвет текста
            function applyDarkTheme() {
                document.querySelectorAll('*').forEach(el => {
        
        
                    const style = getComputedStyle(el);

                    if (style.backgroundColor && isLightColor(style.backgroundColor)) {
                        el.style.setProperty('background-color', 'transparent', 'important');
                    }

                    if (style.borderColor && isLightColor(style.borderColor)) {
                        el.style.setProperty('border-color', 'white', 'important');
                    }

                    if (!isLightColor(style.color)) {
                        el.style.setProperty('color', 'white', 'important');
                    }
                });

                // Общий фон и текст на body/html
                if (document.body) {
                    document.body.style.setProperty('background-color', '#1E1E20', 'important');
                    document.body.style.setProperty('color', 'white', 'important');
                }
                if (document.documentElement) {
                    document.documentElement.style.setProperty('background-color', '#1E1E20', 'important');
                    document.documentElement.style.setProperty('color', 'white', 'important');
                }

                console.log('✅ SurfShield: Темная тема применена, включая верхние слои');
            }


            // Применяем мгновенно
            applyDarkTheme();
            
            // Применяем при загрузке DOM
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function() {
                    applyDarkTheme();
                });
            }
            
            // Применяем при полной загрузке
            window.addEventListener('load', function() {
                applyDarkTheme();
            });
            
            // Применяем при изменении DOM (для динамического контента)
            if (window.MutationObserver) {
                const observer = new MutationObserver(function(mutations) {
                    mutations.forEach(function(mutation) {
                        if (mutation.type === 'childList') {
                            mutation.addedNodes.forEach(function(node) {
                                if (node.nodeType === 1) { // Element node
                                    // Применяем темную тему к новому элементу
                                    const style = getComputedStyle(node);
                                    
                                    if (style.backgroundColor && isLightColor(style.backgroundColor)) {
                                        node.style.setProperty('background-color', 'transparent', 'important');
                                    }
                                    
                                    if (style.borderColor && isLightColor(style.borderColor)) {
                                        node.style.setProperty('border-color', 'white', 'important');
                                    }
                                    
                                    if (!isLightColor(style.color)) {
                                        node.style.setProperty('color', 'white', 'important');
                                    }
                                    
                                    // Применяем к дочерним элементам
                                    const children = node.querySelectorAll('*');
                                    children.forEach(function(child) {
                                        const childStyle = getComputedStyle(child);
                                        
                                        if (childStyle.backgroundColor && isLightColor(childStyle.backgroundColor)) {
                                            child.style.setProperty('background-color', 'transparent', 'important');
                                        }
                                        
                                        if (childStyle.borderColor && isLightColor(childStyle.borderColor)) {
                                            child.style.setProperty('border-color', 'white', 'important');
                                        }
                                        
                                        if (!isLightColor(childStyle.color)) {
                                            child.style.setProperty('color', 'white', 'important');
                                        }
                                    });
                                }
                            });
                        }
                    });
                });
                
                observer.observe(document.body || document.documentElement, {
                    childList: true,
                    subtree: true
                });
            }
            
            console.log('SurfShield: Темная тема применена МГНОВЕННО');

            // Применять повторно при динамических изменениях и скролле можно дополнительно
        })();

        """
    }
}
