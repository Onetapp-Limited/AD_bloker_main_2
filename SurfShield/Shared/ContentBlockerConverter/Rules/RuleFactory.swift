import Foundation

public enum RuleFactory {
    public static func createRules(
        lines: [String],
        for version: SafariVersion,
        errorsCounter: ErrorsCounter? = nil
    ) -> [Rule] {
        var collectedRules: [Rule] = []

        for line in lines {
            var ruleLine = line
            if !ruleLine.isContiguousUTF8 {
                ruleLine.makeContiguousUTF8()
            }

            ruleLine = ruleLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if ruleLine.isEmpty || RuleFactory.checkIfComment(ruleText: ruleLine) {
                continue
            }

            let convertedLines = RuleConverter.convertRule(ruleText: ruleLine)
            for convertedLine in convertedLines where convertedLine != nil {
                do {
                    if let ruleText = convertedLine,
                        let rule = try RuleFactory.createRule(ruleText: ruleText, for: version)
                    {
                        collectedRules.append(rule)
                    }
                } catch {
                    errorsCounter?.add()
                }
            }
        }

        return collectedRules
    }

    public static func filterOutExceptions(from rules: [Rule], version: SafariVersion) -> [Rule] {
        var networkRulesList: [NetworkRule] = []
        var cosmeticRulesList: [CosmeticRule] = []

        var badfilterMap: [String: [NetworkRule]] = [:]
        var cosmeticExcepMap: [String: [CosmeticRule]] = [:]

        var finalResult: [Rule] = []

        for rule in rules {
            if let networkRule = rule as? NetworkRule {
                if networkRule.isBadfilter {
                    badfilterMap[networkRule.urlRuleText, default: []].append(networkRule)
                } else {
                    networkRulesList.append(networkRule)
                }
            } else if let cosmeticRule = rule as? CosmeticRule {
                if cosmeticRule.isWhiteList {
                    cosmeticExcepMap[cosmeticRule.content, default: []].append(cosmeticRule)
                } else {
                    cosmeticRulesList.append(cosmeticRule)
                }
            }
        }

        finalResult += RuleFactory.processBadFilter(
            rules: networkRulesList,
            badfilterRules: badfilterMap
        )
        finalResult += RuleFactory.processCosmeticExceptions(
            rules: cosmeticRulesList,
            cosmeticExceptions: cosmeticExcepMap,
            version: version
        )

        return finalResult
    }

    public static func createRule(ruleText: String, for version: SafariVersion) throws -> Rule? {
        do {
            if ruleText.isEmpty || RuleFactory.checkIfComment(ruleText: ruleText) {
                return nil
            }

            if ruleText.utf8.count < 3 {
                throw SyntaxError.invalidRule(message: "The rule is too short")
            }

            if RuleFactory.checkIfCosmetic(ruleText: ruleText) {
                return try CosmeticRule(ruleText: ruleText, for: version)
            }

            return try NetworkRule(ruleText: ruleText, for: version)
        } catch {
            Logger.log(
                "(RuleFactory) - Unexpected error: \(error) while creating rule from: \(String(describing: ruleText))"
            )
            throw error
        }
    }

    private static func processBadFilter(
        rules: [NetworkRule],
        badfilterRules: [String: [NetworkRule]]
    ) -> [Rule] {
        var filteredRules: [Rule] = []
        for rule in rules {
            let negatingRule = badfilterRules[rule.urlRuleText]?.first {
                $0.negatesBadfilter(specifiedRule: rule)
            }
            if negatingRule == nil {
                filteredRules.append(rule)
            }
        }

        return filteredRules
    }

    private static func processCosmeticExceptions(
        rules: [CosmeticRule],
        cosmeticExceptions: [String: [CosmeticRule]],
        version: SafariVersion
    ) -> [Rule] {
        var modifiedRules: [Rule] = []

        for rule in rules {
            if let exceptionRules = cosmeticExceptions[rule.content] {
                if let newRule = applyCosmeticDomainRestrictions(
                    baseRule: rule,
                    exceptionRules: exceptionRules,
                    version: version
                ) {
                    modifiedRules.append(newRule)
                }
            } else {
                modifiedRules.append(rule)
            }
        }

        return modifiedRules
    }

    private static func applyCosmeticDomainRestrictions(
        baseRule: CosmeticRule,
        exceptionRules: [CosmeticRule],
        version: SafariVersion
    ) -> CosmeticRule? {
        for exceptionRule in exceptionRules {
            if exceptionRule.permittedDomains.isEmpty {
                return nil
            }

            for domainToRestrict in exceptionRule.permittedDomains {
                if !baseRule.permittedDomains.isEmpty {
                    baseRule.permittedDomains.removeAll { permittedDomain in
                        DomainUtils.isDomainOrSubdomain(candidate: permittedDomain, domain: domainToRestrict)
                    }

                    if baseRule.permittedDomains.isEmpty {
                        return nil
                    }

                    if version.isSafari16_4orGreater() && !baseRule.restrictedDomains.contains(domainToRestrict) {
                        let canRestrict = baseRule.permittedDomains.contains { permittedDomain in
                            DomainUtils.isDomainOrSubdomain(candidate: domainToRestrict, domain: permittedDomain)
                        }

                        if canRestrict {
                            baseRule.restrictedDomains.append(domainToRestrict)
                        }
                    }
                } else if !baseRule.restrictedDomains.contains(domainToRestrict) {
                    baseRule.restrictedDomains.append(domainToRestrict)
                }
            }
        }

        return baseRule
    }

    private static func checkIfCosmetic(ruleText: String) -> Bool {
        let markerDetails = CosmeticRuleMarker.findCosmeticRuleMarker(ruleText: ruleText)
        return markerDetails.index != -1
    }

    private static func checkIfComment(ruleText: String) -> Bool {
        switch ruleText.utf8.first {
        case Chars.EXCLAMATION:
            return true
        case Chars.HASH:
            if ruleText.utf8.count == 1 {
                return true
            }
            let nextByte = ruleText.utf8[ruleText.utf8.index(after: ruleText.utf8.startIndex)]
            if nextByte == Chars.WHITESPACE {
                return true
            }

            return false
        default:
            return false
        }
    }
}
