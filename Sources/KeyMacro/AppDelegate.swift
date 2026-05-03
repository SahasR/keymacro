import Cocoa
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var store: MacroStore!
    var hotKeyManager: HotKeyManager!
    var menuBarController: MenuBarController!
    private var settingsWindow: NSWindow?
    private var onboardingWindow: NSWindow?
    private var accessibilityTimer: Timer?
    private var wasAccessibilityTrusted = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        store = MacroStore()
        hotKeyManager = HotKeyManager(store: store)
        menuBarController = MenuBarController(store: store, appDelegate: self)
        MacroEngine.shared.store = store

        if !AccessibilityChecker.isTrusted {
            showOnboarding()
        } else {
            hotKeyManager.registerAll()
            wasAccessibilityTrusted = true
        }
        startAccessibilityWatcher()
    }

    private func startAccessibilityWatcher() {
        accessibilityTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let trusted = AccessibilityChecker.isTrusted
            if self.wasAccessibilityTrusted && !trusted {
                self.hotKeyManager.unregisterAll()
                let alert = NSAlert()
                alert.messageText = "Accessibility Access Revoked"
                alert.informativeText = "KeyMacro's Accessibility permission was removed. Hotkeys are disabled until access is restored.\n\nRe-enable in System Settings → Privacy & Security → Accessibility."
                alert.addButton(withTitle: "Open Settings")
                alert.addButton(withTitle: "Later")
                if alert.runModal() == .alertFirstButtonReturn {
                    AccessibilityChecker.openSystemPreferences()
                }
            } else if !self.wasAccessibilityTrusted && trusted {
                self.hotKeyManager.registerAll()
            }
            self.wasAccessibilityTrusted = trusted
        }
    }

    func showSettings() {
        if settingsWindow == nil {
            settingsWindow = makeSettingsWindow()
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makeSettingsWindow() -> NSWindow {
        let tabs = NSTabViewController()
        tabs.tabStyle = .toolbar

        let panes: [(title: String, symbol: String, view: NSView)] = [
            ("Macros",  "keyboard",    NSHostingView(rootView: MacrosPane().environmentObject(store))),
            ("General", "gearshape",   NSHostingView(rootView: GeneralPane().environmentObject(store))),
            ("About",   "info.circle", NSHostingView(rootView: AboutPane())),
        ]

        for pane in panes {
            let item = NSTabViewItem()
            item.label = pane.title
            if let img = NSImage(systemSymbolName: pane.symbol, accessibilityDescription: pane.title) {
                item.image = img
            }
            item.viewController = NSViewController()
            item.viewController!.view = pane.view
            tabs.addTabViewItem(item)
        }

        let w = NSWindow(contentViewController: tabs)
        w.title = "KeyMacro Settings"
        w.styleMask = [.titled, .closable, .miniaturizable, .resizable, .unifiedTitleAndToolbar]
        w.setContentSize(NSSize(width: 720, height: 520))
        w.center()
        w.isReleasedWhenClosed = false
        return w
    }

    func showOnboarding() {
        if onboardingWindow == nil {
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false
            )
            w.title = "Welcome to KeyMacro"
            w.center()
            w.isReleasedWhenClosed = false
            w.contentView = NSHostingView(rootView: OnboardingView(onComplete: { [weak self] in
                DispatchQueue.main.async {
                    self?.onboardingWindow?.close()
                    self?.hotKeyManager.registerAll()
                    self?.wasAccessibilityTrusted = true
                }
            }))
            onboardingWindow = w
        }
        onboardingWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
