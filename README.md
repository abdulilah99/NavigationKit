# NavigationKit

NavigationKit provides type-safe, programmatic SwiftUI navigation for iOS,
iPadOS, macOS, tvOS, and visionOS.

Its central idea is simple: a tab, a sidebar item, a route, a sheet, and a
full-screen presentation are all placements of the same destination. A page can
be a tab on iPhone, a sidebar item on iPad, and a route somewhere else without
becoming a different concept in the app's model.

NavigationKit can provide the native navigation view, or it can provide only
the state and commands behind navigation chrome that you build yourself.

## Capabilities

- One `Navigable` type for roots, routes, sheets, and full-screen presentations.
- One optional destination modifier applied consistently in every placement.
- A fixed root catalog with an independent, retained path for every root.
- Programmatic root selection, navigation, backward navigation, returning to a
  root, and complete path replacement.
- Native adaptive navigation using modern SwiftUI tabs and sidebars, with a
  native `TabView` fallback on older supported releases.
- Platform-specific root placement without changing destination identity or
  navigation behavior.
- Native search-root roles where the platform supports them.
- Nested modal stacks with stable occurrence identity and an independent route
  path inside every presentation.
- Configurable presentation style and maximum modal depth.
- Custom tab bars, sidebars, and other navigation views backed by the same
  controller and commands.
- First-class tvOS support using native focus and navigation behavior.

## Platform support

| Platform | Minimum | Modern navigation view |
| --- | ---: | ---: |
| iOS and iPadOS | 17 | 18 |
| tvOS | 17 | 18 |
| macOS | 14 | 15 |
| visionOS | 1 | 2 |

The package requires Swift 6 and Xcode 16 or newer.

## Installation

Add the package in Xcode using:

```text
https://github.com/abdulilah99/NavigationKit.git
```

The API documented here targets NavigationKit 0.2. Until 0.2 is tagged, select
the repository's development branch. After release, use:

```swift
.package(
    url: "https://github.com/abdulilah99/NavigationKit.git",
    from: "0.2.0"
)
```

Add the `NavigationKit` product to the app target and import it:

```swift
import NavigationKit
```

## Getting started

### Define the destinations

One type describes every location the app can display. An enum works well
because associated values can carry the identity of detail pages.

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

    var icon: Image {
        switch self {
        case .home: Image(systemName: "house")
        case .library: Image(systemName: "books.vertical")
        case .settings: Image(systemName: "gear")
        case .article: Image(systemName: "doc.text")
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .home: HomeView()
        case .library: LibraryView()
        case .settings: SettingsView()
        case .article(let id): ArticleView(id: id)
        }
    }
}
```

`titleKey` is intentionally a `LocalizedStringKey`, so SwiftUI resolves it as
localizable text. Destination values should encode meaningful identity:
`.article(id: 42)` and `.article(id: 73)` are different locations.

### Apply behavior to every destination view

`Navigable.modifier` is the shared SwiftUI modifier for a destination. The
default is `EmptyModifier`, so destinations only implement it when they need
shared behavior. NavigationKit applies the modifier whenever it renders that
destination as a root, a route, a sheet, or a full-screen presentation.

For example, the destination's localizable title can be attached once instead
of repeated in every view:

```swift
struct PageModifier: ViewModifier {
    let titleKey: LocalizedStringKey

    func body(content: Content) -> some View {
        content.navigationTitle(titleKey)
    }
}

