import NavigationKit
import SwiftUI

@main
struct ExampleApp: App {
    @State private var navigation = makeExampleNavigationController()
    @State private var toasts = ToastController<ExampleToast>()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigation)
                .environment(toasts)
        }
    }
}
