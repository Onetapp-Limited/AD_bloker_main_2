import Foundation

public enum CosmeticRuleMarker: String, CaseIterable {
    case elementHiding = "##"
    case elementHidingException = "#@#"
    case elementHidingExtCSS = "#?#"
    case elementHidingExtCSSException = "#@?#"
    case css = "#$#"
    case cssException = "#@$#"
    case cssExtCSS = "#$?#"
    case cssExtCSSException = "#@$?#"
    case javascript = "#%#"
    case javascriptException = "#@%#"
    case html = "$$"
    case htmlException = "$@$"

    public static func findCosmeticRuleMarker(
        ruleText: String
    ) -> (
        index: Int, marker: CosmeticRuleMarker?
    ) {
        let ruleLength = ruleText.utf8.count
        let maxSearchIndex = ruleLength - 2

        if maxSearchIndex <= 0 {
            return (-1, nil)
        }

        guard let firstByte = ruleText.utf8.first else {
            return (-1, nil)
        }

        if firstByte == Chars.PIPE || firstByte == Chars.AT_CHAR {
            return (-1, nil)
        }

        for searchPosition in 0...maxSearchIndex {
            let currentByte = ruleText.utf8[safeIndex: searchPosition]

            switch currentByte {
            case Chars.HASH:
                let byteNext = ruleText.utf8[safeIndex: searchPosition + 1]
                let byteTwo = (searchPosition + 2 < ruleLength) ? ruleText.utf8[safeIndex: searchPosition + 2] : nil
                let byteThree = (searchPosition + 3 < ruleLength) ? ruleText.utf8[safeIndex: searchPosition + 3] : nil
                let byteFour = (searchPosition + 4 < ruleLength) ? ruleText.utf8[safeIndex: searchPosition + 4] : nil

                switch byteNext {
                case Chars.AT_CHAR:
                    switch byteTwo {
                    case Chars.DOLLAR:
                        if byteThree == Chars.HASH {
                            return (searchPosition, .cssException)
                        } else if byteThree == Chars.QUESTION && byteFour == Chars.HASH {
                            return (searchPosition, .cssExtCSSException)
                        }
                    case Chars.QUESTION:
                        if byteThree == Chars.HASH {
                            return (searchPosition, .elementHidingExtCSSException)
                        }
                    case Chars.PERCENT:
                        if byteThree == Chars.HASH {
                            return (searchPosition, .javascriptException)
                        }
                    case Chars.HASH:
                        return (searchPosition, .elementHidingException)
                    default: break
                    }
                case Chars.DOLLAR:
                    switch byteTwo {
                    case Chars.QUESTION:
                        if byteThree == Chars.HASH {
                            return (searchPosition, .cssExtCSS)
                        }
                    case Chars.HASH:
                        return (searchPosition, .css)
                    default: break
                    }
                case Chars.QUESTION:
                    if byteTwo == Chars.HASH {
                        return (searchPosition, .elementHidingExtCSS)
                    }
                case Chars.PERCENT:
                    if byteTwo == Chars.HASH {
                        return (searchPosition, .javascript)
                    }
                case Chars.HASH:
                    return (searchPosition, .elementHiding)
                default: break
                }

            case Chars.DOLLAR:
                let byteNext = ruleText.utf8[safeIndex: searchPosition + 1]
                let byteTwo = (searchPosition + 2 < ruleLength) ? ruleText.utf8[safeIndex: searchPosition + 2] : nil

                if byteNext == Chars.AT_CHAR && byteTwo == Chars.DOLLAR {
                    return (searchPosition, .htmlException)
                } else if byteNext == Chars.DOLLAR {
                    return (searchPosition, .html)
                }
            default: break
            }
        }

        return (-1, nil)
    }
}
