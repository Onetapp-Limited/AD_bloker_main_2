import Foundation
import SafariServices

public class RulesConverterService {
    public static let shared = RulesConverterService()
    
    private let groupID: String = Constants.adblockGroupId
    private let bundleIdsForExtension: [String] = Constants.BundleAdsBlockerExtenesionIds.allCases.map { $0.rawValue }
    
    internal func getExtensionFileURLWithFallback(forType type: RulesType) -> URL? {
        return type.getPathToFile
    }
    
    // MARK: - Public
    
    public func saveEmptyRules() async {
        let emptyRuleArray = [self.createMinimalBlockRule()]
        
        guard let emptyRulesJSON = self.serializeRulesToJSON(emptyRuleArray) else {
            return
        }
        
        await applyEmptyRulesToFile(emptyRulesJSON)
        await self.reloadExtensions(bundles: self.bundleIdsForExtension, maxRetries: self.bundleIdsForExtension.count)
    }
    
    public func saveConvertedRules(_ convertedRules: [String]) async {
        await storeConvertedRulesInGroup(convertedRules)
        await self.reloadExtensions(bundles: self.bundleIdsForExtension, maxRetries: self.bundleIdsForExtension.count)
    }
    
    public func applyBlockingState(_ isEnabled: Bool) async {
        if isEnabled {
            await activateContentBlocker()
        } else {
            await buildAndApplyEmptyRules()
        }
    }
    
    private func activateContentBlocker() async  {
        if let cachedRules = retrieveCachedRules() {
            await storeConvertedRulesInGroup(cachedRules)
            await self.reloadExtensions(bundles: self.bundleIdsForExtension, maxRetries: self.bundleIdsForExtension.count)
            return
        }
        
        await initiateRulesConversion()
    }
    
    private func initiateRulesConversion() async {
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
        
        cacheGeneratedRules(resultArray)
        await storeConvertedRulesInGroup(resultArray)
        await self.reloadExtensions(bundles: self.bundleIdsForExtension, maxRetries: self.bundleIdsForExtension.count)
    }
    
    private func buildAndApplyEmptyRules() async {
        let emptyRuleArray = [self.createMinimalBlockRule()]
        
        guard let emptyRulesJSON = self.serializeRulesToJSON(emptyRuleArray) else {
            return
        }
        
        await applyEmptyRulesToFile(emptyRulesJSON)
        await self.reloadExtensions(bundles: self.bundleIdsForExtension, maxRetries: self.bundleIdsForExtension.count)
    }
    
    private func applyEmptyRulesToFile(_ emptyRulesJSON: String) async {
        for ruleType in RulesType.allCases {
            ruleType.setRules(emptyRulesJSON, emptyRules: true, groupID: self.groupID)
        }
    }
    
    private func storeConvertedRulesInGroup(_ convertedRules: [String]) async {
        for (index, ruleType) in RulesType.allCases.enumerated() {
            if let rules = convertedRules[safe: index] {
                ruleType.setRules(rules, emptyRules: false, groupID: groupID)
            } else {
                let emptyRuleArray = [createMinimalBlockRule()]
                if let jsonString = serializeRulesToJSON(emptyRuleArray) {
                    ruleType.setRules(jsonString, emptyRules: true, groupID: groupID)
                }
            }
        }
    }
    
    private func saveJSONToTemporaryFile(json: String) {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "safari_rules_\(Date().timeIntervalSince1970).json"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try json.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("\(error)")
        }
    }
    
    // MARK: - Cache
    
    private func cacheGeneratedRules(_ rules: [String]) {
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
    
    private func retrieveCachedRules() -> [String]? {
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
    
    private func removeRulesCache() {
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

    // MARK: - Private Utilities
    
    private func createMinimalBlockRule() -> [String: Any] {
        return [
            "trigger": [
                "url-filter": "^https?://never-existing-domain-for-adblocker-disabled\\.com/.*"
            ],
            "action": [
                "type": "block"
            ]
        ]
    }
    
    private func serializeRulesToJSON(_ rules: [[String: Any]]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    private func reloadExtensions(bundles: [String], maxRetries: Int) async {
        guard !bundles.isEmpty else { return }
        await attemptToReloadSingleExtension(bundle: bundles.first!, maxRetries: 1)
    }
    
    private func attemptToReloadSingleExtension(bundle: String, maxRetries: Int) async {
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
