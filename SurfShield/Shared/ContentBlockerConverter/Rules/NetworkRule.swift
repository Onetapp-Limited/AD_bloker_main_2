import Foundation

public class NetworkRule: Rule {
    public struct ContentType: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let image = ContentType(rawValue: 1 << 0)
        public static let stylesheet = ContentType(rawValue: 1 << 1)
        public static let script = ContentType(rawValue: 1 << 2)
        public static let media = ContentType(rawValue: 1 << 3)
        public static let xmlHttpRequest = ContentType(rawValue: 1 << 4)
        public static let other = ContentType(rawValue: 1 << 5)
        public static let websocket = ContentType(rawValue: 1 << 6)
        public static let font = ContentType(rawValue: 1 << 7)
        public static let document = ContentType(rawValue: 1 << 8)
        public static let subdocument = ContentType(rawValue: 1 << 9)
        public static let ping = ContentType(rawValue: 1 << 10)

        public static let all: ContentType = [
            .image,
            .stylesheet,
            .script,
            .media,
            .xmlHttpRequest,
            .other,
            .websocket,
            .font,
            .document,
            .subdocument,
            .ping,
        ]
    }

    public struct Option: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let elemhide = Option(rawValue: 1 << 0)
        public static let generichide = Option(rawValue: 1 << 1)
        public static let genericblock = Option(rawValue: 1 << 2)
        public static let specifichide = Option(rawValue: 1 << 3)
        public static let jsinject = Option(rawValue: 1 << 4)
        public static let urlblock = Option(rawValue: 1 << 5)
        public static let content = Option(rawValue: 1 << 6)
        public static let document = Option(rawValue: 1 << 7)
        public static let popup = Option(rawValue: 1 << 8)

        public static let documentLevel: Option = [
            .document,
            .popup,
            .whitelistOnly,
        ]

        public static let whitelistOnly: Option = [
            .jsinject,
            .elemhide,
            .content,
            .urlblock,
            .genericblock,
            .generichide,
            .specifichide,
        ]
    }
    
    public var isDocumentWhiteList = false
    public var isUrlBlock = false
    public var isCssExceptionRule = false
    public var isJsInject = false

    public var isCheckThirdParty = false
    public var isThirdParty = false
    public var isMatchCase = false

    public var isWebSocket = false
    public var isBadfilter = false

    public var permittedContentType: ContentType = .all
    public var restrictedContentType: ContentType = []

    public var enabledOptions: Option = []
    public var disabledOptions: Option = []

    public var urlRuleText: String = ""

    public var urlRegExpSource: String?

    public override init(
        ruleText: String,
        for version: SafariVersion = DEFAULT_SAFARI_VERSION
    ) throws {
        try super.init(ruleText: ruleText)

        let parsedParts = try NetworkRuleParser.parseRuleText(ruleText: ruleText)
        isWhiteList = parsedParts.whitelist

        if let ruleOptions = parsedParts.options, !ruleOptions.isEmpty {
            try configureOptions(options: ruleOptions, version: version)
        }

        urlRuleText = parsedParts.pattern

        if let regex = SimpleRegex.extractRegex(urlRuleText) {
            urlRegExpSource = regex
        } else {
            guard
                let encodedPattern = NetworkRuleParser.encodeDomainIfRequired(pattern: urlRuleText)
            else {
                throw SyntaxError.invalidRule(message: "Failed to encode the domain in \(ruleText)")
            }

            urlRuleText = encodedPattern
            if !urlRuleText.isEmpty {
                urlRegExpSource = try SimpleRegex.createRegexText(pattern: urlRuleText)
            }
        }

        isDocumentWhiteList = isWhiteList && isOptionEnabled(option: .document)
        isUrlBlock = isSingleOption(option: .urlblock) || isSingleOption(option: .genericblock)
        isCssExceptionRule =
            isSingleOption(option: .elemhide) || isSingleOption(option: .generichide)
        isJsInject = isSingleOption(option: .jsinject)

        try ensureRuleValidity(version: version)
    }

    public func isRegexRule() -> Bool {
        return SimpleRegex.isRegexPattern(urlRuleText)
    }

    public func hasContentType(contentType: ContentType) -> Bool {
        return permittedContentType.contains(contentType)
            && !restrictedContentType.contains(contentType)
    }

    public func isContentType(contentType: ContentType) -> Bool {
        return permittedContentType == contentType
    }

    public func hasRestrictedContentType(contentType: ContentType) -> Bool {
        return restrictedContentType.contains(contentType)
    }

    public func negatesBadfilter(specifiedRule: NetworkRule) -> Bool {
        if isWhiteList != specifiedRule.isWhiteList {
            return false
        }

        if urlRuleText != specifiedRule.urlRuleText {
            return false
        }

        if permittedContentType != specifiedRule.permittedContentType {
            return false
        }

        if restrictedContentType != specifiedRule.restrictedContentType {
            return false
        }

        if enabledOptions != specifiedRule.enabledOptions {
            return false
        }

        if disabledOptions != specifiedRule.disabledOptions {
            return false
        }

        if restrictedDomains != specifiedRule.restrictedDomains {
            return false
        }

        if !NetworkRule.compareDomainIntersections(
            firstArray: permittedDomains,
            secondArray: specifiedRule.permittedDomains
        ) {
            return false
        }

        return true
    }

    public func isSingleOption(option: Option) -> Bool {
        return enabledOptions == option
    }

    public func isOptionEnabled(option: Option) -> Bool {
        return self.enabledOptions.contains(option)
    }
    
    // MARK: - Private Implementations (Renamed and cleaned)

    private static func compareDomainIntersections(firstArray: [String], secondArray: [String]) -> Bool {
        if firstArray.isEmpty && secondArray.isEmpty {
            return true
        }

        for element in firstArray where secondArray.contains(element) {
            return true
        }

        return false
    }

    private func setDomainsFromOption(domains: String) throws {
        if domains.isEmpty {
            throw SyntaxError.invalidModifier(message: "$domain cannot be empty")
        }

        try addDomains(domainsStr: domains, separator: Chars.PIPE)
    }

    private func ensureRuleValidity(version: SafariVersion) throws {
        if urlRuleText == "||"
            || urlRuleText == "*"
            || urlRuleText.isEmpty
            || urlRuleText.utf8.count < 3
        {
            if permittedDomains.count < 1 {
                throw SyntaxError.invalidPattern(
                    message:
                        "The rule is too wide, add domain restriction or make the pattern more specific"
                )
            }
        }

        if urlRegExpSource?.isEmpty ?? false {
            throw SyntaxError.invalidPattern(message: "Empty regular expression for URL")
        }

        if !isWhiteList && !enabledOptions.isDisjoint(with: .whitelistOnly) {
            throw SyntaxError.invalidModifier(
                message: "Blocking rule cannot use whitelist-only modifiers"
            )
        }

        if !version.isSafari15orGreater() && !isWhiteList && !isContentType(contentType: .all)
            && hasContentType(contentType: .subdocument) && !isThirdParty
            && permittedDomains.isEmpty
        {
            throw SyntaxError.invalidRule(
                message:
                    "$subdocument blocking rules are allowed only along with third-party or if-domain modifiers"
            )
        }
    }

    private func configureOptions(options: String, version: SafariVersion) throws {
        let optionSegments = options.split(delimiter: Chars.COMMA, escapeChar: Chars.BACKSLASH)

        for optionSegment in optionSegments {
            var modifierName = optionSegment
            var modifierValue = ""

            if let valueDelimiterIndex = optionSegment.utf8.firstIndex(of: Chars.EQUALS_SIGN) {
                modifierName = String(optionSegment[..<valueDelimiterIndex])
                if let valueStartIndex = optionSegment.utf8.index(
                    valueDelimiterIndex,
                    offsetBy: 1,
                    limitedBy: optionSegment.utf8.endIndex
                ) {
                    modifierValue = String(optionSegment[valueStartIndex...])
                }
            }

            try processSingleOption(modifierName: modifierName, modifierValue: modifierValue, version: version)
        }

        if !enabledOptions.isDisjoint(with: .documentLevel) {
            if permittedContentType != .subdocument {
                permittedContentType = .document
            }
        }
    }

    private func processSingleOption(modifierName: String, modifierValue: String, version: SafariVersion) throws
    {
        if modifierName.utf8.first == Chars.UNDERSCORE {
            if modifierName.utf8.allSatisfy({ $0 == Chars.UNDERSCORE }) {
                return
            }
        }

        switch modifierName {
        case "all":
            break
        case "third-party", "~first-party", "3p", "~1p":
            isCheckThirdParty = true
            isThirdParty = true
        case "~third-party", "first-party", "1p", "~3p":
            isCheckThirdParty = true
            isThirdParty = false
        case "match-case":
            isMatchCase = true
        case "~match-case":
            isMatchCase = false
        case "important":
            isImportant = true
        case "popup":
            try updateOptionStatus(option: .popup, value: true)
        case "badfilter":
            isBadfilter = true
        case "domain", "from":
            try setDomainsFromOption(domains: modifierValue)
        case "elemhide", "ehide":
            try updateOptionStatus(option: .elemhide, value: true)
        case "generichide", "ghide":
            try updateOptionStatus(option: .generichide, value: true)
        case "genericblock":
            try updateOptionStatus(option: .genericblock, value: true)
        case "specifichide", "shide":
            try updateOptionStatus(option: .specifichide, value: true)
        case "jsinject":
            try updateOptionStatus(option: .jsinject, value: true)
        case "urlblock":
            try updateOptionStatus(option: .urlblock, value: true)
        case "content":
            try updateOptionStatus(option: .content, value: true)
        case "document", "doc":
            try updateOptionStatus(option: .document, value: true)
        case "script":
            updateRequestType(contentType: .script, enabled: true)
        case "~script":
            updateRequestType(contentType: .script, enabled: false)
        case "stylesheet", "css":
            updateRequestType(contentType: .stylesheet, enabled: true)
        case "~stylesheet", "~css":
            updateRequestType(contentType: .stylesheet, enabled: false)
        case "subdocument", "frame":
            updateRequestType(contentType: .subdocument, enabled: true)
        case "~subdocument", "~frame":
            updateRequestType(contentType: .subdocument, enabled: false)
        case "image":
            updateRequestType(contentType: .image, enabled: true)
        case "~image":
            updateRequestType(contentType: .image, enabled: false)
        case "xmlhttprequest", "xhr":
            updateRequestType(contentType: .xmlHttpRequest, enabled: true)
        case "~xmlhttprequest", "~xhr":
            updateRequestType(contentType: .xmlHttpRequest, enabled: false)
        case "media":
            updateRequestType(contentType: .media, enabled: true)
        case "~media":
            updateRequestType(contentType: .media, enabled: false)
        case "font":
            updateRequestType(contentType: .font, enabled: true)
        case "~font":
            updateRequestType(contentType: .font, enabled: false)
        case "websocket":
            self.isWebSocket = true
            updateRequestType(contentType: .websocket, enabled: true)
        case "~websocket":
            updateRequestType(contentType: .websocket, enabled: false)
        case "other":
            updateRequestType(contentType: .other, enabled: true)
        case "~other":
            updateRequestType(contentType: .other, enabled: false)
        case "ping":
            if version.isSafari14orGreater() {
                updateRequestType(contentType: .ping, enabled: true)
            } else {
                throw SyntaxError.invalidModifier(message: "$ping is not supported")
            }
        case "~ping":
            if version.isSafari14orGreater() {
                updateRequestType(contentType: .ping, enabled: false)
            } else {
                throw SyntaxError.invalidModifier(message: "$~ping is not supported")
            }
        default:
            throw SyntaxError.invalidModifier(message: "Unsupported modifier: \(modifierName)")
        }

        if modifierName != "domain" && modifierName != "from" && !modifierValue.isEmpty {
            throw SyntaxError.invalidModifier(message: "Option \(modifierName) must not have value")
        }
    }

    private func updateRequestType(contentType: ContentType, enabled: Bool) {
        if enabled {
            if permittedContentType == .all {
                permittedContentType = []
            }

            permittedContentType.insert(contentType)
        } else {
            restrictedContentType.insert(contentType)
        }
    }

    private func updateOptionStatus(option: Option, value: Bool) throws {
        if value {
            self.enabledOptions.insert(option)
        } else {
            self.disabledOptions.insert(option)
        }
    }
}
