import Foundation

enum SafariRegexError: Error {
    case invalidRegex(message: String)
    case unquantifiableCharacter(message: String)
    case digitRange(message: String)
    case pipeCondition(message: String)
    case nonASCII(message: String)
    case unbalancedParentheses(message: String)
    case unsupportedMetaCharacter(message: String)
}
