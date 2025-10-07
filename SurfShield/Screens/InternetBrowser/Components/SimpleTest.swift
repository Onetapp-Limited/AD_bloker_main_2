//
//  SimpleTest.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import Foundation

// MARK: - Simple Test
class SimpleTest {
    
    static func testTrafficStatistics() {
        print("🧪 Тестирование статистики трафика...")
        
        let interactor = WebViewInteractor()
        
        // Получаем начальную статистику
        let initialStats = interactor.getTrafficStatistics()
        print("📊 Начальная статистика:")
        print("   - Заблокировано: \(initialStats.blockedRequestsCount) запросов")
        print("   - Разрешено: \(initialStats.allowedRequestsCount) запросов")
        print("   - Сэкономлено: \(initialStats.formattedSavedBytes)")
        
        // Тестируем сброс статистики
        interactor.resetTrafficStatistics()
        let resetStats = interactor.getTrafficStatistics()
        let isReset = resetStats.blockedRequestsCount == 0 && resetStats.allowedRequestsCount == 0
        print("\(isReset ? "✅" : "❌") Сброс статистики: \(isReset ? "Успешно" : "Ошибка")")
        
        print("🎉 Тестирование статистики завершено!")
    }
    
    static func testRulesParsing() {
        print("🧪 Тестирование парсинга правил...")
        
        let interactor = WebViewInteractor()
        
        // Получаем JavaScript код с правилами
        let script = interactor.getMonitoringScript()
        print("📋 JavaScript код загружен (\(script.count) символов)")
        
        // Проверяем наличие ключевых элементов
        let keyElements = [
            "blockedDomains",
            "blockedPatterns", 
            "shouldBlockResource",
            "originalFetch",
            "originalXHROpen"
        ]
        
        for element in keyElements {
            let contains = script.contains(element)
            let result = contains ? "✅" : "❌"
            print("\(result) Элемент '\(element)': \(contains ? "Найден" : "Не найден")")
        }
        
        print("🎉 Тестирование парсинга правил завершено!")
    }
    
    static func testDomainsLoading() {
        print("🧪 Тестирование загрузки доменов...")
        
        // Тестируем fallback скрипт с доменами
        let fallbackScript = ResourceMonitor.getFallbackMonitoringScript()
        print("📋 Fallback скрипт загружен (\(fallbackScript.count) символов)")
        
        // Проверяем, что в скрипте есть домены
        let hasDomains = fallbackScript.contains("blockedDomains") && fallbackScript.contains("[")
        let result = hasDomains ? "✅" : "❌"
        print("\(result) Домены в fallback скрипте: \(hasDomains ? "Найдены" : "Не найдены")")
        
        // Подсчитываем примерное количество доменов в скрипте
        let domainCount = fallbackScript.components(separatedBy: "'").count / 2
        print("📊 Примерное количество доменов: \(domainCount)")
        
        print("🎉 Тестирование загрузки доменов завершено!")
    }
    
    static func runQuickTest() {
        print("🚀 Быстрый тест...")
        testTrafficStatistics()
        testRulesParsing()
        testDomainsLoading()
    }
    
    static func runAllTests() {
        testTrafficStatistics()
        testRulesParsing()
        testDomainsLoading()
    }
}
