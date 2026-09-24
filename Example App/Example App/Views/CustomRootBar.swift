import NavigationKit
import SwiftUI

struct CustomRootBar: View {
    let navigation: NavigationController<Page>

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(navigation.roots) { root in
                    Button {
                        navigation.select(root: root.destination)
                    } label: {
                        Label(
                            title: { Text(root.destination.titleKey) },
                            icon: { root.destination.icon }
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(
                        navigation.selectedRoot == root.destination
                            ? .accentColor
                            : .secondary
                    )
                    .accessibilityAddTraits(
                        navigation.selectedRoot == root.destination
                            ? .isSelected
                            : []
                    )
                }
            }
            .padding()
        }
        .accessibilityIdentifier("custom-root-bar")
    }
}
