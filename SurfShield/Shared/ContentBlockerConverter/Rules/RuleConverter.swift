import Foundation

public enum RuleConverter {
    private static let uboScriptletPattern = "#@?#\\+js"
    // swiftlint:disable:next force_try
    private static let uboScriptletRegex = try! NSRegularExpression(
        pattern: uboScriptletPattern,
        options: [.caseInsensitive]
    )
    // swiftlint:disable:next force_try
    private static let argumentSentenceRegex = try! NSRegularExpression(
        pattern: #"'.*?'|".*?"|\S+"#,
        options: [.caseInsensitive]
    )
    private static let denyallowModifierName = "denyallow="
    private static let domainModifierName = "domain="
    private static let importantModifierName = "important"

    private static let modifierDelimiter = "$"
    private static let exceptionMarker = "@@"
    private static let exceptionDomainSuffix = exceptionMarker + "||"

    private static let uboScriptletBlockMask = "##+js"
    private static let uboScriptletExcepMask = "#@#+js"
    private static let uboCssStyleMask = ":style("

    private static let adgCssPattern = "#@?\\$#.+?\\s*\\{.*\\}\\s*$"
    // swiftlint:disable:next force_try
    private static let adgCssRegex = try! NSRegularExpression(
        pattern: adgCssPattern,
        options: [.caseInsensitive]
    )

    private static let adguardScriptletBlockTemplate = "${domains}#%#//scriptlet(${args})"
    private static let adguardScriptletExcepTemplate = "${domains}#@%#//scriptlet(${args})"

    public static func convertRule(ruleText: String) -> [String?] {
        guard !ruleText.isEmpty else {
            return [ruleText]
        }

        let markerDetails = CosmeticRuleMarker.findCosmeticRuleMarker(ruleText: ruleText)

        if let ruleMarker = markerDetails.marker, markerDetails.index != -1 {
            if checkIsUboScriptletRule(rule: ruleText, marker: ruleMarker, markerIndex: markerDetails.index) {
                return [transformUboScriptlet(rule: ruleText)]
            }

            if checkIsAbpSnippetRule(rule: ruleText, marker: ruleMarker, markerIndex: markerDetails.index) {
                return transformAbpSnippet(
                    ruleText: ruleText,
                    marker: ruleMarker,
                    markerIndex: markerDetails.index
                )
            }

            if ruleMarker == .elementHiding || ruleMarker == .elementHidingException {
                if let convertedUboCss = transformUboCssStyle(ruleText: ruleText) {
                    return [convertedUboCss]
                }
            }
        } else {
            if let convertedDenyallow = transformDenyallowRule(ruleText: ruleText) {
                return convertedDenyallow
            }
        }

        return [ruleText]
    }

    private static func checkIsUboScriptletRule(
        rule: String,
        marker: CosmeticRuleMarker,
        markerIndex: Int
    ) -> Bool {
        if marker != .elementHiding && marker != .elementHidingException {
            return false
        }

        let contentStartIndex = rule.utf8.index(rule.startIndex, offsetBy: markerIndex)
        let ruleContent = rule[contentStartIndex...]

        return
            (ruleContent.utf8.starts(with: Self.uboScriptletBlockMask.utf8)
                || ruleContent.utf8.starts(with: Self.uboScriptletExcepMask.utf8))
            && String(ruleContent).firstMatch(for: Self.uboScriptletRegex) != nil
    }

