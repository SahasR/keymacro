import CoreGraphics
import AppKit

enum KeyTyper {
    static func typeString(_ text: String) {
        let src = CGEventSource(stateID: .combinedSessionState)
        for scalar in text.unicodeScalars {
            var ch = UniChar(scalar.value)
            let dn = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: true)
            let up = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: false)
            dn?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &ch)
            up?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &ch)
            dn?.post(tap: .cghidEventTap)
            usleep(8_000)
            up?.post(tap: .cghidEventTap)
            usleep(8_000)
        }
    }

    static func paste(_ text: String) {
        let prev = NSPasteboard.general.string(forType: .string)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        pressKey(keyCode: 9, modifiers: CGEventFlags.maskCommand)  // ⌘V
        usleep(100_000)
        NSPasteboard.general.clearContents()
        if let prev = prev { NSPasteboard.general.setString(prev, forType: .string) }
    }

    static func pressKey(keyCode: CGKeyCode, modifiers: CGEventFlags = []) {
        let src = CGEventSource(stateID: .combinedSessionState)
        let dn = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        dn?.flags = modifiers
        up?.flags = modifiers
        dn?.post(tap: .cghidEventTap)
        usleep(50_000)
        up?.post(tap: .cghidEventTap)
        usleep(50_000)
    }
}
