//
//  RulesConverter.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//
import Foundation
import SafariServices


/// Модуль блокировщика рекламы
public class RulesConverter {
    // MARK: - Singleton
    public static let shared = RulesConverter()
    
    // MARK: Internal Properties
    private let groupID: String = Constants.adblockGroupId
    private let extensionsBundles: [String] = Constants.BlockExtenesionBundleIds.all
    
    /// Получить URL файла правил с fallback к bundle
    /// - Parameter type: тип расширения
    /// - Returns: URL файла правил или fallback к bundle
    internal func getExtensionFileURLWithFallback(forType type: RulesType) -> URL? {
        return type.filePath
    }
    // MARK: - Public Methods
    
    /// Сохраняет пустые правила (отключает блокировщик)
    public func saveEmptyRules() async {
        print("🔄 Создаем пустые правила для отключения блокировщика...")
        
        let emptyRuleArray = [self.createEmptyRule()]
        
        guard let emptyRulesJSON = self.convertRulesToJSON(emptyRuleArray) else {
            print("❌ Ошибка создания пустых правил")
            return
        }
        
        await saveEmptyRules(emptyRulesJSON)
        
        print("🔄 Перезагружаем расширения после сохранения пустых правил...")
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
        print("✅ Пустые правила применены ко всем расширениям")
    }
    
    /// Сохраняет уже сконвертированные правила (включает блокировщик)
    /// - Parameter convertedRules: массив сконвертированных правил в JSON формате
    public func saveConvertedRules(_ convertedRules: [String]) async {
        await saveConvertedRulesToGroup(convertedRules)
        
        print("🔄 Перезагружаем расширения после сохранения сконвертированных правил...")
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
        print("✅ Сконвертированные правила применены ко всем расширениям")
    }
    
    /// Применяет или отменяет правила блокировки в зависимости от состояния
    public func applyBlockingState(_ isEnabled: Bool) async {
        print("🔄 Применяем состояние блокировщика: \(isEnabled ? "включен" : "выключен")")
        
        if isEnabled {
//            await generateFiles()
            await enableContentBlocker()
        } else {
            await generateEmptyRules()
        }
    }
    
    //MARK: Main Method
    private func enableContentBlocker() async  {
        // Проверяем есть ли кэшированные правила
        if let cachedRules = loadCachedRules() {
            print("✅ Найдены кэшированные правила, применяем их...")
            await saveConvertedRulesToGroup(cachedRules)
            await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
            print("✅ Кэшированные правила применены")
            return
        }
        
        // Если нет кэша - конвертируем и сохраняем
        print("🔄 Кэш не найден, конвертируем правила...")
        await convertAndSaveRules()
    }
    
    /// Конвертирует правила и сохраняет в кэш
    private func convertAndSaveRules() async {
        guard let rulesPath = Bundle.main.path(forResource: "adblock_rules2", ofType: "txt") else {
            print("❌ Файл adblock_rules2.txt не найден в bundle")
            return
        }
        
        let rulesString = try! String(contentsOfFile: rulesPath, encoding: .utf8)
        let lines = rulesString.components(separatedBy: .newlines)
        let chunkedRules = lines.chunked(by: 140000)
        var resultArray: [String] = []
        
        print("📊 Конвертируем \(lines.count) правил...")
        
        for (index, chunkedRule) in chunkedRules.enumerated() {
            let result: ConversionResult = ContentBlockerConverter().convertArray(
                   rules: chunkedRule,
                   safariVersion: SafariVersion.autodetect(),
                   advancedBlocking: true,
                   maxJsonSizeBytes: nil,
                   progress: nil
               )
            resultArray.append(result.safariRulesJSON)
        }
        
        // Сохраняем в кэш и применяем
        saveRulesToCache(resultArray)
        await saveConvertedRulesToGroup(resultArray)
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
        
        print("✅ Правила сконвертированы, сохранены в кэш и применены")
    }
    
    /// Генерирует пустые правила для отключения блокировки
    private func generateEmptyRules() async {
        print("🔄 Создаем пустые правила для отключения блокировки...")
        
        let emptyRuleArray = [self.createEmptyRule()]
        
        guard let emptyRulesJSON = self.convertRulesToJSON(emptyRuleArray) else {
            print("❌ Ошибка создания пустых правил")
            return
        }
        
        // Используем новый метод для сохранения пустых правил
        await saveEmptyRules(emptyRulesJSON)
        
        print("🔄 Перезагружаем расширения после создания пустых правил...")
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
        print("✅ Пустые правила применены ко всем расширениям")
    }
    
