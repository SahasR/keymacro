import Foundation

struct Macro: Identifiable, Codable {
    var id: UUID
    var name: String
    var enabled: Bool
    var hotKey: HotKey
    var steps: [ActionStep]

    init(id: UUID = UUID(), name: String, enabled: Bool = true, hotKey: HotKey, steps: [ActionStep]) {
        self.id = id; self.name = name; self.enabled = enabled
        self.hotKey = hotKey; self.steps = steps
    }
}

struct HotKey: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32   // Carbon mask: controlKey | optionKey | cmdKey | shiftKey
    var displayString: String
}
