import NavigationKit
import SwiftUI

struct PresentationControlsSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Dismiss presentations") {
            Button("Dismiss top presentation") {
                navigation.dismissPresentation()
            }

            Button("Dismiss top two presentations") {
                navigation.dismissPresentations(count: 2)
            }

            Button("Dismiss all presentations", role: .destructive) {
                navigation.dismissAllPresentations()
            }
        }
    }
}
