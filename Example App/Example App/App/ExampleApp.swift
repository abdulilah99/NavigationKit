import NavigationKit
import SwiftUI

@main
struct ExampleApp: App {
    @State private var navigation = makeExampleNavigationController()
    @State private var toasts = ToastController<ExampleToast>()

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--presentation-direction") {
                PresentationDirectionFixture(rightToLeft: ProcessInfo.processInfo.arguments.contains("--rtl"))
            } else {
                exampleContent
            }
            #else
            exampleContent
            #endif
        }
    }

    private var exampleContent: some View {
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
