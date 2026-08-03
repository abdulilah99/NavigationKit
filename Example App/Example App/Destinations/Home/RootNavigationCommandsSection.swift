import NavigationKit
import SwiftUI

struct RootNavigationCommandsSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Programmatic navigation") {
            Button("Open Article 2 on Home") {
                navigation.navigate(to: .article(2), on: .home)
            }

            Button("Open Article 3 in Library") {
                navigation.navigate(to: .article(3), on: .library)
            }

            Button("Navigate back on Home") {
                navigation.navigateBack(on: .home)
            }

            Button("Return Home to its root") {
                navigation.returnToRoot(on: .home)
            }

            Button("Replace the Library path") {
                navigation.replacePath(
                    with: [.article(4), .article(5)],
                    on: .library
                )
            }

            Button("Select Settings root") {
                navigation.select(root: .settings)
            }
        }
    }
}
