import NavigationKit
import SwiftUI

struct PresentationNavigationCommandsSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Top presentation navigation") {
            if let presentation = navigation.presentations.last {
                Button("Navigate to Article 40") {
                    navigation.navigate(
                        to: .article(40),
                        in: presentation.id
                    )
                }

                Button("Navigate back") {
                    navigation.navigateBack(in: presentation.id)
                }

                Button("Return to the presentation root") {
                    navigation.returnToRoot(in: presentation.id)
                }

                Button("Replace the presentation path") {
                    navigation.replacePath(
                        with: [.article(41), .filters],
                        in: presentation.id
                    )
                }
            } else {
                Text("No modal presentation to navigate")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
