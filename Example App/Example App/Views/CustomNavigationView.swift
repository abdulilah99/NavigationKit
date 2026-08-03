import NavigationKit
import SwiftUI

/// Demonstrates custom navigation chrome backed by the same controller used by
/// NavigationKit's native view.
struct CustomNavigationView: View {
    let navigation: NavigationController<Page>

    var body: some View {
        VStack(spacing: 0) {
            if let selectedRoot = navigation.roots.first(
                where: { $0.destination == navigation.selectedRoot }
            ) {
                selectedRoot.content
            }

            Divider()
            CustomRootBar(navigation: navigation)
        }
    }
}
