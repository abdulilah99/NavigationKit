import NavigationKit
import SwiftUI

struct ArticleView: View {
    let id: Int

    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        List {
            ArticleIdentitySection(id: id)
            ArticleBodySection()
            ArticleNavigationSection(id: id, navigation: navigation)
            ArticlePresentationSection(id: id, navigation: navigation)
            PresentationNavigationCommandsSection(navigation: navigation)
            PresentationControlsSection(navigation: navigation)
            PresentationStateSection(navigation: navigation)
        }
        .navigationTitle("Article \(id)")
    }
}
