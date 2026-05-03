import SwiftUI
import AppKit
import Carbon.HIToolbox

struct HotKeyRecorder: View {
    @Binding var hotKey: HotKey
    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack {
            Text("Hotkey:")
            Button(isRecording ? "\u{23FA} Press keys\u{2026}" : (hotKey.displayString.isEmpty ? "Click to record" : hotKey.displayString)) {
                if isRecording { stopRecording() }
                else { startRecording() }
            }
            .buttonStyle(.bordered)
            .foregroundColor(isRecording ? .red : .primary)
            if isRecording {
                Button("Cancel") { stopRecording() }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func startRecording() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            guard event.type == .keyDown else { return event }
            let mods = carbonModifiers(from: event.modifierFlags)
            let keyCode = UInt32(event.keyCode)
            let display = modifierString(from: event.modifierFlags) + (event.charactersIgnoringModifiers?.uppercased() ?? "?")
            hotKey = HotKey(keyCode: keyCode, modifiers: mods, displayString: display)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
    }

    private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var mods: UInt32 = 0
        // Carbon modifier raw values: controlKey=4096, optionKey=2048, cmdKey=256, shiftKey=512
        if flags.contains(.control) { mods |= 4096 }
        if flags.contains(.option)  { mods |= 2048 }
        if flags.contains(.command) { mods |= 256  }
        if flags.contains(.shift)   { mods |= 512  }
        return mods
    }

    private func modifierString(from flags: NSEvent.ModifierFlags) -> String {
        var s = ""
        if flags.contains(.control) { s += "\u{2303}" }
        if flags.contains(.option)  { s += "\u{2325}" }
        if flags.contains(.shift)   { s += "\u{21E7}" }
        if flags.contains(.command) { s += "\u{2318}" }
        return s
    }
}
