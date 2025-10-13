import Foundation
import Punycode

public class ContentBlockerConverter {
    public init() {}

    public func convertArray(
        rules: [String],
        safariVersion: SafariVersion = .safari13,
        advancedBlocking: Bool = false,
        maxJsonSizeBytes: Int? = nil,
        progress: Progress? = nil
    ) -> ConversionResult {
        var processingAllowed: Bool {
            !(progress?.isCancelled ?? false)
        }

        let errorTracker = ErrorsCounter()

        guard processingAllowed else {
            return ConversionResult.createEmptyResult()
        }

        let allInputRules = RuleFactory.createRules(
            lines: rules,
            for: safariVersion,
            errorsCounter: errorTracker
        )

        var (basicRules, extendedRules) = ContentBlockerConverter.splitSimpleAdvanced(allInputRules)

        let initialCompatibleRulesCount = basicRules.count

        basicRules = RuleFactory.filterOutExceptions(from: basicRules, version: safariVersion)

        guard processingAllowed else {
            return ConversionResult.createEmptyResult()
        }

        let ruleCompiler = Compiler(errorsCounter: errorTracker, version: safariVersion)

        let compilerOutput = ruleCompiler.compileRules(rules: basicRules, progress: progress)

        let ruleLimit = safariVersion.rulesLimit
        let finalOutput = SafariCbBuilder.buildCbJson(
            from: compilerOutput,
            maxRules: ruleLimit,
            maxJsonSizeBytes: maxJsonSizeBytes
        )

        let extendedRulesCount = advancedBlocking ? extendedRules.count : 0
        let extendedBlockingData =
            advancedBlocking && extendedRulesCount > 0
            ? extendedRules.map { $0.ruleText }.joined(separator: "\n") : nil

        let finalConversionReport = ConversionResult(
            sourceRulesCount: allInputRules.count,
            sourceSafariCompatibleRulesCount: initialCompatibleRulesCount,
            safariRulesCount: finalOutput.rulesCount,
            advancedRulesCount: extendedRulesCount,
            discardedSafariRules: finalOutput.discardedRulesCount,
            errorsCount: errorTracker.getCount(),
            safariRulesJSON: finalOutput.json,
            advancedRulesText: extendedBlockingData
        )

        return finalConversionReport
    }

    public static func createAllowlistRule(by domain: String) -> String {
        return "@@||\(domain)$document"
    }

    public static func createInvertedAllowlistRule(by domains: [String]) -> String? {
        let domainList = domains.filter { !$0.isEmpty }.joined(separator: "|~")
        return !domainList.isEmpty ? "@@||*$document,domain=~\(domainList)" : nil
    }

    private static let universalSimpleAdvancedOptions: NetworkRule.Option = [
        .document,
        .elemhide,
        .generichide,
        .specifichide,
    ]

    private static let advancedOptions: NetworkRule.Option = [
        .jsinject
    ]

    private static func splitSimpleAdvanced(_ rules: [Rule]) -> (simple: [Rule], advanced: [Rule]) {
        var basicList: [Rule] = []
        var extendedList: [Rule] = []

        for ruleItem in rules {
            if let networkRule = ruleItem as? NetworkRule {
                if networkRule.isWhiteList {
                    if !networkRule.enabledOptions.isDisjoint(with: universalSimpleAdvancedOptions) {
                        extendedList.append(networkRule)
                        basicList.append(networkRule)
                    } else if !networkRule.enabledOptions.isDisjoint(with: advancedOptions) {
                        extendedList.append(networkRule)
                    } else {
                        basicList.append(networkRule)
                    }
                } else {
                    basicList.append(networkRule)
                }
            } else if let cosmeticRule = ruleItem as? CosmeticRule {
                let requiresAdvanced = cosmeticRule.isScript || cosmeticRule.isExtendedCss || cosmeticRule.isInjectCss

                if requiresAdvanced {
                    extendedList.append(cosmeticRule)
                } else {
                    basicList.append(cosmeticRule)
                }
            }
        }

        return (basicList, extendedList)
    }
}
