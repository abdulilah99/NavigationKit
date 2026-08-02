# NavigationKit

NavigationKit is a SwiftUI navigation library for programmatic, type-safe navigation across iOS, iPadOS, macOS, tvOS, and visionOS.

It provides two ways to use the same navigation state:

- Call `controller.makeView()` for NavigationKit's native platform-adaptive host.
- Build your own tab bar, sidebar, or other navigation chrome using the controller's roots, selection, and commands.

Tabs, pushed routes, sheets, and full-screen presentations use one destination type. A destination may be a root on one platform, appear only in a sidebar on another, be pushed inside a stack, or occur multiple times in a modal stack.

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

NavigationKit uses five core types:

- `Navigable` describes every destination in the application.
- `NavigationRoot` gives a configured top-level destination an independent path and presentation policy.
- `NavigationPresentation` represents one stable occurrence in the modal stack and owns an independent route path.
- `NavigationControllerConfiguration` contains mutable controller-wide policies.
- `NavigationController` owns the fixed root catalog, selected root, modal stack, and navigation commands.

“Tab,” “route,” “sheet,” and “full screen” are presentation terms rather than separate destination types.

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
        configuration: NavigationControllerConfiguration(
            defaultPresentationStyle: .sheet,
            maximumPresentationDepth: 8
        ),
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

## Controller configuration

`NavigationControllerConfiguration` contains policies that apply across the
whole controller:

```swift
let configuration = NavigationControllerConfiguration(
    defaultPresentationStyle: .sheet,
    maximumPresentationDepth: 8
)

let navigation = NavigationController(
    roots: roots,
    configuration: configuration
)
```

The configuration is mutable after initialization:

```swift
navigation.configuration.defaultPresentationStyle = .fullScreen
navigation.configuration.maximumPresentationDepth = 4
```

Configuration changes affect future operations. They do not rewrite existing
paths or presentations. Lowering the maximum below the current presentation
depth preserves the current stack and blocks new presentations until enough
layers are dismissed. A maximum depth of zero disables new presentations.

## Modal presentation stacks

Modal presentation is part of `NavigationController`; there is no separate modal destination type or controller.

### Present destinations

```swift
navigation.present(.settings, as: .sheet)
navigation.present(.article(id: 42), as: .fullScreen)
```

Omit `as:` to use `configuration.defaultPresentationStyle`:

```swift
navigation.present(.article(id: 42))
```

`present` appends a new occurrence while the controller is below its configured
maximum depth. It returns `nil` without changing state when the limit has been
reached:

```swift
guard let presentation = navigation.present(.article(id: 42)) else {
    return
}
```

Use `navigation.canPresent` when presentation availability should be reflected
in custom UI. Rejected presentations do not retain or invoke their dismissal
callbacks.

Occurrence identity is separate from destination identity. Presenting `.article(id: 42)` twice produces two distinct stack entries, which is useful for recursive workflows and repeated detail contexts.

Every presentation owns an independent typed route path. Navigate within one presentation using its stable ID:

```swift
navigation.navigate(
    to: .article(id: 43),
    in: presentation.id
)

navigation[presentation: presentation.id] = [
    .article(id: 44),
    .article(id: 45),
]
```

The root paths underneath the modal stack are unaffected.

### Build nested stacks

Presenting while another destination is presented creates a native child presentation:

```swift
navigation.present(.article(id: 42), as: .sheet)
navigation.present(.settings, as: .sheet)
navigation.present(.article(id: 43), as: .fullScreen)
```

NavigationKit hosts these as a real presenting hierarchy: application content presents the article, the article presents the filters, and the filters present the player. It does not use timing delays to simulate a stack.

### Dismiss presentations

```swift
navigation.dismissPresentation()
navigation.dismissPresentations(count: 2)
navigation.dismissAllPresentations()
navigation.dismissPresentation(id: presentation.id)
```

`dismissPresentation(id:)` removes the identified presentation and every presentation above it. A native child cannot outlive the presentation that owns it. Dismissal callbacks run exactly once in top-to-bottom order:

```swift
navigation.present(.settings, as: .sheet) {
    // Runs when this occurrence leaves the controller's stack.
}
```

The public `presentations` array is read-only from outside the controller and can be inspected to render debugging or custom state UI.

### Platform behavior

- `.sheet` uses native sheets everywhere.
- `.fullScreen` uses native full-screen covers on iOS and tvOS.
- macOS and visionOS do not expose SwiftUI full-screen covers, so `.fullScreen` deterministically falls back to a native sheet there.
- Remote Back/Menu and interactive sheet dismissal update the same controller stack.

### Migrating from ModalKit

NavigationKit 0.2 removes the separate `ModalKit` product and its `Modal` and `ModalController` protocols.

- Add only the `NavigationKit` product and remove `import ModalKit`.
- Add modal-only cases to the same type that conforms to `Navigable`.
- Replace `present(sheet:)` with `navigation.present(_:as:path:onDismiss:)`.
- Replace mutation of a `sheets` array with the explicit dismissal commands.
- Remove `.sheets(items:)`. `makeView()` hosts presentations automatically; custom hosts apply `.navigationPresentations(navigation)` once.

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
        .navigationPresentations(navigation)
    }
}
```

Custom chrome decides its own layout, styling, focus behavior, and which roots to expose. It should call controller commands rather than assigning selection directly. Apply `.navigationPresentations(navigation)` exactly once around a custom host. `makeView()` installs it automatically.

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
- Nested sheets and full-screen covers use native presentation and dismissal behavior.
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
- Nested sheet and full-screen presentation stacks.
- Repeated modal occurrences of the same destination.
- Independent route paths inside modal presentations.
- Top, counted, cascading, and complete modal dismissal.
- Runtime editing of controller-wide presentation configuration.
- Platform-specific surface policy.
- A programmatically selectable root hidden from compact modern chrome.
- A native search-role root.
- iOS, iPadOS, macOS, tvOS, and visionOS from one target.

## Current scope and roadmap

NavigationKit currently focuses on:

- A homogeneous, typed `[Destination]` path.
- A fixed root catalog.
- Independent paths for every root.
- First-class modal stacks with independent paths for every presentation.
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

## Design guarantees

- Tabs, routes, sheets, and full-screen presentations share one destination type.
- Modal occurrences have stable identity independent from destination identity.
- Repeated destination values are valid in a modal stack.
- Modal-stack growth is bounded by mutable controller configuration.
- Removing a presentation removes every presentation above it.
- Dismissal callbacks run exactly once from the top layer downward.
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

The test suite covers path reuse, hash collisions, cross-root navigation, missing-root no-ops, fixed catalog validation, independent paths, surface policies, controller configuration, bounded modal growth, repeated modal occurrences, modal paths, cascading dismissal, callbacks, and reentrant presentation.
