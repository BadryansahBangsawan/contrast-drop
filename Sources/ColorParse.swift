import Foundation

struct RGBColor: Equatable {
    let r: Int
    let g: Int
    let b: Int

    var hex: String {
        String(format: "#%02X%02X%02X", r, g, b)
    }
}

enum ColorParse {
    enum Outcome {
        case parsed(RGBColor)
        case invalid
        case regexFailed
    }

    static func parse(_ raw: String) -> Outcome {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .invalid
        }
        switch parseHex(trimmed) {
        case .parsed(let color):
            return .parsed(color)
        case .regexFailed:
            return .regexFailed
        case .invalid:
            break
        }
        return parseRGB(trimmed)
    }

    static func storedRRGGBB(_ raw: String) -> RGBColor? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == 7, trimmed.hasPrefix("#") else { return nil }
        let digits = String(trimmed.dropFirst())
        guard digits.count == 6 else { return nil }
        guard let r = Int(digits.prefix(2), radix: 16),
              let g = Int(digits.dropFirst(2).prefix(2), radix: 16),
              let b = Int(digits.dropFirst(4).prefix(2), radix: 16)
        else {
            return nil
        }
        return RGBColor(r: r, g: g, b: b)
    }

    private static func parseHex(_ trimmed: String) -> Outcome {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: #"^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$"#)
        } catch {
            return .regexFailed
        }
        let nsRange = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: nsRange),
              match.numberOfRanges >= 2,
              let digitsRange = Range(match.range(at: 1), in: trimmed)
        else {
            return .invalid
        }
        let hex = String(trimmed[digitsRange])
        switch hex.count {
        case 3:
            let chars = Array(hex)
            guard let r = Int(String(repeating: String(chars[0]), count: 2), radix: 16),
                  let g = Int(String(repeating: String(chars[1]), count: 2), radix: 16),
                  let b = Int(String(repeating: String(chars[2]), count: 2), radix: 16)
            else {
                return .invalid
            }
            return .parsed(RGBColor(r: r, g: g, b: b))
        case 6, 8:
            guard let r = Int(hex.prefix(2), radix: 16),
                  let g = Int(hex.dropFirst(2).prefix(2), radix: 16),
                  let b = Int(hex.dropFirst(4).prefix(2), radix: 16)
            else {
                return .invalid
            }
            return .parsed(RGBColor(r: r, g: g, b: b))
        default:
            return .invalid
        }
    }

    private static func parseRGB(_ trimmed: String) -> Outcome {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: #"^(rgba|rgb)\s*\(\s*([^)]*)\s*\)$"#, options: [.caseInsensitive])
        } catch {
            return .regexFailed
        }
        let nsRange = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: nsRange),
              match.numberOfRanges >= 3,
              let kindRange = Range(match.range(at: 1), in: trimmed),
              let innerRange = Range(match.range(at: 2), in: trimmed)
        else {
            return .invalid
        }
        let kind = trimmed[kindRange].lowercased()
        let inner = String(trimmed[innerRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        if inner.isEmpty {
            return .invalid
        }
        let tokens: [String]
        if inner.contains(",") {
            tokens = inner.split(separator: ",", omittingEmptySubsequences: false).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            tokens = inner.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        }
        if tokens.contains(where: { $0.isEmpty }) {
            return .invalid
        }
        let expected = kind == "rgba" ? 4 : 3
        guard tokens.count == expected else { return .invalid }
        guard let r = parseChannel(tokens[0]),
              let g = parseChannel(tokens[1]),
              let b = parseChannel(tokens[2])
        else {
            return .invalid
        }
        if expected == 4, !isAlphaToken(tokens[3]) {
            return .invalid
        }
        return .parsed(RGBColor(r: r, g: g, b: b))
    }

    private static func parseChannel(_ token: String) -> Int? {
        if token.hasSuffix("%") {
            let number = String(token.dropLast())
            guard let value = Double(number), value >= 0, value <= 100 else { return nil }
            let scaled = Int((value / 100.0 * 255.0).rounded())
            if scaled < 0 { return 0 }
            if scaled > 255 { return 255 }
            return scaled
        }
        guard let value = Int(token), value >= 0, value <= 255 else { return nil }
        return value
    }

    private static func isAlphaToken(_ token: String) -> Bool {
        if token.hasSuffix("%") {
            let number = String(token.dropLast())
            guard let value = Double(number) else { return false }
            return value >= 0 && value <= 100
        }
        guard let value = Double(token) else { return false }
        return value >= 0
    }
}
