# Roots and platform placement

A `NavigationRoot` makes a destination a top-level entry. Root configuration
does not change what the destination is: the same value remains available as a
route or modal.

## Fixed root catalog

Create the complete catalog with the controller:

```swift
let navigation = NavigationController(
    roots: [
        NavigationRoot(destination: Page.home),
        NavigationRoot(destination: Page.library),
        NavigationRoot(destination: Page.settings),
    ],
    selectedRoot: .home
)
```

The catalog is immutable for the controller's lifetime. Each root object has
stable reference identity and owns its own typed path. Controller-driven root
changes preserve those paths:

```swift
let library = NavigationRoot(
    destination: Page.library,
    path: [.article(id: 42)]
)
```

Native containers remain free to apply their platform behavior during direct
user interaction. Stable root identity does not replace native view-local
state, scroll state, or focus state with package-owned state.

## Platform-specific placement

Placement belongs to a configured root, not to `Navigable`. Use
`NavigationSurfacePolicy` to describe where a root should be discoverable:

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

The semantic contexts are:

| Context | Intended environment |
| --- | --- |
| `.compact` | A narrow mobile presentation, commonly iPhone |
| `.regular` | A regular mobile presentation, commonly iPad |
| `.television` | tvOS |
| `.desktop` | macOS |
| `.spatial` | visionOS |

Each context accepts `.tabBar`, `.sidebar`, `.all`, or an empty set. Use one
placement everywhere when no adaptation is needed:

```swift
NavigationRoot(
    destination: Page.library,
    surfacePolicy: NavigationSurfacePolicy(.sidebar)
)
```

An empty surface set requests that the native navigation view hide the root.
The root remains configured, retains its path, and can still be selected
programmatically.

Native visibility controls differ by platform and OS version. The legacy view
keeps every root in its `TabView`, and some modern platforms cannot express
every tab/sidebar combination. NavigationKit applies a deterministic native
best effort without changing root membership or command semantics.

## Search roots

Give a root the search role when it should use native search-tab treatment:

```swift
NavigationRoot(
    destination: Page.search,
    role: .search
)
```

The modern navigation view maps this to the platform's native search role.
Older fallback APIs retain the root and its state without special styling.

## tvOS

tvOS is a first-class target:

- tvOS 18 uses the modern native tab/sidebar APIs.
- tvOS 17 uses the native `TabView` fallback.
- Roots and modal occurrences own independent `NavigationStack` paths.
- Remote back and native modal dismissal update the controller state.
- Custom navigation views can use ordinary focusable `Button` and
  `NavigationLink` views.

NavigationKit does not mirror focus into shared navigation state or intercept
the focus engine. Platform-specific focus behavior remains in the app's views.
