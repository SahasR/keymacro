import SwiftUI

struct AboutPane: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "command.square.fill")
                .font(.system(size: 72))
                .foregroundColor(.accentColor)
            Text("KeyMacro").font(.largeTitle.bold())
            Text("Version 1.0.0")
                .foregroundColor(.secondary)
            Text("A keyboard macro manager for macOS.\nBind global hotkeys to sequences of actions.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Divider().frame(width: 300)
            Text("Built with Swift & SwiftUI")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
