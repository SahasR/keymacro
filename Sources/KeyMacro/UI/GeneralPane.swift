import SwiftUI
import ServiceManagement

struct GeneralPane: View {
    @EnvironmentObject var store: MacroStore

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at login", isOn: $store.launchAtLogin)
                    .onChange(of: store.launchAtLogin) { val in
                        // ServiceManagement requires a helper app or SMAppService (macOS 13+)
                        // For now, open Login Items system preference
                        if val {
                            NSWorkspace.shared.open(
                                URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.Extension")!
                            )
                        }
                    }
            }
            Section("Typing") {
                HStack {
                    Text("Keystroke delay")
                    Spacer()
                    TextField("ms", value: $store.defaultDelayMs, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    Text("ms").foregroundColor(.secondary)
                }
                Text("Lower = faster typing. Increase if characters are missed.")
                    .font(.caption).foregroundColor(.secondary)
            }
            Section("Permissions") {
                HStack {
                    Label("Accessibility Access", systemImage: AccessibilityChecker.isTrusted ? "checkmark.shield.fill" : "shield.slash.fill")
                        .foregroundColor(AccessibilityChecker.isTrusted ? .green : .red)
                    Spacer()
                    if !AccessibilityChecker.isTrusted {
                        Button("Grant Access") { AccessibilityChecker.openSystemPreferences() }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