    /// Сохраняет пустые правила с маркировкой
    /// - Parameter emptyRulesJSON: JSON строка с пустыми правилами
    private func saveEmptyRules(_ emptyRulesJSON: String) async {
        print("💾 Сохраняем пустые правила в App Group...")
        
        for ruleType in RulesType.allCases {
            ruleType.writeRules(emptyRulesJSON, emptyRules: true, groupID: self.groupID)
            print("✅ Пустые правила сохранены для \(ruleType.rawValue)")
        }
    }
    
    /// Сохраняет уже сконвертированные правила (приватный метод)
    /// - Parameter convertedRules: массив сконвертированных правил в JSON формате
    private func saveConvertedRulesToGroup(_ convertedRules: [String]) async {
        print("💾 Сохраняем сконвертированные правила в App Group...")
        
        for (index, ruleType) in RulesType.allCases.enumerated() {
            if let rules = convertedRules[safe: index] {
                ruleType.writeRules(rules, emptyRules: false, groupID: groupID)
                print("✅ Сконвертированные правила сохранены для \(ruleType.rawValue)")
            } else {
                // Если для этого типа нет правил, создаем пустые
                let emptyRuleArray = [createEmptyRule()]
                if let jsonString = convertRulesToJSON(emptyRuleArray) {
                    ruleType.writeRules(jsonString, emptyRules: true, groupID: groupID)
                    print("✅ Пустые правила сохранены для \(ruleType.rawValue) (нет сконвертированных)")
                }
            }
        }
    }
    
    
    /// Сохраняет JSON в файл для просмотра
    private func saveJSONToFile(json: String) {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "safari_rules_\(Date().timeIntervalSince1970).json"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try json.write(to: fileURL, atomically: true, encoding: .utf8)
            
            print("💾 JSON сохранен в файл: \(fileURL.path)")
            print("📁 Путь к файлу: \(fileURL.path)")
            
        } catch {
            print("❌ Ошибка при сохранении JSON: \(error)")
        }
    }
    
    // MARK: - Cache Methods
    
    /// Сохраняет сконвертированные правила в кэш
    /// - Parameter rules: массив сконвертированных правил
    private func saveRulesToCache(_ rules: [String]) {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            print("❌ Не удалось получить доступ к App Group для кэша")
            return
        }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            try jsonData.write(to: cacheURL)
            print("✅ Правила сохранены в кэш: \(cacheURL.path)")
        } catch {
            print("❌ Ошибка сохранения правил в кэш: \(error)")
        }
    }
    
    /// Загружает сконвертированные правила из кэша
    /// - Returns: массив сконвертированных правил или nil, если кэш пуст
    private func loadCachedRules() -> [String]? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            print("❌ Не удалось получить доступ к App Group для кэша")
            return nil
        }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        
        guard fileManager.fileExists(atPath: cacheURL.path) else {
            print("📋 Кэшированные правила не найдены")
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: cacheURL)
            let rules = try JSONSerialization.jsonObject(with: jsonData) as? [String]
            print("✅ Кэшированные правила загружены")
            return rules
        } catch {
            print("❌ Ошибка загрузки кэшированных правил: \(error)")
            return nil
        }
    }
    
    /// Очищает кэш правил
    private func clearRulesCache() {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            print("❌ Не удалось получить доступ к App Group для кэша")
            return
        }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        
        do {
            if fileManager.fileExists(atPath: cacheURL.path) {
                try fileManager.removeItem(at: cacheURL)
                print("✅ Кэш правил очищен")
            }
        } catch {
            print("❌ Ошибка очистки кэша правил: \(error)")
        }
    }
 
    // MARK: - Private Methods
    
    // Добавляем недостающие вспомогательные методы
    private func createEmptyRule() -> [String: Any] {
        return [
            "trigger": [
                "url-filter": "^https?://never-existing-domain-for-adblocker-disabled\\.com/.*"
            ],
            "action": [
                "type": "block"
            ]
        ]
    }
    
    private func convertRulesToJSON(_ rules: [[String: Any]]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("❌ Ошибка конвертации правил в JSON: \(error)")
            return nil
        }
    }
    
    private func reloadExtensions(bundles: [String], maxRetries: Int) async {
        guard !bundles.isEmpty else { return }
        
        print("🔄 Начинаем параллельную перезагрузку \(bundles.count) расширений...")

        
//        for bundle in bundles {
        await reloadSingleExtension(bundle: bundles.first!, maxRetries: 1)
//        }
        
        print("✅ Завершена перезагрузка всех расширений")
    }
    
    /// Перезагружает одно расширение с повторными попытками
    private func reloadSingleExtension(bundle: String, maxRetries: Int) async {
        var attempts = 0
        
        while attempts < maxRetries {
            attempts += 1
            do {
                try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundle)
                print("✅ Расширение \(bundle) успешно перезагружено (попытка \(attempts)/\(maxRetries))")
                return
            } catch {
                print("❌ Попытка - Ошибка перезагрузки расширения \(bundle):")
            }
        }
        
        print("⚠️ Не удалось перезагрузить расширение \(bundle) после \(maxRetries) попыток")
    }
    
    
    
    //MARK: OLD
    /// Генерирует файлы правил
