import Foundation
import Carbon.HIToolbox

final class MacroEngine {
    static let shared = MacroEngine()

    func run(_ macro: Macro) {
        DispatchQueue.global(qos: .userInteractive).async {
            usleep(300_000)  // let hotkey chord release
            for step in macro.steps {
                self.execute(step)
            }
        }
    }

    private func execute(_ step: ActionStep) {
        switch step {
        case .typeText(let d):
            KeyTyper.typeString(d.text)
        case .paste(let d):
            KeyTyper.paste(d.text)
        case .pressKey(let d):
            var flags: CGEventFlags = []
            let mods = d.modifiers
            // Carbon modifier raw values: cmdKey=256, shiftKey=512, optionKey=2048, controlKey=4096
            if mods & 256  != 0 { flags.insert(.maskCommand) }
            if mods & 2048 != 0 { flags.insert(.maskAlternate) }
            if mods & 4096 != 0 { flags.insert(.maskControl) }
            if mods & 512  != 0 { flags.insert(.maskShift) }
            KeyTyper.pressKey(keyCode: CGKeyCode(d.keyCode), modifiers: flags)
        case .delay(let d):
            usleep(UInt32(d.milliseconds) * 1_000)
        case .shell(let d):
            let output = ShellRunner.run(d.command)
            if d.captureOutputAsType, !output.isEmpty {
                KeyTyper.typeString(output)
            }
        }
    }
}
