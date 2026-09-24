import NavigationKit
import SwiftUI

@main
struct ExampleApp: App {
    @State private var navigation = makeExampleNavigationController()
    @State private var toasts = ToastController<ExampleToast>()

    var body: some Scene {
        WindowGroup {
            Group {
                if ProcessInfo.processInfo.arguments.contains("--navigation-only") {
                    navigation.makeView()
                } else if ProcessInfo.processInfo.arguments.contains("--standalone-toasts") {
                    navigation.makeView()
                        .toastPresentations(for: toasts)
                } else {
                    ContentView()
                }
            }
            .environment(navigation)
            .environment(toasts)
        }
    }
}
