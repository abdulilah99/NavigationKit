import NavigationKit
import SwiftUI

struct NavigationStateSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Retained root paths") {
            ForEach(navigation.roots) { root in
                HStack {
                    Label(
                        title: { Text(root.destination.titleKey) },
                        icon: { root.destination.icon }
                    )

                    Spacer()

                    Text("\(root.path.count) destinations")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
