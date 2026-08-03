import NavigationKit
import SwiftUI

struct ArticleNavigationSection: View {
    let id: Int
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Continue") {
            Button("Navigate to Article \(id + 1)") {
                navigation.navigate(to: .article(id + 1))
            }

            Button("Open Settings root") {
                navigation.select(root: .settings)
            }
        }
    }
}
