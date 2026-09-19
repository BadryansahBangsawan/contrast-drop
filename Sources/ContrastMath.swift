import Foundation

enum ContrastMath {
    static func relativeLuminance(_ color: RGBColor) -> Double {
        func linear(_ channel: Int) -> Double {
            let c = Double(channel) / 255.0
            if c <= 0.03928 {
                return c / 12.92
            }
            return pow((c + 0.055) / 1.055, 2.4)
        }
        let r = linear(color.r)
        let g = linear(color.g)
        let b = linear(color.b)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    static func ratio(fg: RGBColor, bg: RGBColor) -> Double {
        let fgL = relativeLuminance(fg)
        let bgL = relativeLuminance(bg)
        let maxL = max(fgL, bgL)
        let minL = min(fgL, bgL)
        return (maxL + 0.05) / (minL + 0.05)
    }

    static func ratioString(fg: RGBColor, bg: RGBColor) -> String {
        String(format: "%.2f:1", ratio(fg: fg, bg: bg))
    }
}
