import Foundation

public class CosmeticRule: Rule {
    private static let PSEUDO_HAS_TAG = "has"
    private static let PSEUDO_IS_TAG = "is"

    private static let EXTENDED_PSEUDO_TAGS = [
        CosmeticRule.PSEUDO_HAS_TAG,
        CosmeticRule.PSEUDO_IS_TAG,
        "has-text",
        "contains",
        "matches-css",
        "if",
        "if-not",
        "xpath",
        "nth-ancestor",
        "upward",
        "remove",
        "matches-attr",
        "matches-property",
    ]

    private static let EXTENDED_ATTR_TOKEN = "[-ext-"

    private static let ABP_PSEUDO_PREFIX = "-abp-"

    public var content: String = ""

    public var isElemhide = false

    public var isInjectCss = false

    public var isExtendedCss = false

    public var isScript = false

    public var isScriptlet = false

    public var pathModifier: String?

    public var pathRegExpSource: String?

    public override init(
        ruleText: String,
        for version: SafariVersion = SafariVersion.autodetect()
    ) throws {
        try super.init(ruleText: ruleText)

        let markerData = CosmeticRuleMarker.findCosmeticRuleMarker(ruleText: ruleText)
        if markerData.index == -1 {
            throw SyntaxError.invalidRule(message: "Not a cosmetic rule")
        }

        guard let markerType = markerData.marker else {
            throw SyntaxError.invalidRule(message: "Invalid cosmetic rule marker")
        }

        let offsetLength = markerData.index + markerType.rawValue.utf8.count
        let contentStart = ruleText.utf8.index(ruleText.utf8.startIndex, offsetBy: offsetLength)
        self.content = String(ruleText[contentStart...])

        if self.content.isEmpty {
            throw SyntaxError.invalidRule(message: "Rule content is empty")
        }

        switch markerType {
        case .elementHiding,
             .elementHidingExtCSS,
             .elementHidingException,
             .elementHidingExtCSSException:
            self.isElemhide = true
        case .css,
             .cssExtCSS,
             .cssException,
             .cssExtCSSException:
            self.isInjectCss = true
        case .javascript,
             .javascriptException:
            self.isScript = true
        default:
            throw SyntaxError.invalidRule(message: "Unsupported rule type")
        }

        if self.isScript {
            if ScriptletParser.isScriptlet(cosmeticRuleContent: self.content) {
                self.isScriptlet = true
            }
        }

        if markerData.index > 0 {
            let markerStart = ruleText.utf8.index(
                ruleText.utf8.startIndex,
                offsetBy: markerData.index
            )
            let domainList = String(ruleText[..<markerStart])

            if !(domainList.utf8.count == 1 && domainList.utf8.first == Chars.WILDCARD) {
                try setRuleDomains(domainString: domainList)
            }
        }

        isWhiteList = CosmeticRule.checkIsException(marker: markerType)
        isExtendedCss = CosmeticRule.checkIsExtendedCssMarker(marker: markerType)

        if !isExtendedCss
            && CosmeticRule.hasExtendedCssSyntax(ruleContent: self.content, version: version)
        {
            isExtendedCss = true
        }

        if isInjectCss && content.range(of: "url(") != nil {
            throw SyntaxError.invalidRule(message: "Forbidden style in a CSS rule")
        }

        if isWhiteList && pathModifier != nil {
            throw SyntaxError.invalidRule(
                message: "CSS exception rules with $path modifier are not supported"
            )
        }
    }

    private static func hasExtendedCssSyntax(ruleContent: String, version: SafariVersion) -> Bool {
        if ruleContent.utf8.count < 6 {
            return false
        }

        let lastIndex = ruleContent.utf8.count - 1
        var inPseudoSection = false
        var pseudoNameStart = 0

        for index in 0...lastIndex {
            let currentByte = ruleContent.utf8[safeIndex: index]

            switch currentByte {
            case Chars.SQUARE_BRACKET_OPEN:
                if ruleContent.utf8.dropFirst(index).starts(with: CosmeticRule.EXTENDED_ATTR_TOKEN.utf8)
                {
                    return true
                }
            case Chars.COLON:
                inPseudoSection = true
                pseudoNameStart = index + 1
            case Chars.BRACKET_OPEN:
                if inPseudoSection {
                    inPseudoSection = false
                    let pseudoNameEnd = index - 1

                    if pseudoNameEnd > pseudoNameStart {
                        let startIndex = ruleContent.utf8.index(
                            ruleContent.utf8.startIndex,
                            offsetBy: pseudoNameStart
                        )
                        let endIndex = ruleContent.utf8.index(
                            ruleContent.utf8.startIndex,
                            offsetBy: pseudoNameEnd
                        )

                        let pseudoName = String(ruleContent[startIndex...endIndex])

                        if version.isSafari16_4orGreater() && pseudoName == PSEUDO_HAS_TAG
                        {
                            continue
                        }

                        if version.isSafari14orGreater() && pseudoName == PSEUDO_IS_TAG {
                            continue
                        }

                        if pseudoName.utf8.starts(with: CosmeticRule.ABP_PSEUDO_PREFIX.utf8) {
                            return true
                        }

                        if EXTENDED_PSEUDO_TAGS.contains(pseudoName) {
                            return true
                        }
                    }
                }
            default:
                break
            }
        }

        return false
    }

