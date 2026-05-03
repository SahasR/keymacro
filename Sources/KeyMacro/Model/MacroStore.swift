import AppKit
import Foundation
import Combine
import UniformTypeIdentifiers

final class MacroStore: ObservableObject {
    @Published var macros: [Macro] = []
    @Published var launchAtLogin: Bool = false
    @Published var defaultDelayMs: Int = 8

    private let storageURL: URL = {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = support.appendingPathComponent("KeyMacro", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("macros.json")
    }()

    private var cancellables = Set<AnyCancellable>()

    init() {
        let storedDelay = UserDefaults.standard.integer(forKey: "defaultDelayMs")
        defaultDelayMs = storedDelay > 0 ? storedDelay : 8
        launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")

        load()
        if macros.isEmpty { macros = Self.defaultMacros() }

        $macros
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)

        $defaultDelayMs.dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "defaultDelayMs") }
            .store(in: &cancellables)

        $launchAtLogin.dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "launchAtLogin") }
            .store(in: &cancellables)
    }

    func add(_ macro: Macro) { macros.append(macro) }
    func delete(at offsets: IndexSet) { macros.remove(atOffsets: offsets) }
    func delete(_ macro: Macro) { macros.removeAll { $0.id == macro.id } }
    func move(from src: IndexSet, to dst: Int) { macros.move(fromOffsets: src, toOffset: dst) }

    func update(_ macro: Macro) {
        if let i = macros.firstIndex(where: { $0.id == macro.id }) {
            macros[i] = macro
        }
    }

    func duplicate(_ macro: Macro) {
        var copy = macro
        copy.id = UUID()
        copy.name = "\(macro.name) Copy"
        copy.lastRun = nil
        if let idx = macros.firstIndex(where: { $0.id == macro.id }) {
            macros.insert(copy, at: idx + 1)
        } else {
            macros.append(copy)
        }
    }

    func conflictingMacro(for macro: Macro) -> Macro? {
        guard macro.hotKey.keyCode != 0 else { return nil }
        return macros.first {
            $0.id != macro.id &&
            $0.hotKey.keyCode == macro.hotKey.keyCode &&
            $0.hotKey.modifiers == macro.hotKey.modifiers
        }
    }

    func jsonData() -> Data? { try? JSONEncoder().encode(macros) }

    func importFrom(_ data: Data) -> Bool {
        guard let imported = try? JSONDecoder().decode([Macro].self, from: data) else { return false }
        macros.append(contentsOf: imported)
        return true
    }

    func exportMacros() {
        guard let data = jsonData() else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.json]
        panel.nameFieldStringValue = "KeyMacro-export.json"
        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url, options: .atomic)
        }
    }

    func importMacros() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.json]
        panel.allowsMultipleSelection = false
        panel.message = "Select a KeyMacro JSON export file"
        if panel.runModal() == .OK, let url = panel.url,
           let data = try? Data(contentsOf: url) {
            _ = importFrom(data)
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(macros) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL),
              let decoded = try? JSONDecoder().decode([Macro].self, from: data) else { return }
        macros = decoded
    }

    static func defaultMacros() -> [Macro] {
        [
            Macro(
                name: "Git: add + status + commit",
                hotKey: HotKey(keyCode: 4, modifiers: UInt32(4096 | 2048), displayString: "⌃⌥H"),
                steps: [
                    .typeText(.init(text: "git add .")),
                    .pressKey(.init(keyCode: 36, modifiers: 0)),
                    .delay(.init(milliseconds: 150)),
                    .typeText(.init(text: "git status")),
                    .pressKey(.init(keyCode: 36, modifiers: 0)),
                    .delay(.init(milliseconds: 150)),
                    .typeText(.init(text: "git commit -m \"")),
                ]
            ),
            Macro(
                name: "Git: current branch",
                hotKey: HotKey(keyCode: 11, modifiers: UInt32(4096 | 2048), displayString: "⌃⌥B"),
                steps: [
                    .shell(.init(command: "git rev-parse --abbrev-ref HEAD", captureOutputAsType: true))
                ]
            )
        ]
    }
}
