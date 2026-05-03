import Carbon.HIToolbox

enum KeyCodeMap {
    static let nameToCode: [String: UInt32] = [
        "A": 0x00, "S": 0x01, "D": 0x02, "F": 0x03, "H": 0x04, "G": 0x05,
        "Z": 0x06, "X": 0x07, "C": 0x08, "V": 0x09, "B": 0x0B, "Q": 0x0C,
        "W": 0x0D, "E": 0x0E, "R": 0x0F, "Y": 0x10, "T": 0x11, "1": 0x12,
        "2": 0x13, "3": 0x14, "4": 0x15, "6": 0x16, "5": 0x17, "=": 0x18,
        "9": 0x19, "7": 0x1A, "-": 0x1B, "8": 0x1C, "0": 0x1D, "]": 0x1E,
        "O": 0x1F, "U": 0x20, "[": 0x21, "I": 0x22, "P": 0x23, "L": 0x25,
        "J": 0x26, "'": 0x27, "K": 0x28, ";": 0x29, "\\": 0x2A, ",": 0x2B,
        "/": 0x2C, "N": 0x2D, "M": 0x2E, ".": 0x2F,
        "Return": UInt32(kVK_Return), "Tab": UInt32(kVK_Tab),
        "Space": UInt32(kVK_Space), "Delete": UInt32(kVK_Delete),
        "Escape": UInt32(kVK_Escape), "Left": UInt32(kVK_LeftArrow),
        "Right": UInt32(kVK_RightArrow), "Up": UInt32(kVK_UpArrow),
        "Down": UInt32(kVK_DownArrow), "F1": UInt32(kVK_F1), "F2": UInt32(kVK_F2),
        "F3": UInt32(kVK_F3), "F4": UInt32(kVK_F4), "F5": UInt32(kVK_F5),
    ]

    static let codeToName: [UInt32: String] = Dictionary(
        uniqueKeysWithValues: nameToCode.map { ($1, $0) }
    )

    static func name(for code: UInt32) -> String { codeToName[code] ?? "0x\(String(code, radix: 16))" }
    static func code(for name: String) -> UInt32? { nameToCode[name.uppercased()] }
}
