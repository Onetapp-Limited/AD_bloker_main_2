import Foundation

public struct ConversionResult: CustomStringConvertible {
    public static let EMPTY_RESULT_JSON: String =
        "[{\"trigger\": {\"url-filter\": \".*\",\"if-domain\": [\"domain.com\"]},\"action\":{\"type\": \"ignore-previous-rules\"}}]"

    static func createEmptyResult() -> ConversionResult {
        return ConversionResult(
            sourceRulesCount: 0,
            sourceSafariCompatibleRulesCount: 0,
            safariRulesCount: 0,
            advancedRulesCount: 0,
            discardedSafariRules: 0,
            errorsCount: 0,
            safariRulesJSON: self.EMPTY_RESULT_JSON,
            advancedRulesText: nil
        )
    }

    public let sourceRulesCount: Int

    public let sourceSafariCompatibleRulesCount: Int

    public let safariRulesCount: Int

    public let advancedRulesCount: Int

    public let discardedSafariRules: Int

    public let errorsCount: Int

    public let safariRulesJSON: String

    public let advancedRulesText: String?

    public var description: String {
        return """
            ## Conversion status

            * Source rules count: \(self.sourceRulesCount)
            * Source rules compatible with Safari: \(self.sourceSafariCompatibleRulesCount)
            * Failed to convert: \(self.errorsCount)
            * Discarded due to limits: \(self.discardedSafariRules)

            ## Result

            * Safari JSON rules count: \(self.safariRulesCount)
            * JSON size: \(self.safariRulesJSON.utf8.count)
            * Advanced rules count: \(self.advancedRulesCount)
            * Advanced rules size: \(self.advancedRulesText?.utf8.count ?? 0)
            """
    }
}

extension ConversionResult: Encodable {}