    private static func transformUboScriptlet(rule: String) -> String? {
        guard let matchRange = rule.firstMatch(for: Self.uboScriptletRegex) else {
            return nil
        }

        let scriptletMask = rule[matchRange]
        let domainScope = String(rule[..<matchRange.lowerBound])

        let ruleTemplate: String
        if scriptletMask.utf8.contains(Chars.AT_CHAR) {
            ruleTemplate = Self.adguardScriptletExcepTemplate
        } else {
            ruleTemplate = Self.adguardScriptletBlockTemplate
        }

        guard let argumentString: String = retrieveArgumentsString(from: rule) else {
            return nil
        }

        var argumentParts = argumentString.components(separatedBy: ", ")
        if argumentParts.count == 1 {
            argumentParts = argumentString.components(separatedBy: ",")
        }

        var processedArgs: [String] = []
        for index in (0..<argumentParts.count) {
            var argument = argumentParts[index]
            if index == 0 {
                argument = "ubo-" + argument
            }

            processedArgs.append(wrapInDoubleQuotes(str: argument))
        }

        let argsListString = processedArgs.joined(separator: ", ")

        return replacePlaceholders(str: ruleTemplate, domains: domainScope, args: argsListString)
    }

    private static func checkIsAbpSnippetRule(
        rule: String,
        marker: CosmeticRuleMarker,
        markerIndex: Int
    ) -> Bool {
        if marker != .css && marker != .cssException {
            return false
        }

        let contentStartIndex = rule.utf8.index(rule.startIndex, offsetBy: markerIndex)
        let ruleContent = String(rule[contentStartIndex...])

        return ruleContent.firstMatch(for: Self.adgCssRegex) == nil
    }

    private static func transformAbpSnippet(
        ruleText: String,
        marker: CosmeticRuleMarker,
        markerIndex: Int
    ) -> [String] {
        let ruleTemplate =
            marker == .css ? Self.adguardScriptletBlockTemplate : Self.adguardScriptletExcepTemplate

        let maskStartIndex = ruleText.utf8.index(ruleText.startIndex, offsetBy: markerIndex)
        let domainScope = String(ruleText[..<maskStartIndex])

        let argsStartIndex = ruleText.utf8.index(
            ruleText.startIndex,
            offsetBy: markerIndex + marker.rawValue.utf8.count
        )
        let argumentString = ruleText[argsStartIndex...]

        let snippetList = argumentString.components(separatedBy: "; ")

        var convertedRules: [String] = []

        for snippet in snippetList {
            var sentenceParts: [String] = []
            let matchedParts = snippet.matches(regex: Self.argumentSentenceRegex)
            for part in matchedParts where !part.isEmpty {
                sentenceParts.append(part)
            }

            var wrappedArgs: [String] = []
            for (index, sentence) in sentenceParts.enumerated() {
                let wrappedSentence = index == 0 ? "abp-" + sentence : sentence
                wrappedArgs.append(wrapInDoubleQuotes(str: wrappedSentence))
            }

            let converted = replacePlaceholders(
                str: ruleTemplate,
                domains: domainScope,
                args: wrappedArgs.joined(separator: ", ")
            )
            convertedRules.append(converted)
        }

        return convertedRules
    }

    private static func transformUboCssStyle(ruleText: String) -> String? {
        guard ruleText.utf8.includes(Self.uboCssStyleMask.utf8) else {
            return nil
        }

        let markerMap: [String: String] = [
            "##": "#$#",
            "#@#": "#@$#",
            "#?#": "#$?#",
            "#@?#": "#@$?#",
        ]

        for (uboMarker, adgReplacement) in markerMap
        where ruleText.utf8.includes(uboMarker.utf8) {
            let markerReplacedRule = ruleText.replacingOccurrences(of: uboMarker, with: adgReplacement)
            let finalResult = markerReplacedRule.replacingOccurrences(
                of: Self.uboCssStyleMask,
                with: " { "
            )
            return finalResult.dropLast() + " }"
        }

        return nil
    }

