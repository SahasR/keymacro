import SwiftUI

struct MacroEditor: View {
    @Binding var macro: Macro

    var body: some View {
        Form {
            Section("Info") {
                TextField("Name", text: $macro.name)
                HotKeyRecorder(hotKey: $macro.hotKey)
                    .labelsHidden()
            }
            Section("Steps") {
                ForEach($macro.steps) { $step in
                    ActionStepRow(step: $step, onDelete: {
                        macro.steps.removeAll { $0.id == step.id }
                    })
                }
                .onMove { src, dst in macro.steps.move(fromOffsets: src, toOffset: dst) }

                Menu("+ Add Step") {
                    Button("Type Text") { macro.steps.append(.typeText(.init(text: ""))) }
                    Button("Paste Text") { macro.steps.append(.paste(.init(text: ""))) }
                    Button("Press Key") { macro.steps.append(.pressKey(.init(keyCode: 36, modifiers: 0))) }
                    Button("Delay") { macro.steps.append(.delay(.init(milliseconds: 200))) }
                    Button("Run Shell Command") { macro.steps.append(.shell(.init(command: "", captureOutputAsType: false))) }
                }
                .menuStyle(.borderlessButton)
                .frame(maxWidth: 120)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
