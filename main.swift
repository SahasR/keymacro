import Cocoa
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let trusted = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        )
        if trusted {
            setupHotKey()
            print("✅ GitMacro running — press ⌃⌥H in any terminal window.")
            print("   Ctrl+C to quit.")
        } else {
            print("⚠️  Accessibility access required.")
            print("   System Settings → Privacy & Security → Accessibility → enable GitMacro")
            print("   Then restart the app.")
        }
    }

    func setupHotKey() {
        let hotKeyID = EventHotKeyID(signature: fourCC("GMAC"), id: 1)
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, ctx) -> OSStatus in
                var hkID = EventHotKeyID()
                GetEventParameter(
                    event!, EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID), nil,
                    MemoryLayout<EventHotKeyID>.size, nil, &hkID
                )
                if hkID.id == 1 {
                    let d = Unmanaged<AppDelegate>.fromOpaque(ctx!).takeUnretainedValue()
                    DispatchQueue.global().async { d.runGitMacro() }
                }
                return noErr
            },
            1, &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )

        RegisterEventHotKey(
            UInt32(kVK_ANSI_H), UInt32(controlKey | optionKey),
            hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef
        )
    }

    func typeString(_ text: String) {
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

    func pressReturn() {
        let src = CGEventSource(stateID: .combinedSessionState)
        CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Return), keyDown: true)?
            .post(tap: .cghidEventTap)
        usleep(50_000)
        CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Return), keyDown: false)?
            .post(tap: .cghidEventTap)
        usleep(50_000)
    }

    func runGitMacro() {
        usleep(300_000)           // let hotkey chord fully release before typing
        typeString("git add .")
        pressReturn()
        usleep(150_000)
        typeString("git status")
        pressReturn()
        usleep(150_000)
        typeString("git commit -m \"")
        // cursor left sitting after the opening quote, ready to type message
    }
}

func fourCC(_ s: String) -> FourCharCode {
    s.utf8.reduce(0) { $0 << 8 + FourCharCode($1) }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
