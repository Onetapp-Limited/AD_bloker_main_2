import Foundation

public enum SafariRegex {
    public static func isSupported(pattern: String) -> Result<Void, Error> {
        let patternBytes = pattern.utf8
        var currentPosition = patternBytes.startIndex
        let finalPosition = patternBytes.endIndex
        var bracketStack: [UInt8] = []
        var allowQuantifier = false

        @inline(__always)
        func isASCIICharacter(_ byte: UInt8) -> Bool {
            return byte < 128
        }

        @inline(__always)
        func insideCharacterSet() -> Bool {
            bracketStack.last == UInt8(ascii: "[")
        }

        @inline(__always)
        func getNextByte() -> UInt8? {
            let nextIndex = patternBytes.index(after: currentPosition)
            guard nextIndex < finalPosition else { return nil }
            return patternBytes[nextIndex]
        }

        @inline(__always)
        func getPreviousByte() -> UInt8? {
            guard currentPosition > patternBytes.startIndex else { return nil }
            let previousIndex = patternBytes.index(before: currentPosition)
            return patternBytes[previousIndex]
        }

        while currentPosition < finalPosition {
            let currentByte = patternBytes[currentPosition]

            if !isASCIICharacter(currentByte) {
                return .failure(SafariRegexError.nonASCII(message: "Detected non-standard character"))
            }

            switch currentByte {
            case UInt8(ascii: "\\"):
                guard let next = getNextByte() else {
                    return .failure(
                        SafariRegexError.invalidRegex(message: "Incomplete escape sequence at end")
                    )
                }

                switch next {
                case UInt8(ascii: "."), UInt8(ascii: "*"), UInt8(ascii: "+"), UInt8(ascii: "?"),
                    UInt8(ascii: "/"), UInt8(ascii: "["), UInt8(ascii: "]"), UInt8(ascii: "("),
                    UInt8(ascii: ")"), UInt8(ascii: "|"), UInt8(ascii: "{"), UInt8(ascii: "}"),
                    UInt8(ascii: "^"), UInt8(ascii: "$"), UInt8(ascii: "\\"):
                    currentPosition = patternBytes.index(currentPosition, offsetBy: 2)
                    allowQuantifier = true
                    continue
                default:
                    return .failure(
                        SafariRegexError.unsupportedMetaCharacter(
                            message: "Invalid character following backslash"
                        )
                    )
                }

            case UInt8(ascii: "("):
                if !insideCharacterSet() {
                    bracketStack.append(currentByte)
                    allowQuantifier = false
                }

            case UInt8(ascii: "["):
                bracketStack.append(currentByte)
                allowQuantifier = false

            case UInt8(ascii: ")"):
                if !insideCharacterSet() {
                    guard let last = bracketStack.popLast(), last == UInt8(ascii: "(") else {
                        return .failure(
                            SafariRegexError.unbalancedParentheses(message: "Mismatched grouping symbols")
                        )
                    }
                }
                allowQuantifier = true

            case UInt8(ascii: "]"):
                guard let last = bracketStack.popLast(), last == UInt8(ascii: "[") else {
                    return .failure(
                        SafariRegexError.unbalancedParentheses(
                            message: "Mismatched character set brackets"
                        )
                    )
                }
                allowQuantifier = true

            case UInt8(ascii: "^"):
                if currentPosition != patternBytes.startIndex && !insideCharacterSet() {
                    return .failure(
                        SafariRegexError.invalidRegex(
                            message: "Start-of-line anchor misplaced"
                        )
                    )
                }
                allowQuantifier = false

            case UInt8(ascii: "$"):
                let next = getNextByte()
                if next != nil && !insideCharacterSet() {
                    return .failure(
                        SafariRegexError.invalidRegex(
                            message: "End-of-line anchor misplaced"
                        )
                    )
                }
                allowQuantifier = false

            case UInt8(ascii: "|"):
                if !insideCharacterSet() {
                    return .failure(
                        SafariRegexError.pipeCondition(message: "Alternation operator is not allowed")
                    )
                }

            case UInt8(ascii: "{"), UInt8(ascii: "}"):
                if !insideCharacterSet() {
                    return .failure(
                        SafariRegexError.digitRange(message: "Explicit repetition range not allowed")
                    )
                }

            case UInt8(ascii: "*"), UInt8(ascii: "+"), UInt8(ascii: "?"):
                if !allowQuantifier && !insideCharacterSet() {
                    return .failure(
                        SafariRegexError.unquantifiableCharacter(message: "Quantifier applies to nothing")
                    )
                }
                allowQuantifier = false
            default:
                allowQuantifier = true
            }

            currentPosition = patternBytes.index(after: currentPosition)
        }

        if !bracketStack.isEmpty {
            return .failure(
                SafariRegexError.unbalancedParentheses(message: "Remaining open grouping symbols")
            )
        }

        return .success(())
    }
}
