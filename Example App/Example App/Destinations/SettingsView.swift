import NavigationKit
import SwiftUI

struct SettingsView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        List {
            Section("Root visibility") {
                Text("Settings is hidden from compact modern navigation chrome but remains programmatically selectable.")
            }

            Section("Navigation") {
                Button("Return to Home root") {
                    navigation.select(root: .home)
                }
            }

            NavigationStateSection(navigation: navigation)
        }
        .navigationTitle("Settings")
    }
}
