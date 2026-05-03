import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var page = 0
    @State private var granted = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                welcomePage.opacity(page == 0 ? 1 : 0)
                permissionPage.opacity(page == 1 ? 1 : 0)
                donePage.opacity(page == 2 ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .animation(.easeInOut(duration: 0.25), value: page)

            Divider()

            HStack {
                if page > 0 {
                    Button("Back") { page -= 1 }
                }
                Spacer()
                // Step dots
                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(i == page ? Color.accentColor : Color.secondary.opacity(0.35))
                            .frame(width: 6, height: 6)
                    }
                }
                Spacer()
                if page == 0 {
                    Button("Get Started") { page = 1 }.buttonStyle(.borderedProminent)
                } else if page == 1 {
                    Button(granted ? "Continue" : "Open System Settings") {
                        if granted { page = 2 }
                        else { AccessibilityChecker.openSystemPreferences(); startPolling() }
                    }.buttonStyle(.borderedProminent)
                } else {
                    Button("Done") { onComplete() }.buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 520, height: 400)
        .onDisappear { timer?.invalidate() }
    }

    private var welcomePage: some View {
        VStack(spacing: 16) {
            Image(systemName: "command.square.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            Text("Welcome to KeyMacro").font(.title.bold())
            Text("Bind global keyboard shortcuts to sequences of actions.\nType text, run commands, and automate your workflow.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }.padding()
    }

    private var permissionPage: some View {
        VStack(spacing: 16) {
            Image(systemName: granted ? "checkmark.shield.fill" : "shield.fill")
                .font(.system(size: 64))
                .foregroundColor(granted ? .green : .orange)
            Text("Accessibility Access").font(.title.bold())
            Text("KeyMacro needs Accessibility access to simulate keystrokes.\nGo to System Settings \u{2192} Privacy & Security \u{2192} Accessibility.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            if granted {
                Label("Access granted!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }.padding()
        .onAppear { startPolling() }
    }

    private var donePage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            Text("You're all set!").font(.title.bold())
            Text("KeyMacro is ready. Press \u{2303}\u{2325}H in any terminal to run the default git macro.\nCustomize macros anytime via the menu bar icon.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }.padding()
    }

    private func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if AccessibilityChecker.isTrusted {
                granted = true
                timer?.invalidate()
            }
        }
    }
}