extension Page {
    var modifier: some ViewModifier {
        PageModifier(titleKey: titleKey)
    }
}
```

The modifier can also install environment dependencies, toolbars, lifecycle
behavior, accessibility metadata, or app-wide destination styling. Custom
navigation chrome receives the same behavior when it renders
`NavigationRoot.content` and uses `.navigationPresentations(for:)` for modals.

### Configure the roots

A root is a destination configured as a top-level entry. Every root owns an
independent route path that survives switching to another root.

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

The root catalog is fixed for the controller's lifetime. This gives roots
stable identity and preserves their navigation paths, SwiftUI state, and tvOS
focus behavior.

The controller requires:

- At least one root.
- A unique destination for every root.
- An initial selection that belongs to the root catalog.
- Unique initial presentation IDs.
- An initial presentation stack within the configured maximum depth.

If `selectedRoot` is omitted, the first root is selected.

Roots can start with a route path when the app already has navigation state:

```swift
NavigationRoot(
    destination: Page.library,
    path: [.article(id: 42)]
)
```

`NavigationController` also accepts an initial presentation stack for apps
that construct the complete initial state themselves.

### Inject the controller

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

Views can read the same observable controller from the environment:

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

### Make the native navigation view

```swift
struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        navigation.makeView()
    }
}
```

`makeView()` selects the modern or legacy native implementation for the running
OS and installs modal presentation handling automatically.

## Root navigation

All path mutations go through the controller, keeping native and custom
navigation views synchronized.

| Capability | Command |
| --- | --- |
| Select a configured root | `navigation.select(root: .library)` |
| Navigate on the selected root | `navigation.navigate(to: .article(id: 42))` |
| Navigate on another root | `navigation.navigate(to: .article(id: 42), on: .library)` |
| Navigate backward | `navigation.navigateBack()` |
| Navigate backward multiple steps | `navigation.navigateBack(2, on: .library)` |
| Return to a root destination | `navigation.returnToRoot(on: .library)` |
| Read a root path | `navigation[.library]` |
| Replace a complete path | `navigation.replacePath(with: path, on: .library)` |

When an `on:` root is supplied, a successful operation also selects that root.
Unconfigured roots are ignored, and reading one returns an empty path.

`navigate(to:)` reuses the first matching destination already in the target
path. If the destination is absent, it is appended. If it is present, everything
after that occurrence is removed. This avoids adding duplicate path entries for
ordinary programmatic navigation.

`navigateBack` removes up to the requested number of entries. Nonpositive
counts are ignored, and navigating farther back than the current depth safely
returns to the root.

Paths are publicly readable but mutate only through controller commands.

### Typed navigation links

NavigationKit adds a label convenience for value-based links:

```swift
NavigationLink(value: Page.article(id: 42))
```

The label uses the destination's `titleKey` and `icon`. The root or modal
navigation stack registers the matching typed destination automatically.

A configured root can also be used as a normal route:

```swift
NavigationLink(value: Page.library)
```

This displays Library inside the current path. It does not select the Library
root, because route placement and root selection are separate operations.

## Modal navigation

Modal stacks are part of `NavigationController`; they do not need a second
destination type or controller.

### Present a destination

```swift
navigation.present(.settings)
navigation.present(.article(id: 42), as: .sheet)
navigation.present(.article(id: 42), as: .fullScreen)
navigation.present(
    .library,
    path: [.article(id: 42)]
)
```

Omitting `as:` uses `configuration.defaultPresentationStyle`. Each call creates
a new presentation occurrence, so the same destination can appear more than
once in a stack without an identity collision.

`present` returns the created `NavigationPresentation`, or `nil` when the
configured depth limit has been reached:

```swift
guard let presentation = navigation.present(.article(id: 42)) else {
    return
}
```

`navigation.hasPresentationCapacity` exposes the same capacity check for
custom UI.

### Navigate inside a presentation

Every presentation owns a route path independent from all roots and other
presentations. Use the occurrence's stable ID to address it:

```swift
navigation.navigate(
    to: .article(id: 43),
    in: presentation.id
)

navigation.navigateBack(in: presentation.id)
navigation.returnToRoot(in: presentation.id)
navigation.replacePath(with: [.article(id: 44)], in: presentation.id)

