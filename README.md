# Contrast Drop

WCAG 2.1 contrast ratio for a foreground and background color. Sample, paste hex/rgb, swap, copy CSS.

Menu extra for macOS 14+. It lives on the **right** of the menu bar and does not show a Dock icon.

| | |
|---|---|
| Product | `ContrastDrop` |
| Bundle ID | `engineer.badry.contrastdrop` |
| Status item | SF Symbol `circle.lefthalf.filled` |
| Panel | opaque ~360×420 pt |

## Features

- Pick FG/BG with `NSColorSampler` (sRGB). Paste `#RGB` / `#RRGGBB` / `#RRGGBBAA` / `rgb()` / `rgba()`.
- Ratio to two decimals (`21.00:1`). Menu title is that string.
- Pass/Fail: AA text 4.5, AAA text 7, AA large 3, AAA large 4.5, UI 3.
- **Swap FG/BG**. **Copy CSS**, **Copy FG**, **Copy BG**.
- Does **not** request Screen Recording.

## Requirements

- macOS 14 Sonoma or later
- Swift 5.9 or later only if you build from source

## Install

Build from source:

```bash
git clone https://github.com/BadryansahBangsawan/contrast-drop.git
cd contrast-drop
bash package-app.sh
ditto dist/ContrastDrop.app /Applications/ContrastDrop.app
xattr -cr /Applications/ContrastDrop.app
open /Applications/ContrastDrop.app
```

Ad-hoc signed (`codesign -s -`). If Gatekeeper blocks it or says it is damaged, run the `xattr` line above. If still blocked: System Settings → Privacy & Security → Open Anyway.

Do not run `dist/` next to a copy in `/Applications` (same bundle ID).

Enable **Open at Login** from Settings if you want it after reboot.

## How to open

This is an `LSUIElement` extra. Proof it is running is the **circle.lefthalf.filled** status item on the **right** of the menu bar.

1. Click that extra. The panel is opaque (~360×420), not a 10px strip.
2. If the bar is full, look behind the Control Center overflow chevron **«**.
3. Double-clicking in Finder/Launchpad does not open a document window. That is expected. There is no Dock icon.

## Usage

- **Pick FG** / **Pick BG**, or **Paste as FG** / **Paste as BG**.
- Swatch shows **Aa**. Five WCAG rows: Pass or Fail.
- **Copy CSS** writes:

```
color: #RRGGBB;
background-color: #RRGGBB;
```

- **Settings** at the bottom: Open at Login, Quit.

## Permissions

No Accessibility, Screen Recording, or network. Color sampler is the system eyedropper.

## Data

UserDefaults `engineer.badry.contrastdrop.fg` / `.bg` as `#RRGGBB`. Missing or invalid resets to `#000000` / `#FFFFFF` and a red **Reset invalid saved color.**

## Privacy

No network. Colors stay on this Mac.

## Uninstall

Delete `/Applications/ContrastDrop.app`. Turn off Open at Login in Settings first if you enabled it.

## Troubleshooting

| What you see | What to do |
|---|---|
| No Dock icon | Click the **circle.lefthalf.filled** extra on the right of the menu bar. |
| Extra missing | Overflow **«**, or `open /Applications/ContrastDrop.app`. |
| “Damaged” | `xattr -cr /Applications/ContrastDrop.app` |
| **Not a hex or rgb color.** | Clipboard is not `#RGB` / `#RRGGBB` / `rgb()` / `rgba()`. |
| **Color is not convertible to sRGB.** | Sampler color has no sRGB conversion; previous color kept. |
| Tiny capsule / only Settings | Reinstall from this repo (panel min height 420). |

## Development

```bash
swift build
swift build -c release --product ContrastDrop
```

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`. Never commit `dist/`. FunTheme.swift is copied verbatim (no shared package).

## License

[MIT](LICENSE)
