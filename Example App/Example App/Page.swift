//
//  Page.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import NavigationKit

enum Page: Navigable {
    case home
    case library
    case search
    case settings
    case article(Int)

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
        }
    }

    var image: Image {
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
        }
    }

    @ViewBuilder
    var destination: some View {
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
        }
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *)
    var role: TabRole? {
        switch self {
        case .search:
            .search
        default:
            nil
        }
    }
}

private struct HomeView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        List {
            Section("Typed links") {
                NavigationLink(value: Page.article(1))
                NavigationLink(value: Page.library)
            }

            Section("Programmatic navigation") {
                Button("Open Article 2 on Home") {
                    navigation.navigate(to: .article(2), on: .home)
                }

                Button("Open Article 3 in Library") {
                    navigation.navigate(to: .article(3), on: .library)
                }

                Button("Select Settings root") {
                    navigation.select(root: .settings)
                }
            }

            NavigationStateSection(navigation: navigation)
        }
        .navigationTitle("Home")
    }
}

private struct LibraryView: View {
    private let articleIDs = Array(1...8)

    var body: some View {
        List(articleIDs, id: \.self) { id in
            NavigationLink(value: Page.article(id))
        }
        .navigationTitle("Library")
    }
}

private struct SearchView: View {
    @State private var query = ""

    private var results: [Int] {
        guard let requestedID = Int(query) else {
            return Array(1...5)
        }

        return [requestedID]
    }

    var body: some View {
        List(results, id: \.self) { id in
            NavigationLink(value: Page.article(id))
        }
        .navigationTitle("Search")
        .searchable(text: $query, prompt: "Article number")
    }
}

private struct SettingsView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        List {
            Section("Root visibility") {
                Text("Settings is hidden from compact modern navigation chrome but remains programmatically selectable.")
            }

            Section("Navigation") {
                Button("Return to Home root") {
                    navigation.select(root: .home)
                }
            }

            NavigationStateSection(navigation: navigation)
        }
        .navigationTitle("Settings")
    }
}

private struct ArticleView: View {
    let id: Int

    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        List {
            Section("Destination identity") {
                Text("Article \(id)")
                Text("The associated value makes every article a distinct destination.")
            }

            ArticleBodySection()

            Section("Continue") {
                Button("Navigate to Article \(id + 1)") {
                    navigation.navigate(to: .article(id + 1))
                }

                Button("Open Settings root") {
                    navigation.select(root: .settings)
                }
            }
        }
        .navigationTitle("Article \(id)")
    }
}

private struct ArticleBodySection: View {
    var body: some View {
        Section("Article content") {
            Text("""
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
            """)

            Text("""
            Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """)

            Text("""
            Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
            """)

            Text("""
            Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.
            """)

            Text("""
            Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur.
            """)

            Text("""
            At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.
            """)

            Text("""
            Similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus.
            """)

            Text("""
            Omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae.
            """)
        }
    }
}

private struct NavigationStateSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Retained root paths") {
            ForEach(navigation.roots) { root in
                HStack {
                    Label(
                        title: { Text(root.destination.titleKey) },
                        icon: { root.destination.image }
                    )

                    Spacer()
                    Text("\(root.path.count) pushed")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
