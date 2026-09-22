import NavigationKit
import SwiftUI

struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation
    @Environment(ToastController<ExampleToast>.self) private var toasts
    @State private var viewMode = NavigationViewMode.native

    var body: some View {
        VStack(spacing: 0) {
            NavigationViewModePicker(selection: $viewMode)

            switch viewMode {
            case .native:
                navigation.makeView(toasts: toasts)
            case .custom:
                CustomNavigationView(navigation: navigation)
                    .navigationPresentations(for: navigation, toasts: toasts)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(makeExampleNavigationController())
        .environment(ToastController<ExampleToast>())
}
