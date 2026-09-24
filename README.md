# NavigationKit

NavigationKit is a type-safe, programmatic navigation library for SwiftUI on
iOS, iPadOS, macOS, tvOS, and visionOS.

Its central idea is that a tab, a sidebar item, a route, and a modal are all
placements of the same destination. A destination can be a tab on iPhone, a
sidebar item on iPad, and a route elsewhere without changing the app's model.

NavigationKit can render native adaptive navigation for you, or provide the
observable state and commands behind navigation views that you build yourself.

## NavigationKit 1.0

Version 1.0 is the first stable release. It includes:

- One `Navigable` type for roots, routes, sheets, and full-screen presentations.
- Independent typed paths for every root and modal occurrence.
- Programmatic selection, navigation, path replacement, and dismissal.
- Native adaptive tab and sidebar presentation with older-OS fallbacks.
- Platform-specific root placement without platform-specific destination types.
- Bounded, nested modal stacks with configurable presentation behavior.
- Equal support for `makeView()` and app-defined navigation views.
- Native focus, remote, back, and dismissal behavior on tvOS.

See the [1.0 changelog](CHANGELOG.md) and the
[migration guide](Documentation/Guidebook/migration-to-1.0.md).

## Requirements

| Platform | Minimum | Modern navigation API |
| --- | ---: | ---: |
| iOS and iPadOS | 17 | 18 |
| tvOS | 17 | 18 |
| macOS | 14 | 15 |
| visionOS | 1 | 2 |

NavigationKit requires Swift 6 and Xcode 16 or newer.

## Installation

Add NavigationKit with Xcode's package dependency interface, or declare it in
`Package.swift`:

```swift
.package(
    url: "https://github.com/abdulilah99/NavigationKit.git",
    from: "1.1.1"
)
```

Add the `NavigationKit` product to the app target, then import it:

```swift
import NavigationKit
```

## Quick start

Define one destination type:

```swift
import NavigationKit
import SwiftUI

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

Create a controller from the app's fixed root catalog and place it in SwiftUI's
type-based environment:

```swift
@main
struct ExampleApp: App {
    @State private var navigation = NavigationController(
        roots: [
            NavigationRoot(destination: Page.home),
            NavigationRoot(destination: Page.library),
        ]
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigation)
        }
    }
}
```

Use NavigationKit's native view:

```swift
struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        navigation.makeView()
    }
}
```

Descendant views can use the same controller for programmatic navigation:

```swift
navigation.select(root: .library)
navigation.navigate(to: .article(id: 42))
navigation.present(.article(id: 73), as: .sheet)
```

## Guidebook

The [NavigationKit Guidebook](Documentation/Guidebook/README.md) contains the
complete usage documentation:

- [Getting started](Documentation/Guidebook/getting-started.md)
- [Destinations](Documentation/Guidebook/destinations.md)
- [Roots and platform placement](Documentation/Guidebook/roots-and-platforms.md)
- [Navigation commands](Documentation/Guidebook/navigation-commands.md)
- [Modal presentations](Documentation/Guidebook/presentations.md)
- [Custom navigation views](Documentation/Guidebook/custom-navigation-views.md)
- [Toasts](Documentation/Guidebook/toasts.md)
- [Migrating from 0.1.x](Documentation/Guidebook/migration-to-1.0.md)

## Toasts

NavigationKit 1.1 includes a typed toast engine. An app-owned
`Toastable` enum supplies custom SwiftUI content, expiration, placement, and swipe permission.
`ToastController<Toast>` maintains independent occurrences and collapsed top and
bottom decks. Add `.navigationToasts(for:)`
after `navigation.makeView()` or `.navigationPresentations(for:)` to carry those
decks through native sheets and covers:

```swift
navigation.makeView()
    .navigationToasts(for: toasts)

CustomNavigationView(navigation: navigation)
    .navigationPresentations(for: navigation)
    .navigationToasts(for: toasts)
```

Navigation and toast hosting are independent. If you used the original 1.1.0 tag,
see the API changes in the [changelog](CHANGELOG.md).

For a screen-owned toast, use `.toast(isPresented:content:)` with a custom view
or `.toast(isPresented:toast:)` with an enum value. Use `.toast(item:)` when the
enum is stored in an optional binding. Both enum forms require `Toastable & Equatable`.
By default, top toasts use the container's safe top and bottom toasts clear bottom
navigation controls. `ToastStackConfiguration(placement:)` also supports
`.container` and `.content` for apps that prefer either behavior on both edges.
See the [toast guide](Documentation/Guidebook/toasts.md) for the complete API.

## Example application

Open `Example App/Example App.xcodeproj` to explore both supported integration
styles. The example can switch between NavigationKit's native view and custom
navigation views backed by the same controller. It runs from one target on iOS,
iPadOS, macOS, tvOS, and visionOS.

## Scope

NavigationKit 1.0 intentionally uses one homogeneous destination type and a
fixed root catalog. Deep-link parsing, state-restoration helpers, dynamic root
catalogs, `TabSection`, and persisted tab customization are not part of 1.0.

## Development

Run the package test suite with:

```sh
swift test
```

The suite covers root and presentation navigation, retained paths, validation,
surface policies, presentation limits, repeated modal occurrences, cascading
dismissal, callbacks, and reentrant presentation behavior.
