import SwiftUI

struct SettingsRoot: View {
    @EnvironmentObject var store: MacroStore

    var body: some View {
        TabView {
            MacrosPane()
                .tabItem { Label("Macros", systemImage: "keyboard") }
                .environmentObject(store)
            GeneralPane()
                .tabItem { Label("General", systemImage: "gearshape") }
                .environmentObject(store)
            AboutPane()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(minWidth: 680, minHeight: 480)
    }
}
