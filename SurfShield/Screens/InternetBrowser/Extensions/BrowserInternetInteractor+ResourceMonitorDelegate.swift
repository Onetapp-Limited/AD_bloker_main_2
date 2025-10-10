import Foundation

extension BrowserInternetInteractor: ResourceMonitorDelegate {
    func resourceAnalysisCompleted(_ data: ResourceAnalysisData) {
        DispatchQueue.main.async {
            self.resourceAnalysis = data
        }
        
        print("📊 ResourceMonitor: Анализ ресурсов завершен")
        print("   - Всего ресурсов на странице: \(data.totalPageResources)")
        print("   - Загружено ресурсов: \(data.totalLoadedResources)")
        print("   - Заблокировано ресурсов: \(data.blockedCount)")
        print("   - Эффективность блокировки: \(String(format: "%.1f", data.blockedPercentage))%")
        
        if data.blockedCount > 0 {
            userDefaultsObserver.updateWebViewBlockedStatistics(data)
            let blockedResources = Set(data.pageResources).subtracting(Set(data.loadedResources))
            print("🚫 Заблокированные ресурсы:")
            for resource in Array(blockedResources).prefix(10) { // Показываем первые 10
                print("   - \(resource)")
            }
            if blockedResources.count > 10 {
                print("   ... и еще \(blockedResources.count - 10) ресурсов")
            }
        }
    }
}
