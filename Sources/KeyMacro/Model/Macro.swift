import Foundation

struct Macro: Identifiable, Codable {
    var id: UUID
    var name: String
    var enabled: Bool
    var hotKey: HotKey
    var steps: [ActionStep]
    var lastRun: Date?

    init(id: UUID = UUID(), name: String, enabled: Bool = true, hotKey: HotKey, steps: [ActionStep], lastRun: Date? = nil) {
        self.id = id; self.name = name; self.enabled = enabled
        self.hotKey = hotKey; self.steps = steps; self.lastRun = lastRun
    }
}

struct HotKey: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32   // Carbon mask: controlKey | optionKey | cmdKey | shiftKey
    var displayString: String
}
