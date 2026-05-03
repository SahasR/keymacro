import Foundation
import Combine

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
        load()
        if macros.isEmpty { macros = Self.defaultMacros() }
        $macros
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.save() }
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
        // Carbon modifier raw values: controlKey=4096, optionKey=2048, cmdKey=256, shiftKey=512
        [
            Macro(
                name: "Git: add + status + commit",
                hotKey: HotKey(keyCode: 4, modifiers: UInt32(4096 | 2048), displayString: "⌃⌥H"),
                steps: [
                    .typeText(.init(text: "git add .")),
                    .pressKey(.init(keyCode: 36, modifiers: 0)),  // Return
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
