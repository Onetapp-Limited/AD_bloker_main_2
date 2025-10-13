import Foundation

public enum NetworkRuleParser {
    public struct BasicRuleParts {
        public var pattern: String = ""
        public var options: String?
        public var whitelist = false
    }
    
    private static let whiteListMaskUtf8 = [Chars.AT_CHAR, Chars.AT_CHAR]
    private static let domainValidationRegex = try! NSRegularExpression(
        pattern: "^[a-zA-Z0-9][a-zA-Z0-9-.]*[a-zA-Z0-9]\\.[a-zA-Z-]{2,}$",
        options: [.caseInsensitive]
    )
    private static let domainPrefixSearcher = PrefixMatcher(prefixes: [
        "||", "@@||", "|https://", "|http://", "@@|https://", "@@|http://",
        "|ws://", "|wss://", "@@|ws://", "@@|wss://",
        "//", "://", "@@//", "@@://", "https://", "http://",
        "@@https://", "@@http://",
    ])

    public static func parseRuleText(ruleText: String) throws -> BasicRuleParts {
        var ruleParts = BasicRuleParts()

        let ruleUtf8 = ruleText.utf8
        var currentSearchIndex = ruleUtf8.endIndex
        var startOffset = ruleUtf8.startIndex
        var delimiterIndex: String.Index?

        if ruleUtf8.isEmpty {
            throw SyntaxError.invalidRule(message: "Rule is too short")
        }

        if ruleUtf8.starts(with: whiteListMaskUtf8) {
            startOffset = ruleUtf8.index(ruleUtf8.startIndex, offsetBy: 2)
            ruleParts.whitelist = true
        }

        @inline(__always)
        func getNextByte() -> UInt8? {
            let nextIndex = ruleUtf8.index(after: currentSearchIndex)
            guard nextIndex < ruleUtf8.endIndex else { return nil }
            return ruleUtf8[nextIndex]
        }

        @inline(__always)
        func getPreviousByte() -> UInt8? {
            guard currentSearchIndex > startOffset else { return nil }
            let previousIndex = ruleUtf8.index(before: currentSearchIndex)
            return ruleUtf8[previousIndex]
        }

        while currentSearchIndex > startOffset {
            currentSearchIndex = ruleUtf8.index(before: currentSearchIndex)

            let byte = ruleUtf8[currentSearchIndex]

            if byte == Chars.DOLLAR {
                if getPreviousByte() != Chars.BACKSLASH && getNextByte() != Chars.SLASH {
                    delimiterIndex = currentSearchIndex
                    break
                }
            }
        }

        var optionsStartIndex = ruleUtf8.endIndex
        if let delimiter = delimiterIndex {
            optionsStartIndex = ruleUtf8.index(after: delimiter)
        }

        if optionsStartIndex == ruleUtf8.endIndex {
            if startOffset == ruleUtf8.startIndex {
                ruleParts.pattern = ruleText
            } else {
                ruleParts.pattern = String(ruleText[startOffset...])
            }
        } else {
            if let delimiter = delimiterIndex {
                ruleParts.pattern = String(ruleText[startOffset..<delimiter])
                ruleParts.options = String(ruleText[optionsStartIndex...])
            }
        }

        return ruleParts
    }

    public static func encodeDomainIfRequired(pattern: String?) -> String? {
        guard let rulePattern = pattern else {
            return nil
        }

        let extracted = searchAndExtractDomain(rulePattern: rulePattern)
        if extracted.domain.isEmpty || extracted.domain.isASCII() {
            return rulePattern
        }

        guard let idnaEncodedDomain = extracted.domain.idnaEncoded else {
            return rulePattern
        }

        return rulePattern.replacingOccurrences(of: extracted.domain, with: idnaEncodedDomain)
    }

    public static func extractDomain(pattern: String) -> (domain: String, patternMatchesPath: Bool)
    {
        let patternUtf8 = pattern.utf8
        let matchResult = domainPrefixSearcher.matchPrefix(in: pattern)

        var domainStartIndex = patternUtf8.startIndex
        if let matchIndex = matchResult.idx {
            domainStartIndex = patternUtf8.index(after: matchIndex)
        }

        var domainEndIndex = patternUtf8.endIndex

        var lastByte: UInt8 = 0
        var byteIndex = domainStartIndex
        while byteIndex < domainEndIndex {
            lastByte = patternUtf8[byteIndex]

            if lastByte == Chars.CARET || lastByte == Chars.SLASH || lastByte == Chars.DOLLAR {
                domainEndIndex = byteIndex
                break
            }

            let isLetter = lastByte >= UInt8(ascii: "a") && lastByte <= UInt8(ascii: "z")
            let isDigit = lastByte >= UInt8(ascii: "0") && lastByte <= UInt8(ascii: "9")
            let nonASCII = lastByte >= 128

            if byteIndex == domainStartIndex {
                if !(isLetter || isDigit || nonASCII) {
                    return ("", false)
                }
            }

            if !isLetter && !isDigit && !nonASCII && lastByte != UInt8(ascii: "-")
                && lastByte != UInt8(ascii: ".")
            {
                return ("", false)
            }

            byteIndex = patternUtf8.index(after: byteIndex)
        }

        if domainStartIndex == domainEndIndex {
            return ("", false)
        }

        if lastByte == UInt8(ascii: ".") {
            return ("", false)
        }

        let extractedDomain = String(pattern[domainStartIndex..<domainEndIndex])
        if extractedDomain.utf8.count < 5 {
            return ("", false)
        }

        let hasPath =
            domainEndIndex < patternUtf8.endIndex && patternUtf8.distance(from: domainEndIndex, to: patternUtf8.endIndex) > 1

        return (extractedDomain, hasPath)
    }

    private static func searchAndExtractDomain(
        rulePattern: String
    ) -> (domain: String, patternMatchesPath: Bool) {
        let extractionResult = extractDomain(pattern: rulePattern)

        if !extractionResult.domain.isEmpty && extractionResult.domain.firstMatch(for: domainValidationRegex) != nil {
            return extractionResult
        }

        return ("", false)
    }
}
