import NavigationKit
import SwiftUI

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