//    private func generateFiles() async {
//        do {
//            let domains = try self.loadAndParseDomains()
//            let preparedRules = self.convertDomainsToSafariRules(domains)
//            self.saveRulesToFiles(preparedRules)
//            
//            print("🔄 Перезагружаем расширения после создания правил блокировки...")
//            await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
//            print("✅ Правила блокировки применены ко всем расширениям")
//        } catch {
//            print("❌ Ошибка генерации файлов: \(error)")
//        }
//    }
    
//    func loadAndParseDomains() throws -> [String] {
//        guard let rulesPath = Bundle.main.path(forResource: "domains", ofType: "txt") else {
//            throw RulesConverterError.fileNotFound
//        }
//        
//        let rulesString = try String(contentsOfFile: rulesPath, encoding: .utf8)
//        let lines = rulesString.components(separatedBy: .newlines)
//        return lines.compactMap { line in
//            let trimmed = line.trimmingCharacters(in: .whitespaces)
//            guard !trimmed.isEmpty, !trimmed.hasPrefix("!"), !trimmed.hasPrefix("[") else { return nil }
//            guard !trimmed.contains("##") else { return nil }
//            return trimmed
//        }
//    }
    
//    private func convertDomainsToSafariRules(_ rules: [String]) -> [String] {
//        let chunks = rules.chunked(by: 35000)
//        var preparedRules = [String]()
//        
//        for chunk in chunks {
//            let safariRules = chunk.compactMap { domain in
//                let escapedDomain = domain.replacingOccurrences(of: ".", with: "\\.")
//                return [
//                    "trigger": [
//                        "url-filter": "^https?:/+([^/:]+\\.)?\(escapedDomain)[:/]",
//                        "load-type": ["third-party", "first-party"]
//                    ],
//                    "action": ["type": "block"]
//                ]
//            }
//            
//            if let jsonString = convertRulesToJSON(safariRules.isEmpty ? [createEmptyRule()] : safariRules) {
//                preparedRules.append(jsonString)
//            }
//        }
//        
//        return preparedRules
//    }
//    

}

/// Тип екстеншена блокировщика
public enum RulesType: String, Codable, CaseIterable {
    case adBlock
    case privacy
    case banners
    case trackers
    case advanced
    case secure
    case basic
    
    /// Получить URL по каторому находится файл для определенного экстеншна
    /// - Returns: URL по каторому находится файл
    internal var filePath: URL? {
        let fileManager = FileManager.default
        // Используй App Group вместо Documents
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Constants.adblockGroupId) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("\(self.rawValue).json")
        return fileURL
    }
    
    private var fileName: String {
        return self.rawValue + ".json"
    }

    internal func writeRules(_ rules: String, emptyRules: Bool, groupID: String) {
        guard let filePath = getFilePath(groupID: groupID) else {
            print("❌ Не удалось получить путь для \(self.rawValue)")
            return 
        }
        let fileManager = FileManager.default
        
        do {
            // Синхронная запись с принудительной синхронизацией
            try rules.write(to: filePath, atomically: true, encoding: .utf8)
            
            // Принудительная синхронизация файловой системы
            let fileHandle = try FileHandle(forWritingTo: filePath)
            try fileHandle.synchronize()
            try fileHandle.close()
            
            // Проверяем, что файл действительно создался и имеет правильный размер
            if fileManager.fileExists(atPath: filePath.path) {
                let attributes = try? fileManager.attributesOfItem(atPath: filePath.path)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                print("✅ \(self.rawValue) успешно сохранен: \(filePath.path) (размер: \(fileSize) байт)")
            } else {
                print("❌ \(self.rawValue) файл не найден после записи: \(filePath.path)")
            }
        } catch {
            print("❌ Ошибка записи \(self.rawValue): \(error.localizedDescription)")
        }
    }
    
    private func getFilePath(groupID: String) -> URL? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("\(self.rawValue).json")
        return fileURL
    }
}

extension Array {
    public func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}



// MARK: - Error Types

private enum RulesConverterError: Error {
    case fileNotFound
}

// MARK: - AdBlock Rule Parser

