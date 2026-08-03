import NavigationKit
import SwiftUI

struct ControllerConfigurationSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        @Bindable var navigation = navigation

        Section("Controller configuration") {
            Picker(
                "Default modal style",
                selection: $navigation.configuration.defaultPresentationStyle
            ) {
                Text("Sheet").tag(NavigationPresentationStyle.sheet)
                Text("Full screen").tag(NavigationPresentationStyle.fullScreen)
            }

            HStack {
                Text("Maximum modal depth")

                Spacer()

                Button {
                    navigation.configuration.maximumPresentationDepth -= 1
                } label: {
                    Label("Decrease", systemImage: "minus")
                        .labelStyle(.iconOnly)
                }
                .disabled(
                    navigation.configuration.maximumPresentationDepth == 0
                )

                Text("\(navigation.configuration.maximumPresentationDepth)")
                    .monospacedDigit()

                Button {
                    navigation.configuration.maximumPresentationDepth += 1
                } label: {
                    Label("Increase", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
                .disabled(
                    navigation.configuration.maximumPresentationDepth >= 16
                )
            }

            Text(
                navigation.hasPresentationCapacity
                    ? "The controller can present another layer."
                    : "The presentation limit has been reached."
            )
            .foregroundStyle(.secondary)
        }
    }
}
