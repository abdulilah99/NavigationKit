# Migrating from 0.1.x to 1.0

NavigationKit 1.0 is a deliberate breaking redesign. It replaces the protocol-
based controller, separate tab and sheet models, custom navigation chrome, and
erased environment values with one concrete typed navigation model. There are
no compatibility aliases or deprecated shims.

## Symbol map

| 0.1.x | 1.0 |
| --- | --- |
| `NavigationController` protocol | `NavigationController<Destination>` concrete observable class |
| `NavigationTab<Page>` | `NavigationRoot<Destination>` |
| `selectedTab` | `selectedRoot` |
| `tabs` | fixed `roots` passed to the controller initializer |
| `select(tab:)` | `select(root:)` |
| `navigate(to:on:)` with `tab:` semantics | `navigate(to:on:)` with root semantics |
| writable `controller[tab]` | read-only `controller[root]` plus `replacePath(with:on:)` |
| `Navigable.image` | `Navigable.icon` |
| `Navigable.destination` | `Navigable.content` |
| `Navigable.placement` / `BarPlacement` | `NavigationRoot.surfacePolicy` / `NavigationSurfacePolicy` |
| `Navigable.role: TabRole?` | `NavigationRoot.role: NavigationRootRole?` |
| `Sheet` and the controller's `Card` type | the same `Navigable` destination type |
| `present(sheet:)` and mutable `sheets` | `present(_:as:path:onDismiss:)` and read-only `presentations` |
| `NavigationView(controller:)` | `navigation.makeView()` |
| `useCustomNavigationView` | app-owned custom navigation view |
| custom navigation environment entries | `.environment(navigation)` and type-based `@Environment` |

## Replace the controller conformance

In 0.1.x, an application defined a controller type that conformed to the
library protocol and owned tabs and sheets. In 1.0, create the library's
concrete controller directly:

```swift
@MainActor
func makeNavigationController() -> NavigationController<Page> {
    NavigationController(
        roots: [
            NavigationRoot(destination: .home),
            NavigationRoot(destination: .library),
        ],
        selectedRoot: .home,
        configuration: NavigationConfiguration(
            defaultPresentationStyle: .sheet,
            maximumPresentationDepth: 8
        )
    )
}
```

Compose this controller into a larger app model when other state belongs beside
navigation. Do not recreate the old protocol solely to wrap it.

## Update `Navigable`

Rename the view and image properties, then move root-only placement and role
metadata to `NavigationRoot`:

```swift
enum Page: Navigable {
    var id: Self { self }
    var titleKey: LocalizedStringKey { /* ... */ }
    var icon: Image { /* previously image */ }

    @ViewBuilder
    var content: some View { /* previously destination */ }
}
```

`Navigable` still supports a destination-wide `modifier`, now with
`EmptyModifier` as its default associated type. NavigationKit applies it in
every placement.

## Configure roots instead of tabs

Replace `NavigationTab(page:path:)` with `NavigationRoot(destination:path:)`:

```swift
NavigationRoot(
    destination: Page.library,
    path: [.article(id: 42)],
    surfacePolicy: NavigationSurfacePolicy(
        compact: .tabBar,
        regular: .sidebar,
        television: .sidebar,
        desktop: .sidebar,
        spatial: .sidebar
    )
)
```

The root catalog can no longer grow implicitly during navigation. Commands for
an unconfigured root are safe no-ops. This makes root membership and retained
path ownership explicit.

## Use one type for routes and modals

Remove the old `Sheet` enum or protocol conformance and add its cases to the
same destination type when they represent navigable locations:

```swift
navigation.present(.filters)
navigation.present(.player(id: 42), as: .fullScreen)
```

Presentation style, occurrence identity, nested paths, depth limits, and
dismissal now belong to `NavigationPresentation` and
`NavigationConfiguration`, not to destination identity.

## Replace environment values

Remove uses of the 0.1.x navigation path, selection, sidebar, and `Serotonin`
environment entries. Own and inject the concrete controller:

```swift
ContentView()
    .environment(navigation)
```

Then read it by type:

```swift
@Environment(NavigationController<Page>.self) private var navigation
```

Use controller commands instead of erased path or selection actions.

## Choose native or custom rendering

For NavigationKit's adaptive native interface:

```swift
navigation.makeView()
```

For app-defined navigation views, read `navigation.roots`, render the selected
root's `content`, call controller commands, and apply
`.navigationPresentations(for: navigation)` once. The package no longer ships
the old hand-built custom sidebar and tab bar.
