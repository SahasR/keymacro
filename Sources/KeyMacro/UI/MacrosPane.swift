import SwiftUI

struct MacrosPane: View {
    @EnvironmentObject var store: MacroStore
    @State private var selectedID: UUID?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedID) {
                ForEach(store.macros) { macro in
                    MacroRow(macro: macro)
                        .tag(macro.id)
                        .contextMenu {
                            Button(role: .destructive) {
                                if selectedID == macro.id { selectedID = nil }
                                store.delete(macro)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onMove(perform: store.move)
            }
            .frame(minWidth: 200)

            Divider()
            HStack(spacing: 0) {
                Button(action: addMacro) {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 24)
                }
                .buttonStyle(.borderless)
                Button {
                    if let id = selectedID,
                       let macro = store.macros.first(where: { $0.id == id }) {
                        selectedID = nil
                        store.delete(macro)
                    }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 28, height: 24)
                }
                .buttonStyle(.borderless)
                .disabled(selectedID == nil)
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        } detail: {
            if let id = selectedID, let idx = store.macros.firstIndex(where: { $0.id == id }) {
                MacroEditor(macro: $store.macros[idx])
            } else {
                Text("Select a macro to edit")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func addMacro() {
        let m = Macro(
            name: "New Macro",
            hotKey: HotKey(keyCode: 0, modifiers: 0, displayString: "\u{2014}"),
            steps: []
        )
        store.add(m)
        selectedID = m.id
    }
}

struct MacroRow: View {
    @EnvironmentObject var store: MacroStore
    let macro: Macro

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(macro.name).fontWeight(.medium)
                Text(macro.hotKey.displayString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { macro.enabled },
                set: { newVal in
                    var m = macro; m.enabled = newVal; store.update(m)
                }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 2)
    }
}
