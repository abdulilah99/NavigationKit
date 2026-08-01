# NavigationKit

NavigationKit is a SwiftUI navigation library for programmatic, type-safe navigation across iOS, iPadOS, macOS, tvOS, and visionOS.

It provides two ways to use the same navigation state:

- Call `controller.makeView()` for NavigationKit's native platform-adaptive host.
- Build your own tab bar, sidebar, or other navigation chrome using the controller's roots, selection, and commands.

Tabs and pushed routes use one destination type. A destination may be a root on one platform, appear only in a sidebar on another, and still be pushed inside any root's stack.

## Platform support

| Platform | Minimum | Modern navigation host |
| --- | ---: | --- |
| iOS and iPadOS | 17 | iOS 18 |
| tvOS | 17 | tvOS 18 |
| macOS | 14 | macOS 15 |
| visionOS | 1 | visionOS 2 |

On modern releases, NavigationKit uses SwiftUI's typed `Tab` API and sidebar-adaptable presentation. On older supported releases, it falls back to a native `TabView` while retaining the same controller and independent root paths.

## Requirements

- Swift 6.0 or newer
- Xcode 16 or newer
- SwiftUI and Observation

## Installation

Add the package in Xcode using:

```text
https://github.com/abdulilah99/NavigationKit.git
```

The API documented here describes the upcoming 0.2 release. Until 0.2 is tagged, select the repository's development branch. After the release, use the 0.2 version requirement:

```swift
.package(
    url: "https://github.com/abdulilah99/NavigationKit.git",
    from: "0.2.0"
)
```

Add the `NavigationKit` product to your app target, then import it:

```swift
import NavigationKit
```

## Core model

NavigationKit uses three core types:

- `Navigable` describes every destination in the application.
- `NavigationRoot` gives a configured top-level destination an independent path and presentation policy.
- `NavigationController` owns the fixed root catalog, selected root, and navigation commands.

“Tab” and “route” are presentation terms rather than separate destination types.

## Quick start

### 1. Define one destination type

An enum is a natural fit because its cases describe every reachable location and associated values provide identity for detail screens.

```swift
import NavigationKit
import SwiftUI

enum Page: Navigable {
    case home
    case library
    case settings
    case article(id: Int)

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .home: "Home"
        case .library: "Library"
        case .settings: "Settings"
        case .article(let id): "Article \(id)"
        }
    }

    var image: Image {
        switch self {
        case .home: Image(systemName: "house")
        case .library: Image(systemName: "books.vertical")
        case .settings: Image(systemName: "gear")
        case .article: Image(systemName: "doc.text")
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .home: HomeView()
        case .library: LibraryView()
        case .settings: SettingsView()
        case .article(let id): ArticleView(id: id)
        }
    }
}
```

Destination values must encode meaningful identity. For example, `.article(id: 42)` and `.article(id: 73)` are distinct locations and can coexist in a path.

### 2. Create the roots and controller

Only destinations placed in the controller's root catalog can be selected as roots. Each root owns an independent typed path.

```swift
@MainActor
func makeNavigationController() -> NavigationController<Page> {
    NavigationController(
        roots: [
            NavigationRoot(destination: .home),
            NavigationRoot(destination: .library),
            NavigationRoot(destination: .settings),
        ],
        selectedRoot: .home
    )
}
```

`selectedRoot` is optional during initialization. When omitted, the first configured root is selected.

The controller fails immediately when configured with:

- No roots.
- Duplicate root destinations.
- An initial selection that is not in the root catalog.

The catalog is intentionally fixed for the controller's lifetime. This preserves root identity, paths, SwiftUI state, and tvOS focus behavior.

### 3. Store and inject the controller

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

Destination views can then access the same controller:

```swift
struct HomeView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        Button("Open settings") {
            navigation.select(root: .settings)
        }
    }
}
```

### 4. Use the native host

```swift
struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        navigation.makeView()
    }
}
```

The host selects the appropriate native implementation for the running OS. Navigation commands and retained paths behave the same in the modern and legacy hosts.

## Navigation commands

### Select a root

```swift
navigation.select(root: .library)
```

Selection succeeds only when the destination belongs to the fixed root catalog. An unconfigured destination is ignored.

### Navigate on the selected root

```swift
navigation.navigate(to: .article(id: 42))
```

### Navigate on another root

```swift
navigation.navigate(
    to: .article(id: 42),
    on: .library
)
```

This updates the Library path and selects the Library root in one operation.

`navigate(to:on:)` has reuse semantics:

- If the destination is absent, it is appended.
- If it already exists, everything after its first occurrence is removed.
- When a target root is provided, that root is selected after its path is updated.
- If the target root is not configured, nothing changes.

### Read or replace a root path

```swift
let libraryPath = navigation[.library]

navigation[.library] = [
    .article(id: 10),
    .article(id: 11),
]
```

Reading an unconfigured root returns an empty path. Writing one is ignored. Dedicated push, pop, replace, and reset commands are planned for the evolving 0.2 API.

## Typed NavigationLink convenience

NavigationKit provides a label convenience for navigable values:

```swift
NavigationLink(value: Page.article(id: 42))
```

It builds the link's label from the destination's `titleKey` and `image`. The root's `NavigationStack` registers the matching typed destination automatically.

The same configured root can also be pushed as a route:

```swift
NavigationLink(value: Page.library)
```

