import Foundation

public enum SimpleRegex {
    private static let startUrlPattern: [UInt8] = Array(#"^[^:]+://+([^:/]+\.)?"#.utf8)
    private static let defaultSeparatorPattern: [UInt8] = Array("[/:&?]".utf8)
    private static let endSeparatorPattern: [UInt8] = Array("[/:&?]?".utf8)
    private static let domainSeparatorPattern: [UInt8] = Array("[/:]".utf8)
    private static let matchAllSymbols = ".*"
    private static let matchAllSymbolsBytes: [UInt8] = Array(".*".utf8)
    private static let startOfStringBytes: [UInt8] = Array("^".utf8)
    private static let endOfStringBytes: [UInt8] = Array("$".utf8)

    public static func createRegexText(pattern: String) throws -> String {
        if pattern.isEmpty || pattern == "||" || pattern == "|" || pattern == "*" {
            return matchAllSymbols
        }

        var resultBytes: [UInt8] = []
        let patternUtf8 = pattern.utf8
        var currentByteIndex = patternUtf8.startIndex
        var isDomainTargeting = false

        @inline(__always)
        func getNextByte() -> UInt8? {
            let nextIndex = patternUtf8.index(after: currentByteIndex)
            guard nextIndex < patternUtf8.endIndex else { return nil }
            return patternUtf8[nextIndex]
        }

        while currentByteIndex < patternUtf8.endIndex {
            let byte = patternUtf8[currentByteIndex]

            switch byte {
            case UInt8(ascii: "."), UInt8(ascii: "+"), UInt8(ascii: "?"), UInt8(ascii: "$"),
                UInt8(ascii: "{"), UInt8(ascii: "}"), UInt8(ascii: "("), UInt8(ascii: ")"),
                UInt8(ascii: "["), UInt8(ascii: "]"), UInt8(ascii: "/"), UInt8(ascii: "\\"):

                resultBytes.append(UInt8(ascii: "\\"))
                resultBytes.append(byte)

                if byte != UInt8(ascii: ".") {
                    isDomainTargeting = false
                }
            case UInt8(ascii: "|"):
                let nextByte = getNextByte()

                if currentByteIndex == patternUtf8.startIndex {
                    if nextByte == UInt8(ascii: "|") {
                        resultBytes.append(contentsOf: startUrlPattern)
                        isDomainTargeting = true
                        currentByteIndex = patternUtf8.index(after: currentByteIndex)
                    } else {
                        resultBytes.append(contentsOf: startOfStringBytes)
                    }
                } else if nextByte == nil {
                    resultBytes.append(contentsOf: endOfStringBytes)
                } else {
                    resultBytes.append(UInt8(ascii: "\\"))
                    resultBytes.append(byte)
                }
            case UInt8(ascii: "^"):
                let nextByte = getNextByte()

                if isDomainTargeting {
                    resultBytes.append(contentsOf: domainSeparatorPattern)
                    isDomainTargeting = false
                } else if nextByte == nil {
                    resultBytes.append(contentsOf: endSeparatorPattern)
                } else {
                    resultBytes.append(contentsOf: defaultSeparatorPattern)
                }
            case UInt8(ascii: "*"):
                resultBytes.append(contentsOf: matchAllSymbolsBytes)
                isDomainTargeting = false
            default:
                if byte > 127 {
                    throw SyntaxError.invalidPattern(
                        message: "Non ASCII characters are not supported"
                    )
                } else if byte == UInt8(ascii: ":") {
                    isDomainTargeting = false
                }

                resultBytes.append(byte)
            }

            currentByteIndex = patternUtf8.index(after: currentByteIndex)
        }

        if let finalString = String(bytes: resultBytes, encoding: .utf8) {
            return finalString
        }

        return matchAllSymbols
    }

    public static func isRegexPattern(_ pattern: String) -> Bool {
        pattern.utf8.count > 2 && pattern.utf8.first == Chars.SLASH
            && pattern.utf8.last == Chars.SLASH
    }

    public static func extractRegex(_ pattern: String) -> String? {
        if !isRegexPattern(pattern) {
            return nil
        }

        let startInd = pattern.utf8.index(after: pattern.utf8.startIndex)
        let endInd = pattern.utf8.index(before: pattern.utf8.endIndex)

        return String(pattern[startInd..<endInd])
    }
}
