import Foundation

public class Rule {
    public let ruleText: String

    public var isWhiteList = false
    public var isImportant = false

    public var permittedDomains: [String] = []
    public var restrictedDomains: [String] = []

    init(ruleText: String, for version: SafariVersion = SafariVersion.autodetect()) throws {
        self.ruleText = ruleText
    }

    func addDomains(domainsStr: String, separator: UInt8) throws {
        let domainListUtf8 = domainsStr.utf8
        var currentPosition = domainListUtf8.startIndex
        var currentDomainStart = currentPosition
        var nonASCIIEncountered = false
        var isDomainRestricted = false

        @inline(__always)
        func processAndAddDomain() throws {
            if currentDomainStart == currentPosition {
                throw SyntaxError.invalidModifier(
                    message: "Empty domain"
                )
            }

            var domainString = String(domainsStr[currentDomainStart..<currentPosition])

            if domainString.utf8.count < 2 {
                throw SyntaxError.invalidModifier(
                    message: "Domain is too short: \(domainString)"
                )
            }

            if nonASCIIEncountered, let encodedDomain = domainString.idnaEncoded {
                domainString = encodedDomain
            }

            if domainString.utf8.first == Chars.SLASH && domainString.utf8.last == Chars.SLASH {
                throw SyntaxError.invalidModifier(
                    message: "Using regular expression for domain modifier is not supported"
                )
            }

            if isDomainRestricted {
                restrictedDomains.append(domainString)
            } else {
                permittedDomains.append(domainString)
            }
        }

        while currentPosition < domainListUtf8.endIndex {
            let byte = domainListUtf8[currentPosition]

            switch byte {
            case separator:
                try processAndAddDomain()

                currentDomainStart = domainListUtf8.index(after: currentPosition)
                nonASCIIEncountered = false
                isDomainRestricted = false
            case UInt8(ascii: "~"):
                if currentDomainStart != currentPosition {
                    throw SyntaxError.invalidModifier(
                        message: "Unexpected tilda character"
                    )
                }
                isDomainRestricted = true

                currentDomainStart = domainListUtf8.index(after: currentPosition)
            default:
                if byte > 127 {
                    nonASCIIEncountered = true
                }
            }

            currentPosition = domainListUtf8.index(after: currentPosition)
        }

        try processAndAddDomain()
    }
}