This pushes Library inside the current stack. It does not select the Library root.

## Platform-specific root placement

Placement belongs to each `NavigationRoot`, not to the destination's identity.

```swift
let settingsRoot = NavigationRoot(
    destination: Page.settings,
    surfacePolicy: NavigationSurfacePolicy(
        compact: [],
        expanded: .sidebar,
        television: .sidebar,
        desktop: .sidebar,
        spatial: .sidebar
    )
)
```

Available semantic contexts:

```swift
NavigationPresentationContext.compact
NavigationPresentationContext.expanded
NavigationPresentationContext.television
NavigationPresentationContext.desktop
NavigationPresentationContext.spatial
```

Available surfaces:

```swift
NavigationSurfaces.tabBar
NavigationSurfaces.sidebar
NavigationSurfaces.all
[]
```

An empty surface set hides the root from navigation chrome where the native platform API supports it. The root remains configured and can still be selected programmatically.

You can use one placement everywhere:

```swift
NavigationRoot(
    destination: Page.library,
    surfacePolicy: NavigationSurfacePolicy(.sidebar)
)
```

### Native limitations

Not every platform and OS generation exposes identical tab/sidebar visibility controls:

- The iOS 17, tvOS 17, macOS 14, and visionOS 1 fallback keeps every root in its native `TabView`; it cannot exactly honor hidden-root policy without also removing that root's content.
- tvOS and macOS do not expose every visibility combination available on iOS and visionOS.
- NavigationKit uses deterministic native best-effort mappings. Surface limitations never alter selection, root membership, or retained paths.

## Custom navigation chrome

You do not need `makeView()` to use NavigationKit. Build controls from the same controller and render the selected root's content:

```swift
struct CustomNavigationHost: View {
    let navigation: NavigationController<Page>

    var body: some View {
        VStack {
            if let root = navigation.roots.first(
                where: { $0.destination == navigation.selectedRoot }
            ) {
                root.content
            }

            HStack {
                ForEach(navigation.roots) { root in
                    Button {
                        navigation.select(root: root.destination)
                    } label: {
                        Label(
                            title: { Text(root.destination.titleKey) },
                            icon: { root.destination.image }
                        )
                    }
                }
            }
        }
    }
}
```

Custom chrome decides its own layout, styling, focus behavior, and which roots to expose. It should call controller commands rather than assigning selection directly.

## Root roles

On modern OS releases, a destination may provide a native `TabRole` such as `.search`:

```swift
@available(iOS 18, macOS 15, tvOS 18, visionOS 2, *)
var role: TabRole? {
    self == .search ? .search : nil
}
```

Root-specific role metadata is expected to move from `Navigable` to root configuration before the 0.2 API is finalized.

## tvOS guidance

NavigationKit treats tvOS as a primary platform:

- tvOS 18 uses the modern native tab/sidebar host.
- tvOS 17 uses the native `TabView` fallback.
- Each root retains its own `NavigationStack` path.
- Standard stack navigation lets the remote's Back/Menu behavior remain native.
- Custom chrome should use native focusable controls such as `Button` and `NavigationLink`, not tap gestures.
- Keep focus state inside views rather than shared navigation state.

The included example target supports tvOS and demonstrates both the native host and a focusable custom root bar.

## Using the controller in a larger app model

`NavigationController` is concrete so it can enforce its catalog and selection invariants. Applications that need unrelated shared state should use composition:

```swift
@Observable
@MainActor
final class AppModel {
    let navigation: NavigationController<Page>
    var signedInUser: User?

    init() {
        navigation = makeNavigationController()
    }
}
```

This keeps navigation behavior consistent instead of asking each application controller to reimplement it.

## Example application

Open:

```text
Example App/Example App.xcodeproj
```

The example demonstrates:

- Native `makeView()` hosting.
- Custom root chrome using the same controller.
- Runtime switching between both hosts.
- A destination used as both a root and a pushed route.
- Programmatic navigation on the current and another root.
- Independent retained paths.
- Platform-specific surface policy.
- A programmatically selectable root hidden from compact modern chrome.
- A native search-role root.
- iOS, iPadOS, macOS, tvOS, and visionOS from one target.

## Current scope and roadmap

NavigationKit currently focuses on:

- A homogeneous, typed `[Destination]` path.
- A fixed root catalog.
- Independent paths for every root.
- Explicit selection and navigation.
- Native modern and legacy hosts.
- Custom-chrome access to the same state and commands.

Not yet included in the finalized API:

- `TabSection` support.
- Dynamic root insertion and removal.
- Deep-link parsing and atomic navigation intents.
- Codable restoration helpers.
- Dedicated push, pop, replace, and reset commands.
- Persisted tab customization.

The package also exports `ModalKit`, which is undergoing a presentation-state redesign. It is not used by the primary example and should be considered experimental until its dismissal, stacking, and full-screen behavior are finalized and tested.

## Design guarantees

- Tabs and routes share one destination identity.
- Surface placement never changes command behavior.
- Switching roots preserves every root's path.
- Hidden roots remain programmatically selectable.
- Missing roots never get inserted implicitly.
- Navigation state is isolated to the main actor.
- The library uses native platform containers rather than a custom focus or tab engine.

## Development

Run the package tests with:

```sh
swift test
```

The test suite covers path reuse, hash collisions, cross-root navigation, missing-root no-ops, fixed catalog validation, independent paths, and surface policies.
