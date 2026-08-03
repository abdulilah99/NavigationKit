import NavigationKit
import SwiftUI

@main
struct ExampleApp: App {
    @State private var navigation = makeExampleNavigationController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigation)
        }
    }
}
