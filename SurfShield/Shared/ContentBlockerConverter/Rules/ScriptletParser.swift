import Foundation

public enum ScriptletParser {
    public static let SCRIPTLET_MASK = "//scriptlet("
    private static let scriptletPrefixLength = SCRIPTLET_MASK.count

    public static func isScriptlet(cosmeticRuleContent: String) -> Bool {
        return cosmeticRuleContent.utf8.starts(with: SCRIPTLET_MASK.utf8)
    }

    public static func parse(cosmeticRuleContent: String) throws -> (name: String, args: [String]) {
        if !isScriptlet(cosmeticRuleContent: cosmeticRuleContent) {
            throw SyntaxError.invalidRule(message: "Invalid scriptlet")
        }

        let contentUtf8 = cosmeticRuleContent.utf8
        let argumentsStartIndex = contentUtf8.index(contentUtf8.startIndex, offsetBy: scriptletPrefixLength)
        let argumentsEndIndex = contentUtf8.index(contentUtf8.endIndex, offsetBy: -1)
        let argumentsSubstring = cosmeticRuleContent[argumentsStartIndex..<argumentsEndIndex]

        var extractedArguments: [String] = try ScriptletParser.fetchArguments(
            argumentSubstring: argumentsSubstring,
            delimiter: Chars.COMMA
        )

        if extractedArguments.count < 1 || extractedArguments[0].isEmpty {
            throw SyntaxError.invalidRule(message: "Invalid scriptlet params")
        }

        let scriptletName = extractedArguments[0]
        extractedArguments.remove(at: 0)

        return (scriptletName, extractedArguments)
    }

    private static func fetchArguments(argumentSubstring: Substring, delimiter: UInt8) throws -> [String] {
        var finalArguments: [String] = []
        var currentBytes: [UInt8] = []
        var byteIterator = argumentSubstring.utf8.makeIterator()

        var insideQuotes = false
        var activeQuoteChar: UInt8 = 0

        while let currentByte = byteIterator.next() {
            switch currentByte {
            case delimiter where !insideQuotes:
                continue

            case UInt8(ascii: "\""), UInt8(ascii: "'"):
                if !insideQuotes {
                    insideQuotes = true
                    activeQuoteChar = currentByte
                } else if activeQuoteChar == currentByte {
                    insideQuotes = false
                    if let argumentString = String(bytes: currentBytes, encoding: .utf8) {
                        finalArguments.append(argumentString)
                    }
                    currentBytes = []
                } else {
                    currentBytes.append(currentByte)
                }

            case UInt8(ascii: "\\") where insideQuotes:
                guard let nextByte = byteIterator.next() else {
                    throw SyntaxError.invalidRule(
                        message: "Invalid escape sequence in matching arguments"
                    )
                }

                if nextByte == activeQuoteChar || nextByte == UInt8(ascii: "\\") {
                    currentBytes.append(nextByte)
                } else {
                    currentBytes.append(UInt8(ascii: "\\"))
                    currentBytes.append(nextByte)
                }

            case UInt8(ascii: " ") where !insideQuotes:
                continue

            default:
                if insideQuotes {
                    currentBytes.append(currentByte)
                } else {
                    throw SyntaxError.invalidRule(message: "Invalid arguments string")
                }
            }
        }

        if insideQuotes {
            throw SyntaxError.invalidRule(message: "Unmatched quotes in scriptlet arguments")
        }

        if !currentBytes.isEmpty {
            throw SyntaxError.invalidRule(message: "Invalid arguments string")
        }

        return finalArguments
    }
}
