import NavigationKit
import SwiftUI

struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation
    @Environment(ToastController<ExampleToast>.self) private var toasts
    @State private var viewMode = NavigationViewMode.native
    @State private var toastPlacement = ToastStackConfiguration.Placement.automatic

    var body: some View {
        VStack(spacing: 0) {
            NavigationViewModePicker(selection: $viewMode)
            Picker("Toast placement", selection: $toastPlacement) {
                Text("Automatic").tag(ToastStackConfiguration.Placement.automatic)
                Text("Container").tag(ToastStackConfiguration.Placement.container)
                Text("Content").tag(ToastStackConfiguration.Placement.content)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color.secondary.opacity(0.08))
            .accessibilityIdentifier("toast-placement")

            switch viewMode {
            case .native:
                navigation.makeView()
                    .navigationToasts(for: toasts, configuration: .init(placement: toastPlacement))
            case .custom:
                CustomNavigationView(navigation: navigation)
                    .navigationPresentations(for: navigation)
                    .navigationToasts(for: toasts, configuration: .init(placement: toastPlacement))
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(makeExampleNavigationController())
        .environment(ToastController<ExampleToast>())
}
