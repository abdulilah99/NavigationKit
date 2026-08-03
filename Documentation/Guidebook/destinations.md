# Destinations

`Navigable` is the single destination contract used throughout NavigationKit.
It combines stable identity, standard label metadata, view construction, and
an optional shared modifier.

## Identity

`Navigable` inherits `Identifiable` and `Hashable`. Identity should represent
the location itself and remain stable while SwiftUI displays it:

```swift
enum Page: Navigable {
    case article(id: Int)

    var id: Self { self }

    // titleKey, icon, and content...
}
```

With this model, `.article(id: 42)` and `.article(id: 73)` are different
destinations. Avoid generating a new UUID whenever `id` is read; unstable IDs
break path and view identity.

## Localizable title and icon

Every destination provides `titleKey` and `icon`:

```swift
var titleKey: LocalizedStringKey {
    switch self {
    case .article(let id): "Article \(id)"
    }
}

var icon: Image {
    Image(systemName: "doc.text")
}
```

`titleKey` deliberately uses `LocalizedStringKey`, allowing SwiftUI to resolve
the value through the app's localization resources. These values form the
standard label for native roots and NavigationKit's link convenience.

## Destination content

The `content` property builds the view associated with the value:

```swift
@ViewBuilder
var content: some View {
    switch self {
    case .home:
        HomeView()
    case .article(let id):
        ArticleView(id: id)
    }
}
```

Keep substantial screens in their own `View` types. The destination switch
should select and initialize views rather than contain the screen layout.

## Shared destination behavior

`modifier` is applied whenever NavigationKit renders a destination as a root,
route, sheet, or full-screen presentation. Its default is `EmptyModifier`, so
it only needs to be implemented when the destination has shared behavior.

For example, attach navigation titles in one place:

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

The modifier is also an appropriate place for destination-wide toolbars,
environment dependencies, accessibility metadata, and lifecycle behavior.

Custom navigation views receive the same behavior when they render
`NavigationRoot.content`. Presentation destinations receive it when the custom
view installs `.navigationPresentations(for:)`.

## Typed navigation links

NavigationKit provides a label convenience for SwiftUI's value-based link:

```swift
NavigationLink(value: Page.article(id: 42))
```

The label uses the value's `titleKey` and `icon`. NavigationKit's root and
presentation stacks register the matching typed destination automatically.

A configured root can also be used as an ordinary route value. For example,
`NavigationLink(value: Page.library)` displays Library inside the current path;
it does not select the Library root. Root selection is an explicit controller
operation.
