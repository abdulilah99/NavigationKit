import NavigationKit
import SwiftUI

extension Page: Navigable {
    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .home:
            "Home"
        case .library:
            "Library"
        case .search:
            "Search"
        case .settings:
            "Settings"
        case .article(let id):
            "Article \(id)"
        case .filters:
            "Filters"
        case .player(let id):
            "Player \(id)"
        case .toastBindings:
            "Binding toasts"
        }
    }

    var icon: Image {
        switch self {
        case .home:
            Image(systemName: "house")
        case .library:
            Image(systemName: "books.vertical")
        case .search:
            Image(systemName: "magnifyingglass")
        case .settings:
            Image(systemName: "gear")
        case .article:
            Image(systemName: "doc.text")
        case .filters:
            Image(systemName: "line.3.horizontal.decrease.circle")
        case .player:
            Image(systemName: "play.rectangle")
        case .toastBindings:
            Image(systemName: "bell.badge")
        }
    }

    var modifier: some ViewModifier {
        PageModifier(titleKey: titleKey)
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .home:
            HomeView()
        case .library:
            LibraryView()
        case .search:
            SearchView()
        case .settings:
            SettingsView()
        case .article(let id):
            ArticleView(id: id)
        case .filters:
            FiltersView()
        case .player(let id):
            PlayerView(id: id)
        case .toastBindings:
            ToastBindingDemoView()
        }
    }
}
