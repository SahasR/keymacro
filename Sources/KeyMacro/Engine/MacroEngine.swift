import AppKit
import Foundation
import Carbon.HIToolbox

final class MacroEngine {
    static let shared = MacroEngine()
    weak var store: MacroStore?

    func run(_ macro: Macro) {
        DispatchQueue.global(qos: .userInteractive).async {
            usleep(300_000)
            for step in macro.steps {
                if !self.execute(step) { break }
            }
            DispatchQueue.main.async {
                if var m = self.store?.macros.first(where: { $0.id == macro.id }) {
                    m.lastRun = Date()
                    self.store?.update(m)
                }
            }
        }
    }

    // Returns false if the macro should abort (shell abortOnError triggered)
    private func execute(_ step: ActionStep) -> Bool {
        let charDelay = UInt32((store?.defaultDelayMs ?? 8) * 1_000)
        switch step {
        case .typeText(let d):
            KeyTyper.typeString(VariableResolver.resolve(d.text), charDelayUs: charDelay)
        case .paste(let d):
            KeyTyper.paste(VariableResolver.resolve(d.text))
        case .pressKey(let d):
            var flags: CGEventFlags = []
            let mods = d.modifiers
            if mods & 256  != 0 { flags.insert(.maskCommand) }
            if mods & 2048 != 0 { flags.insert(.maskAlternate) }
            if mods & 4096 != 0 { flags.insert(.maskControl) }
            if mods & 512  != 0 { flags.insert(.maskShift) }
            KeyTyper.pressKey(keyCode: CGKeyCode(d.keyCode), modifiers: flags)
        case .delay(let d):
            usleep(UInt32(d.milliseconds) * 1_000)
        case .shell(let d):
            let result = ShellRunner.run(VariableResolver.resolve(d.command))
            if d.captureOutputAsType && !result.output.isEmpty {
                KeyTyper.typeString(result.output, charDelayUs: charDelay)
            }
            if d.abortOnError && result.exitCode != 0 { return false }
        case .openURL(let d):
            var urlStr = VariableResolver.resolve(d.url)
            if !urlStr.contains("://") { urlStr = "https://" + urlStr }
            if let url = URL(string: urlStr) {
                DispatchQueue.main.sync { _ = NSWorkspace.shared.open(url) }
            }
        case .setClipboard(let d):
            let text = VariableResolver.resolve(d.text)
            DispatchQueue.main.sync {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            }
        }
        return true
    }
}
