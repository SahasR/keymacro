import Foundation

enum ActionStep: Codable, Identifiable {
    case typeText(TypeTextData)
    case paste(PasteData)
    case pressKey(PressKeyData)
    case delay(DelayData)
    case shell(ShellData)
    case openURL(OpenURLData)
    case setClipboard(SetClipboardData)

    var id: UUID {
        switch self {
        case .typeText(let d):     return d.id
        case .paste(let d):        return d.id
        case .pressKey(let d):     return d.id
        case .delay(let d):        return d.id
        case .shell(let d):        return d.id
        case .openURL(let d):      return d.id
        case .setClipboard(let d): return d.id
        }
    }

    var label: String {
        switch self {
        case .typeText(let d):     return "Type: \"\(d.text.prefix(30))\""
        case .paste(let d):        return "Paste: \"\(d.text.prefix(30))\""
        case .pressKey(let d):     return "Key: \(KeyCodeMap.name(for: d.keyCode))"
        case .delay(let d):        return "Wait \(d.milliseconds) ms"
        case .shell(let d):        return "Shell: \(d.command.prefix(30))"
        case .openURL(let d):      return "Open: \(d.url.prefix(40))"
        case .setClipboard(let d): return "Clipboard: \"\(d.text.prefix(30))\""
        }
    }

    struct TypeTextData: Codable { var id = UUID(); var text: String }
    struct PasteData: Codable    { var id = UUID(); var text: String }
    struct PressKeyData: Codable { var id = UUID(); var keyCode: UInt32; var modifiers: UInt32 }
    struct DelayData: Codable    { var id = UUID(); var milliseconds: Int }
    struct OpenURLData: Codable  { var id = UUID(); var url: String }
    struct SetClipboardData: Codable { var id = UUID(); var text: String }

    struct ShellData: Codable {
        var id = UUID()
        var command: String
        var captureOutputAsType: Bool
        var abortOnError: Bool

        init(command: String, captureOutputAsType: Bool = false, abortOnError: Bool = false) {
            self.command = command
            self.captureOutputAsType = captureOutputAsType
            self.abortOnError = abortOnError
        }

        // Custom decoder so old saved JSON without abortOnError still loads
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = try c.decode(UUID.self, forKey: .id)
            command = try c.decode(String.self, forKey: .command)
            captureOutputAsType = try c.decode(Bool.self, forKey: .captureOutputAsType)
            abortOnError = (try? c.decode(Bool.self, forKey: .abortOnError)) ?? false
        }
    }

    private enum CodingKeys: String, CodingKey { case type, data }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .typeText(let d):     try c.encode("typeText", forKey: .type);     try c.encode(d, forKey: .data)
        case .paste(let d):        try c.encode("paste", forKey: .type);        try c.encode(d, forKey: .data)
        case .pressKey(let d):     try c.encode("pressKey", forKey: .type);     try c.encode(d, forKey: .data)
        case .delay(let d):        try c.encode("delay", forKey: .type);        try c.encode(d, forKey: .data)
        case .shell(let d):        try c.encode("shell", forKey: .type);        try c.encode(d, forKey: .data)
        case .openURL(let d):      try c.encode("openURL", forKey: .type);      try c.encode(d, forKey: .data)
        case .setClipboard(let d): try c.encode("setClipboard", forKey: .type); try c.encode(d, forKey: .data)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "typeText":     self = .typeText(try c.decode(TypeTextData.self, forKey: .data))
        case "paste":        self = .paste(try c.decode(PasteData.self, forKey: .data))
        case "pressKey":     self = .pressKey(try c.decode(PressKeyData.self, forKey: .data))
        case "delay":        self = .delay(try c.decode(DelayData.self, forKey: .data))
        case "shell":        self = .shell(try c.decode(ShellData.self, forKey: .data))
        case "openURL":      self = .openURL(try c.decode(OpenURLData.self, forKey: .data))
        case "setClipboard": self = .setClipboard(try c.decode(SetClipboardData.self, forKey: .data))
        default: throw DecodingError.dataCorruptedError(forKey: .type, in: c, debugDescription: "Unknown step type")
        }
    }
}
