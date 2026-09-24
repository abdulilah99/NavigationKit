# Getting started

NavigationKit models every place an app can navigate to with one `Navigable`
type. The controller owns the roots, paths, current selection, and modal stack;
SwiftUI owns the native presentation and interaction behavior.

## Install the package

Add the package through Xcode or `Package.swift`:

```swift
.package(
    url: "https://github.com/abdulilah99/NavigationKit.git",
    from: "1.1.1"
)
```

Add the `NavigationKit` product to the app target and import both frameworks
where navigation is declared:

```swift
import NavigationKit
import SwiftUI
```

## Define the app's destinations

An enum is usually the clearest model because associated values can carry the
identity of detail destinations.

```swift
enum Page: Navigable {
    case home
    case library
    case article(id: Int)

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .home: "Home"
        case .library: "Library"
        case .article(let id): "Article \(id)"
        }
    }

    var icon: Image {
        switch self {
        case .home: Image(systemName: "house")
        case .library: Image(systemName: "books.vertical")
        case .article: Image(systemName: "doc.text")
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .home: HomeView()
        case .library: LibraryView()
        case .article(let id): ArticleView(id: id)
        }
    }
}
```

The same value can be configured as a root, added to a route path, or
presented modally. These are placements, not separate destination concepts.

## Create the controller

Configure the roots once when the controller is created:

```swift
@MainActor
func makeNavigationController() -> NavigationController<Page> {
    NavigationController(
        roots: [
            NavigationRoot(destination: .home),
            NavigationRoot(destination: .library),
        ],
        selectedRoot: .home
    )
}
```

The root catalog is fixed for the controller's lifetime. If `selectedRoot` is
omitted, NavigationKit selects the first root. Initialization requires at least
one root, unique root destinations, and a configured initial selection.

## Share it through the environment

The controller is an observable, main-actor model. Own it with `@State` at the
app boundary and use SwiftUI's type-based environment:

```swift
@main
struct ExampleApp: App {
    @State private var navigation = makeNavigationController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigation)
        }
    }
}
```

Read the concrete controller type wherever navigation commands are needed:

```swift
@Environment(NavigationController<Page>.self) private var navigation
```

NavigationKit does not introduce a custom environment key or erase the
destination type.

## Render native navigation

Call `makeView()` when NavigationKit should provide the native tab/sidebar
interface and modal presentation handling:

```swift
struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        navigation.makeView()
    }
}
```

The view automatically selects the modern or legacy native implementation for
the running OS. Continue with [Destinations](destinations.md), or see
[Custom navigation views](custom-navigation-views.md) when the app supplies
its own navigation chrome.