    private static func checkIsException(marker: CosmeticRuleMarker) -> Bool {
        switch marker {
        case .elementHidingException,
             .elementHidingExtCSSException,
             .cssException,
             .cssExtCSSException,
             .javascriptException,
             .htmlException:
            return true
        default:
            return false
        }
    }

    private static func checkIsExtendedCssMarker(marker: CosmeticRuleMarker) -> Bool {
        switch marker {
        case .cssExtCSS,
             .cssExtCSSException,
             .elementHidingExtCSS,
             .elementHidingExtCSSException:
            return true
        default:
            return false
        }
    }

    private func processSingleOption(name: String, value: String) throws {
        switch name {
        case "domain", "from":
            if value.isEmpty {
                throw SyntaxError.invalidModifier(message: "$domain modifier cannot be empty")
            }
            try addDomains(domainsStr: value, separator: Chars.PIPE)
        case "path":
            if value.isEmpty {
                throw SyntaxError.invalidRule(message: "$path modifier cannot be empty")
            }

            pathModifier = value

            guard let pathMod = pathModifier else {
                throw SyntaxError.invalidModifier(message: "Path modifier is nil")
            }

            if let compiledRegex = SimpleRegex.extractRegex(pathMod) {
                pathRegExpSource = compiledRegex
            } else {
                pathRegExpSource = try SimpleRegex.createRegexText(pattern: pathMod)
            }

            guard let finalRegexSource = pathRegExpSource, !finalRegexSource.isEmpty else {
                throw SyntaxError.invalidModifier(message: "Empty regular expression for path")
            }
        default:
            throw SyntaxError.invalidModifier(message: "Unsupported modifier \(name)")
        }
    }

    private func extractAndProcessOptions(domainInput: String) throws -> String? {
        let optionsStart = domainInput.utf8.index(domainInput.utf8.startIndex, offsetBy: 2)
        guard let optionsEnd = domainInput.utf8.lastIndex(of: Chars.SQUARE_BRACKET_CLOSE) else {
            throw SyntaxError.invalidModifier(message: "Invalid option format")
        }

        if domainInput.utf8.count < 3 || domainInput.utf8[safeIndex: 1] != Chars.DOLLAR {
            throw SyntaxError.invalidModifier(message: "Invalid cosmetic rule modifier")
        }

        let rawOptions = String(domainInput[optionsStart..<optionsEnd])
        let splitOptions = rawOptions.split(delimiter: Chars.COMMA, escapeChar: Chars.BACKSLASH)

        for optionEntry in splitOptions {
            var optionName = optionEntry
            var optionValue = ""

            if let equalsIndex = optionEntry.utf8.firstIndex(of: Chars.EQUALS_SIGN) {
                optionName = String(optionEntry[..<equalsIndex])
                optionValue = String(optionEntry[optionEntry.utf8.index(after: equalsIndex)...])
            }

            try processSingleOption(name: optionName, value: optionValue)
        }

        let remainingDomainsIndex = domainInput.index(after: optionsEnd)
        if remainingDomainsIndex < domainInput.endIndex {
            let remainingDomains = domainInput[remainingDomainsIndex...]
            return String(remainingDomains)
        }

        return nil
    }

    func setRuleDomains(domainString: String) throws {
        if domainString.utf8.first == Chars.SQUARE_BRACKET_OPEN {
            if let leftoverDomains = try extractAndProcessOptions(domainInput: domainString),
                !leftoverDomains.isEmpty
            {
                try addDomains(domainsStr: leftoverDomains, separator: Chars.COMMA)
            }
        } else {
            try addDomains(domainsStr: domainString, separator: Chars.COMMA)
        }
    }
}
