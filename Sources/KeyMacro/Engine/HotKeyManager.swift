import Carbon.HIToolbox
import Combine

final class HotKeyManager {
    private var store: MacroStore
    private var registeredRefs: [UUID: EventHotKeyRef] = [:]
    private var cancellable: AnyCancellable?
    private var eventHandlerRef: EventHandlerRef?
    private var hotKeyIDMap: [UUID: UInt32] = [:]
    private var idToMacroID: [UInt32: UUID] = [:]
    private var _nextID: UInt32 = 1

    init(store: MacroStore) {
        self.store = store
        installEventHandler()
        cancellable = store.$macros
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.registerAll() }
    }

    func registerAll() {
        unregisterAll()
        for macro in store.macros where macro.enabled {
            register(macro)
        }
    }

    private func register(_ macro: Macro) {
        let hk = macro.hotKey
        let idVal = hotKeyIDMap[macro.id] ?? nextID()
        hotKeyIDMap[macro.id] = idVal
        idToMacroID[idVal] = macro.id
        let hotKeyID = EventHotKeyID(signature: fourCC("KMAC"), id: idVal)
        var ref: EventHotKeyRef?
        RegisterEventHotKey(hk.keyCode, hk.modifiers, hotKeyID,
                            GetApplicationEventTarget(), 0, &ref)
        if let ref = ref { registeredRefs[macro.id] = ref }
    }

    private func unregisterAll() {
        for ref in registeredRefs.values { UnregisterEventHotKey(ref) }
        registeredRefs.removeAll()
    }

    private func nextID() -> UInt32 { defer { _nextID += 1 }; return _nextID }

    private func installEventHandler() {
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, ctx) -> OSStatus in
                guard let ctx = ctx else { return noErr }
                let mgr = Unmanaged<HotKeyManager>.fromOpaque(ctx).takeUnretainedValue()
                var hkID = EventHotKeyID()
                GetEventParameter(event!, EventParamName(kEventParamDirectObject),
                                  EventParamType(typeEventHotKeyID), nil,
                                  MemoryLayout<EventHotKeyID>.size, nil, &hkID)
                if let macroID = mgr.idToMacroID[hkID.id],
                   let macro = mgr.store.macros.first(where: { $0.id == macroID }) {
                    MacroEngine.shared.run(macro)
                }
                return noErr
            },
            1, &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
    }

    deinit {
        unregisterAll()
        if let ref = eventHandlerRef { RemoveEventHandler(ref) }
    }
}

private func fourCC(_ s: String) -> FourCharCode {
    s.utf8.reduce(0) { $0 << 8 + FourCharCode($1) }
}