    private static func transformDenyallowRule(ruleText: String) -> [String]? {
        guard ruleText.utf8.includes(Self.denyallowModifierName.utf8) else {
            return nil
        }

        guard let ruleComponents = try? NetworkRuleParser.parseRuleText(ruleText: ruleText) else {
            return nil
        }

        guard let optionsString = ruleComponents.options else {
            return nil
        }

        if ruleComponents.pattern.utf8.first == Chars.PIPE
            || !optionsString.utf8.includes(Self.domainModifierName.utf8)
        {
            return nil
        }

        var patternElement: String = ruleComponents.pattern
        if patternElement.starts(with: "/") {
            patternElement = String(patternElement.dropFirst())
        }

        let isGeneric = patternElement.isEmpty || patternElement == "*"

        let allOptions = optionsString.components(separatedBy: ",")
        guard
            let denyallowOption = allOptions.first(where: {
                $0.contains(Self.denyallowModifierName)
            })
        else {
            return nil
        }

        let domainListString = denyallowOption.replace(
            target: Self.denyallowModifierName,
            withString: ""
        )
        let denyallowDomains = domainListString.components(separatedBy: "|")

        for domain in denyallowDomains {
            if domain.hasPrefix("~") || domain.contains("*") {
                return nil
            }
        }

        let remainingOptions: [String] = allOptions.filter { optionPart in
            optionPart != denyallowOption
        }
        let remainingOptionsString = remainingOptions.joined(separator: ",")

        var resultingRules: [String] = []

        let blockPrefix: String = ruleComponents.whitelist ? "@@" : ""
        let excepPrefix: String = ruleComponents.whitelist ? "||" : Self.exceptionDomainSuffix
        let excepSuffix: String =
            ruleComponents.whitelist ? "," + Self.importantModifierName : ""

        let blockingRule =
            blockPrefix + ruleComponents.pattern + Self.modifierDelimiter
            + remainingOptionsString
        resultingRules.append(blockingRule)

        for domain in denyallowDomains {
            if !isGeneric {
                let exceptionPath = domain + "/" + patternElement
                let pathExceptionRule =
                    excepPrefix + exceptionPath + Self.modifierDelimiter
                    + remainingOptionsString + excepSuffix
                resultingRules.append(pathExceptionRule)

                let exceptionPathWide = domain + "/*/" + patternElement
                let widePathExceptionRule =
                    excepPrefix + exceptionPathWide + Self.modifierDelimiter
                    + remainingOptionsString + excepSuffix
                resultingRules.append(widePathExceptionRule)
            } else {
                let domainExceptionRule =
                    excepPrefix + domain + Self.modifierDelimiter
                    + remainingOptionsString + excepSuffix
                resultingRules.append(domainExceptionRule)
            }
        }

        return resultingRules
    }

    private static func retrieveArgumentsString(from ruleString: String) -> String? {
        guard var startIndex = ruleString.utf8.firstIndex(of: Chars.BRACKET_OPEN),
            let endIndex = ruleString.utf8.lastIndex(of: Chars.BRACKET_CLOSE)
        else {
            return nil
        }

        ruleString.utf8.formIndex(after: &startIndex)
        guard startIndex < endIndex else {
            return nil
        }

        return String(ruleString[startIndex..<endIndex])
    }

    private static func wrapInDoubleQuotes(str: String) -> String {
        var modifiedString = str

        if str.utf8.count <= 1 {
            modifiedString = modifiedString.replacingOccurrences(of: "\"", with: "\\\"")
        } else if str.utf8.first == Chars.QUOTE_SINGLE && str.utf8.last == Chars.QUOTE_SINGLE {
            modifiedString =
                modifiedString
                .trimmingCharacters(in: Chars.TRIM_SINGLE_QUOTE)
                .replacingOccurrences(of: "\"", with: "\\\"")
        } else if str.utf8.first == Chars.QUOTE_DOUBLE && str.utf8.last == Chars.QUOTE_DOUBLE {
            modifiedString =
                modifiedString
                .trimmingCharacters(in: Chars.TRIM_DOUBLE_QUOTE)
                .replacingOccurrences(of: "'", with: "\'")
        }

        return "\"\(modifiedString)\""
    }

    private static func replacePlaceholders(str: String, domains: String, args: String) -> String {
        var result = str.replace(target: "${domains}", withString: domains)
        result = result.replace(target: "${args}", withString: args)

        return result
    }
}
