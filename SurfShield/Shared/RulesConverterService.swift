import Foundation
import SafariServices

public class RulesConverterService {
    public static let shared = RulesConverterService()
    
    private let groupID: String = Constants.adblockGroupId
    private let extensionsBundles: [String] = Constants.BlockExtenesionBundleIds.all
    
    internal func getExtensionFileURLWithFallback(forType type: RulesType) -> URL? {
        return type.filePath
    }
    
    // MARK: - Public
    
    public func saveEmptyRules() async {
        let emptyRuleArray = [self.createEmptyRule()]
        
        guard let emptyRulesJSON = self.convertRulesToJSON(emptyRuleArray) else {
            return
        }
        
        await saveEmptyRules(emptyRulesJSON)
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
    }
    
    public func saveConvertedRules(_ convertedRules: [String]) async {
        await saveConvertedRulesToGroup(convertedRules)
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
    }
    
    public func applyBlockingState(_ isEnabled: Bool) async {
        if isEnabled {
            await enableContentBlocker()
        } else {
            await generateEmptyRules()
        }
    }
    
    private func enableContentBlocker() async  {
        if let cachedRules = loadCachedRules() {
            await saveConvertedRulesToGroup(cachedRules)
            await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
            return
        }
        
        await convertAndSaveRules()
    }
    
    private func convertAndSaveRules() async {
        guard let rulesPath = Bundle.main.path(forResource: "adblock_rules2", ofType: "txt") else {
            return
        }
        
        let rulesString = try! String(contentsOfFile: rulesPath, encoding: .utf8)
        let lines = rulesString.components(separatedBy: .newlines)
        let chunkedRules = lines.chunked(by: 140000)
        var resultArray: [String] = []
                
        for chunkedRule in chunkedRules {
            let result: ConversionResult = ContentBlockerConverter().convertArray(
                   rules: chunkedRule,
                   safariVersion: SafariVersion.autodetect(),
                   advancedBlocking: true,
                   maxJsonSizeBytes: nil,
                   progress: nil
               )
            resultArray.append(result.safariRulesJSON)
        }
        
        saveRulesToCache(resultArray)
        await saveConvertedRulesToGroup(resultArray)
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
    }
    
    private func generateEmptyRules() async {
        let emptyRuleArray = [self.createEmptyRule()]
        
        guard let emptyRulesJSON = self.convertRulesToJSON(emptyRuleArray) else {
            return
        }
        
        await saveEmptyRules(emptyRulesJSON)
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
    }
    
    private func saveEmptyRules(_ emptyRulesJSON: String) async {
        for ruleType in RulesType.allCases {
            ruleType.writeRules(emptyRulesJSON, emptyRules: true, groupID: self.groupID)
        }
    }
    
    private func saveConvertedRulesToGroup(_ convertedRules: [String]) async {
        for (index, ruleType) in RulesType.allCases.enumerated() {
            if let rules = convertedRules[safe: index] {
                ruleType.writeRules(rules, emptyRules: false, groupID: groupID)
            } else {
                let emptyRuleArray = [createEmptyRule()]
                if let jsonString = convertRulesToJSON(emptyRuleArray) {
                    ruleType.writeRules(jsonString, emptyRules: true, groupID: groupID)
                }
            }
        }
    }
    
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
    
    // MARK: - Cache
    
    private func saveRulesToCache(_ rules: [String]) {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return
        }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            try jsonData.write(to: cacheURL)
        } catch {
            print("\(error)")
        }
    }
    
    private func loadCachedRules() -> [String]? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        
        guard fileManager.fileExists(atPath: cacheURL.path) else {
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: cacheURL)
            let rules = try JSONSerialization.jsonObject(with: jsonData) as? [String]
            return rules
        } catch {
            return nil
        }
    }
    
    private func clearRulesCache() {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return
        }
        
        let cacheURL = groupURL.appendingPathComponent("cached_rules.json")
        
        do {
            if fileManager.fileExists(atPath: cacheURL.path) {
                try fileManager.removeItem(at: cacheURL)
            }
        } catch {
            print("\(error)")
        }
    }
 
    // MARK: - Private
    
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
            return nil
        }
    }
    
    private func reloadExtensions(bundles: [String], maxRetries: Int) async {
        guard !bundles.isEmpty else { return }
        await reloadSingleExtension(bundle: bundles.first!, maxRetries: 1)
    }
    
    private func reloadSingleExtension(bundle: String, maxRetries: Int) async {
        var attempts = 0
        
        while attempts < maxRetries {
            attempts += 1
            do {
                try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundle)
                return
            } catch {
                print("\(error):")
            }
        }
    }
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

