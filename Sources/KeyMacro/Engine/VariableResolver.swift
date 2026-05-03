import AppKit
import Foundation

enum VariableResolver {
    static func resolve(_ text: String) -> String {
        var result = text
        let clipboard = NSPasteboard.general.string(forType: .string) ?? ""
        let now = Date()

        let dateFmt = DateFormatter()
        dateFmt.dateStyle = .short
        dateFmt.timeStyle = .none

        let timeFmt = DateFormatter()
        timeFmt.dateStyle = .none
        timeFmt.timeStyle = .short

        let isoFmt = ISO8601DateFormatter()

        result = result.replacingOccurrences(of: "{{clipboard}}", with: clipboard)
        result = result.replacingOccurrences(of: "{{date}}", with: dateFmt.string(from: now))
        result = result.replacingOccurrences(of: "{{time}}", with: timeFmt.string(from: now))
        result = result.replacingOccurrences(of: "{{iso}}", with: isoFmt.string(from: now))
        return result
    }
}
