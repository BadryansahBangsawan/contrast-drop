import AppKit
import SwiftUI

@MainActor
final class ContrastStore: ObservableObject {
    private enum PrefKey {
        static let fg = "engineer.badry.contrastdrop.fg"
        static let bg = "engineer.badry.contrastdrop.bg"
    }

    private enum Slot {
        case fg
        case bg
    }

    @Published private(set) var fg: RGBColor
    @Published private(set) var bg: RGBColor
    @Published var errorMessage: String?

    init() {
        let defaults = UserDefaults.standard
        var reset = false
        if let raw = defaults.string(forKey: PrefKey.fg), let color = ColorParse.storedRRGGBB(raw) {
            fg = color
        } else {
            fg = RGBColor(r: 0, g: 0, b: 0)
            reset = true
        }
        if let raw = defaults.string(forKey: PrefKey.bg), let color = ColorParse.storedRRGGBB(raw) {
            bg = color
        } else {
            bg = RGBColor(r: 255, g: 255, b: 255)
            reset = true
        }
        if reset {
            errorMessage = "Reset invalid saved color."
            persist()
        }
    }

    var menuTitle: String {
        ContrastMath.ratioString(fg: fg, bg: bg)
    }

    var fgColor: Color {
        Color(red: Double(fg.r) / 255.0, green: Double(fg.g) / 255.0, blue: Double(fg.b) / 255.0)
    }

    var bgColor: Color {
        Color(red: Double(bg.r) / 255.0, green: Double(bg.g) / 255.0, blue: Double(bg.b) / 255.0)
    }

    var checks: [ContrastCheck] {
        let value = ContrastMath.ratio(fg: fg, bg: bg)
        return [
            ContrastCheck(id: "aa-text", label: "AA text", passed: value >= 4.5),
            ContrastCheck(id: "aaa-text", label: "AAA text", passed: value >= 7),
            ContrastCheck(id: "aa-large", label: "AA large", passed: value >= 3),
            ContrastCheck(id: "aaa-large", label: "AAA large", passed: value >= 4.5),
            ContrastCheck(id: "ui", label: "UI", passed: value >= 3),
        ]
    }

    func pickFG() {
        pick(slot: .fg)
    }

    func pickBG() {
        pick(slot: .bg)
    }

    func pasteFG() {
        paste(slot: .fg)
    }

    func pasteBG() {
        paste(slot: .bg)
    }

    func swap() {
        let previous = fg
        fg = bg
        bg = previous
        persist()
    }

    func copyCSS() {
        writePasteboard("color: \(fg.hex);\nbackground-color: \(bg.hex);")
    }

    func copyFG() {
        writePasteboard(fg.hex)
    }

    func copyBG() {
        writePasteboard(bg.hex)
    }

    private func pick(slot: Slot) {
        NSColorSampler().show { [weak self] color in
            Task { @MainActor in
                self?.applyPicked(color, slot: slot)
            }
        }
    }

    private func applyPicked(_ color: NSColor?, slot: Slot) {
        guard let color else { return }
        guard let srgb = color.usingColorSpace(.sRGB) else {
            errorMessage = "Color is not convertible to sRGB."
            return
        }
        let picked = RGBColor(
            r: channel8(srgb.redComponent),
            g: channel8(srgb.greenComponent),
            b: channel8(srgb.blueComponent)
        )
        errorMessage = nil
        switch slot {
        case .fg:
            fg = picked
        case .bg:
            bg = picked
        }
        persist()
    }

    private func paste(slot: Slot) {
        let raw = NSPasteboard.general.string(forType: .string) ?? ""
        switch ColorParse.parse(raw) {
        case .parsed(let color):
            errorMessage = nil
            switch slot {
            case .fg:
                fg = color
            case .bg:
                bg = color
            }
            persist()
        case .invalid:
            errorMessage = "Not a hex or rgb color."
        case .regexFailed:
            errorMessage = "Internal regex failed."
        }
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(fg.hex, forKey: PrefKey.fg)
        defaults.set(bg.hex, forKey: PrefKey.bg)
    }

    private func writePasteboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }

    private func channel8(_ component: CGFloat) -> Int {
        let value = Int((component * 255.0).rounded())
        if value < 0 { return 0 }
        if value > 255 { return 255 }
        return value
    }
}

struct ContrastCheck: Identifiable {
    let id: String
    let label: String
    let passed: Bool
}
