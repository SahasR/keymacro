import AppKit
import Combine

final class MenuBarController {
    private var statusItem: NSStatusItem!
    private var store: MacroStore
    private weak var appDelegate: AppDelegate?
    private var cancellable: AnyCancellable?

    init(store: MacroStore, appDelegate: AppDelegate) {
        self.store = store
        self.appDelegate = appDelegate
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let btn = statusItem.button {
            btn.image = NSImage(systemSymbolName: "command.square.fill", accessibilityDescription: "KeyMacro")
            btn.image?.isTemplate = true
        }
        buildMenu()
        cancellable = store.$macros
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.buildMenu() }
    }

    private func buildMenu() {
        let menu = NSMenu()

        let header = NSMenuItem(title: "KeyMacro", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        for macro in store.macros where macro.enabled {
            let item = NSMenuItem(title: "\(macro.name)  \(macro.hotKey.displayString)",
                                  action: #selector(runMacroItem(_:)),
                                  keyEquivalent: "")
            item.target = self
            item.representedObject = macro.id
            menu.addItem(item)
        }
        if !store.macros.filter(\.enabled).isEmpty { menu.addItem(.separator()) }

        let settingsItem = NSMenuItem(title: "Settings\u{2026}", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit KeyMacro", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func runMacroItem(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? UUID,
              let macro = store.macros.first(where: { $0.id == id }) else { return }
        MacroEngine.shared.run(macro)
    }

    @objc private func openSettings() {
        appDelegate?.showSettings()
    }
}
