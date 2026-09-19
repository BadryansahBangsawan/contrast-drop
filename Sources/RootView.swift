import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: ContrastStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: FunTheme.sectionSpacing) {
            Text(store.menuTitle)
                .font(.headline)

            if let errorMessage = store.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RoundedRectangle(cornerRadius: FunTheme.rowRadius, style: .continuous)
                .fill(store.bgColor)
                .overlay {
                    Text("Aa")
                        .foregroundStyle(store.fgColor)
                }
                .frame(height: 48)
                .extraRowSurface()

            VStack(alignment: .leading, spacing: FunTheme.innerSpacing) {
                HStack {
                    Text("FG")
                    Text(store.fg.hex)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                    Button("Pick FG") {
                        store.pickFG()
                    }
                    Button("Paste as FG") {
                        store.pasteFG()
                    }
                }
                .extraRowSurface()

                HStack {
                    Text("BG")
                    Text(store.bg.hex)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                    Button("Pick BG") {
                        store.pickBG()
                    }
                    Button("Paste as BG") {
                        store.pasteBG()
                    }
                }
                .extraRowSurface()
            }

            Button("Swap FG/BG") {
                store.swap()
            }
            .buttonStyle(.bordered)

            VStack(alignment: .leading, spacing: FunTheme.innerSpacing) {
                ForEach(store.checks) { check in
                    HStack {
                        Text(check.label)
                        Spacer()
                        Text(check.passed ? "Pass" : "Fail")
                            .foregroundStyle(check.passed ? Color.secondary : Color.red)
                    }
                    .extraRowSurface()
                }
            }

            HStack {
                Button("Copy CSS") {
                    store.copyCSS()
                }
                .buttonStyle(.borderedProminent)
                Button("Copy FG") {
                    store.copyFG()
                }
                Button("Copy BG") {
                    store.copyBG()
                }
            }

            ExtraSettingsFooter()
        }
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.fg)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.bg)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.errorMessage)
        .funPanel()
    }
}
