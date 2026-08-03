import NavigationKit
import SwiftUI

struct ModalPresentationCommandsSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Modal presentation stacks") {
            Button("Present Article 10 using the configured style") {
                navigation.present(.article(10))
            }

            Button("Present Article 10 as a sheet") {
                navigation.present(.article(10), as: .sheet)
            }

            Button("Present Player 1 full screen") {
                navigation.present(.player(1), as: .fullScreen)
            }

            Button("Build a three-layer mixed stack") {
                navigation.present(.article(20), as: .sheet)
                navigation.present(.filters, as: .sheet)
                navigation.present(.player(2), as: .fullScreen)
            }
        }
    }
}