let path = navigation[presentation: presentation.id]
```

Missing presentation IDs are safely ignored, and reading one returns an empty
path.

### Build and dismiss a modal stack

Presenting again while a modal is active adds a native child presentation:

```swift
navigation.present(.article(id: 42), as: .sheet)
navigation.present(.settings, as: .sheet)
navigation.present(.article(id: 43), as: .fullScreen)
```

Dismiss from the top, remove a number of layers, clear the stack, or dismiss a
specific occurrence and everything presented above it:

```swift
navigation.dismissPresentation()
navigation.dismissPresentations(count: 2)
navigation.dismissAllPresentations()
navigation.dismissPresentation(id: presentation.id)
```

This cascading behavior matches native ownership: a child presentation cannot
outlive the presentation that owns it. Interactive sheet dismissal and the
tvOS remote's native dismissal behavior update the same controller state.

An optional callback runs exactly once when its occurrence leaves the stack:

```swift
navigation.present(.settings) {
    // The Settings occurrence was dismissed.
}
```

Callbacks for cascading dismissal run from the top presentation downward.
The read-only `navigation.presentations` array is available when custom UI
needs to inspect the active occurrences, styles, or paths.

### Configure modal behavior

```swift
let navigation = NavigationController(
    roots: roots,
    configuration: NavigationConfiguration(
        defaultPresentationStyle: .sheet,
        maximumPresentationDepth: 8
    )
)
```

The configuration remains editable:

```swift
navigation.configuration.defaultPresentationStyle = .fullScreen
navigation.configuration.maximumPresentationDepth = 4
```

Changes affect future operations and do not rewrite existing paths or
presentations. A maximum depth of zero disables new presentations. Lowering the
limit below the current stack depth keeps the existing stack but prevents new
layers until enough have been dismissed.

The depth limit bounds recursive presentation flows while still allowing apps
to choose a limit appropriate for their design.

### Presentation styles by platform

- `.sheet` uses a native sheet on every supported platform.
- `.fullScreen` uses a native full-screen cover on iOS and tvOS.
- macOS and visionOS map `.fullScreen` to a native sheet because SwiftUI does
  not provide the same full-screen-cover API there.

## Platform-specific root placement

Placement belongs to `NavigationRoot`, not `Navigable`. The same destination
therefore remains usable as a root, route, or modal regardless of how each
platform displays its configured root.

```swift
NavigationRoot(
    destination: Page.settings,
    surfacePolicy: NavigationSurfacePolicy(
        compact: [],
        regular: .sidebar,
        television: .sidebar,
        desktop: .sidebar,
        spatial: .sidebar
    )
)
```

The semantic contexts are `.compact`, `.regular`, `.television`, `.desktop`,
and `.spatial`. Each context accepts `.tabBar`, `.sidebar`, `.all`, or an empty
set. A single placement can be used everywhere:

```swift
NavigationRoot(
    destination: Page.library,
    surfacePolicy: NavigationSurfacePolicy(.sidebar)
)
```

An empty set asks native navigation chrome to hide the root. The root remains
configured, retains its path, and can still be selected programmatically.

Native visibility controls differ by platform and OS version. The legacy view
keeps every root in its `TabView`, and some modern platforms cannot express
every tab/sidebar combination. NavigationKit applies a deterministic native
best effort without changing root membership, selection semantics, or paths.

### Search roots

Add the search role when configuring a root:

```swift
NavigationRoot(
    destination: Page.search,
    role: .search
)
```

The modern view maps this to SwiftUI's native search tab role. The legacy view
keeps the root and its state but has no equivalent role API.

## Custom navigation views

Apps do not have to call `makeView()`. A custom navigation view can render the
selected root and use the same controller for selection and commands:

```swift
struct CustomNavigationView: View {
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
                            icon: { root.destination.icon }
                        )
                    }
                }
            }
        }
        .navigationPresentations(for: navigation)
    }
}
```

Custom navigation views decide their own layout, styling, root visibility, and
focus behavior. Apply `.navigationPresentations(for:)` exactly once around a
custom view so it can display the controller's modal stack. `makeView()` applies
it automatically.

## tvOS

NavigationKit treats tvOS as a primary platform:

- tvOS 18 uses the modern native tab/sidebar view.
- tvOS 17 uses the native `TabView` fallback.
- Every root and modal occurrence retains its own `NavigationStack` path.
- Stack navigation and modal dismissal remain native to the remote.
- Custom chrome can use normal focusable `Button` and `NavigationLink` views.
- Focus state stays in the app's views instead of entering shared navigation
  state.

## Using a larger app model

`NavigationController` is concrete so it can enforce its navigation invariants.
Compose it into a larger observable model when the app has unrelated state:

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

## Example application

Open `Example App/Example App.xcodeproj`. The example can switch at runtime
between NavigationKit's native view and custom navigation chrome backed by the
same controller. It demonstrates:

- Roots that retain independent paths.
- A destination used as both a root and a route.
- Every root navigation command.
- Platform-specific root placement and a search root.
- Nested sheets and full-screen presentations.
- Repeated occurrences of the same modal destination.
- Independent paths and navigation commands inside presentations.
- Cascading dismissal and runtime-editable controller configuration.
- A destination modifier that derives every navigation title from `titleKey`.
- A focusable custom root bar on tvOS.
- iOS, iPadOS, macOS, tvOS, and visionOS from one example target.

## Current scope

NavigationKit 0.2 focuses on a homogeneous typed destination path, a fixed root
catalog, native adaptive views, app-defined navigation chrome, independent root
paths, and bounded modal stacks with independent presentation paths.

The current API does not yet include `TabSection` support, dynamic root
insertion and removal, deep-link parsing, Codable restoration helpers, or
persisted tab customization.

## Development

Run the package tests with:

```sh
swift test
```

The test suite covers root and presentation navigation, path reuse, independent
paths, fixed-catalog validation, surface policies, bounded and repeated modal
occurrences, cascading dismissal, callbacks, and reentrant presentation.
