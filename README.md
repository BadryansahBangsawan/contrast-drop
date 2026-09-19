# Contrast Drop

[![Build](https://github.com/BadryansahBangsawan/contrast-drop/actions/workflows/ci.yml/badge.svg)](https://github.com/BadryansahBangsawan/contrast-drop/actions/workflows/ci.yml)

WCAG 2.1 contrast for two colors. Sample, paste hex or `rgb()`, swap, copy CSS.

Menu extra for macOS 14+. It lives on the **right** of the menu bar and does not show a Dock icon.

![Contrast Drop panel](docs/panel.png)

| | |
|---|---|
| Product | `ContrastDrop` |
| Bundle ID | `engineer.badry.contrastdrop` |
| Status item | SF Symbol `circle.lefthalf.filled` (title: ratio, e.g. `21.00:1`) |
| Panel | opaque ~360×420 pt |

## Features

- **Pick FG** / **Pick BG** uses the system color sampler, converted to sRGB.
- **Paste as FG** / **Paste as BG** — not automatic clipboard assignment.
- Accepts `#RGB`, `#RRGGBB`, `#RRGGBBAA` (alpha dropped), `rgb()`, `rgba()` (alpha dropped), spaces or commas, 0–255 or `%`.
- Ratio to two decimals. Five rows: AA text, AAA text, AA large, AAA large, UI.
- **Swap FG/BG**. **Copy CSS**, **Copy FG**, **Copy BG**.
- Does not request Screen Recording.

### Pass thresholds

| Row | Pass if ratio ≥ |
|---|---|
| AA text | 4.5 |
| AAA text | 7 |
| AA large | 3 |
| AAA large | 4.5 |
| UI | 3 |

Black on white is `21.00:1` (all Pass). `#777777` on white is about `4.48:1` (AA text Fail).

## Requirements

- macOS 14 Sonoma or later
- Swift 5.9 or later (Xcode or Command Line Tools) only if you build from source

## Install

```bash
git clone https://github.com/BadryansahBangsawan/contrast-drop.git
cd contrast-drop
bash package-app.sh
ditto dist/ContrastDrop.app /Applications/ContrastDrop.app
xattr -cr /Applications/ContrastDrop.app
open /Applications/ContrastDrop.app
```

Ad-hoc signed (`codesign -s -`). If Gatekeeper blocks it or says it is damaged, run the `xattr` line. If it is still blocked: System Settings → Privacy & Security → Open Anyway.

Do not run `dist/ContrastDrop.app` while `/Applications/ContrastDrop.app` is running (same bundle ID).

Enable **Open at Login** from Settings if you want it after reboot.

## How to open

This is an `LSUIElement` extra. Proof it is running is the **circle.lefthalf.filled** status item on the **right** of the menu bar, not a window from Finder or Launchpad.

1. Click that extra. The panel is opaque (~360×420), not a 10px strip.
2. If the bar is full, look behind the Control Center overflow chevron **«**.
3. Double-clicking the app in Finder/Launchpad only changes the left-side app name. That is expected. There is no Dock icon.

## Usage

1. Click the extra.
2. **Pick FG** / **Pick BG**, or **Paste as FG** / **Paste as BG**.
3. Read the swatch (**Aa**) and the five Pass/Fail rows.
4. **Copy CSS** writes:

```
color: #RRGGBB;
background-color: #RRGGBB;
```

5. **Settings** at the bottom of the panel: Open at Login, Quit.

## Permissions

No Accessibility, Screen Recording, or network. Color sampler is the system eyedropper.

## Data

| What | Where |
|---|---|
| Foreground | UserDefaults `engineer.badry.contrastdrop.fg` (`#RRGGBB`) |
| Background | UserDefaults `engineer.badry.contrastdrop.bg` (`#RRGGBB`) |
| Open at Login | `SMAppService.mainApp` |

Missing or invalid values reset to `#000000` / `#FFFFFF` and a red **Reset invalid saved color.**

## Privacy

No network. Colors stay on this Mac.

## Uninstall

Delete `/Applications/ContrastDrop.app`. Turn off Open at Login in Settings first if you enabled it.

This does not delete UserDefaults. Defaults keys are `engineer.badry.contrastdrop.fg` and `.bg`.

## Troubleshooting

| What you see | What to do |
|---|---|
| Finder “opens” nothing / no Dock icon | Click the **circle.lefthalf.filled** extra on the right of the menu bar. |
| Extra missing | Overflow **«**, or `pgrep -x ContrastDrop` then `open /Applications/ContrastDrop.app`. |
| “Damaged” / cannot verify | `xattr -cr /Applications/ContrastDrop.app`. `spctl --assess` is `rejected` even when it runs. |
| **Not a hex or rgb color.** | Copy `#RGB`, `#RRGGBB`, or `rgb()` / `rgba()`, then **Paste as FG** / **Paste as BG**. |
| **Color is not convertible to sRGB.** | Sampler color kept the previous value. Pick again. |
| **Reset invalid saved color.** | Saved hex was missing or not `#RRGGBB`. Defaults applied. |
| ~10px empty strip under the bar | Reinstall from this repo (panel min height 420). |

## Development

```bash
swift build
swift build -c release --product ContrastDrop
bash package-app.sh
```

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`. Never commit `dist/`. `FunTheme.swift` is copied verbatim (no shared package).

## License

[MIT](LICENSE)
