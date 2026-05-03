import SwiftUI

struct ActionStepRow: View {
    @Binding var step: ActionStep
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            stepIcon
                .frame(width: 28, height: 28)
                .background(iconBackground)
                .cornerRadius(6)
            stepEditor
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash").foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
    }

    @ViewBuilder private var stepIcon: some View {
        switch step {
        case .typeText: Image(systemName: "character.cursor.ibeam").font(.caption)
        case .paste:    Image(systemName: "doc.on.clipboard").font(.caption)
        case .pressKey: Image(systemName: "return").font(.caption)
        case .delay:    Image(systemName: "clock").font(.caption)
        case .shell:    Image(systemName: "terminal").font(.caption)
        }
    }

    private var iconBackground: Color {
        switch step {
        case .typeText: return .blue.opacity(0.15)
        case .paste:    return .purple.opacity(0.15)
        case .pressKey: return .green.opacity(0.15)
        case .delay:    return .orange.opacity(0.15)
        case .shell:    return .gray.opacity(0.15)
        }
    }

    @ViewBuilder private var stepEditor: some View {
        switch step {
        case .typeText(var d):
            VStack(alignment: .leading) {
                Text("Type Text").font(.caption).foregroundColor(.secondary)
                TextField("Text to type\u{2026}", text: Binding(get: { d.text }, set: { d.text = $0; step = .typeText(d) }))
                    .textFieldStyle(.roundedBorder)
            }
        case .paste(var d):
            VStack(alignment: .leading) {
                Text("Paste Text").font(.caption).foregroundColor(.secondary)
                TextField("Text to paste\u{2026}", text: Binding(get: { d.text }, set: { d.text = $0; step = .paste(d) }))
                    .textFieldStyle(.roundedBorder)
            }
        case .pressKey(let d):
            VStack(alignment: .leading) {
                Text("Press Key").font(.caption).foregroundColor(.secondary)
                Text(KeyCodeMap.name(for: d.keyCode)).fontWeight(.medium)
            }
        case .delay(var d):
            HStack {
                Text("Wait").font(.caption).foregroundColor(.secondary)
                TextField(value: Binding(get: { d.milliseconds }, set: { d.milliseconds = $0; step = .delay(d) }), format: .number) { EmptyView() }
                    .textFieldStyle(.roundedBorder).frame(width: 70)
                Text("ms")
            }
        case .shell(var d):
            VStack(alignment: .leading) {
                Text("Shell Command").font(.caption).foregroundColor(.secondary)
                TextField("command\u{2026}", text: Binding(get: { d.command }, set: { d.command = $0; step = .shell(d) }))
                    .textFieldStyle(.roundedBorder).font(.system(.body, design: .monospaced))
                Toggle("Type stdout into focused app", isOn: Binding(get: { d.captureOutputAsType }, set: { d.captureOutputAsType = $0; step = .shell(d) }))
                    .font(.caption)
            }
        }
    }
}
