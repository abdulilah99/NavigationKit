# Modal presentations

Modal stacks are part of `NavigationController` and use the same destination
type as roots and routes. A second modal enum or controller is not required.

## Present a destination

```swift
navigation.present(.settings)
navigation.present(.article(id: 42), as: .sheet)
navigation.present(.article(id: 73), as: .fullScreen)
navigation.present(
    .library,
    path: [.article(id: 42)]
)
```

Omitting `as:` uses `configuration.defaultPresentationStyle`. Every accepted
call creates a new `NavigationPresentation` occurrence with a stable UUID, so
the same destination can be presented repeatedly without an identity collision.

`present` returns the occurrence, or `nil` when the configured stack limit has
been reached:

```swift
guard let presentation = navigation.present(.article(id: 42)) else {
    return
}
```

Use `navigation.hasPresentationCapacity` when custom UI needs to reflect the
same capacity check.

## Configure the stack

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

Changes affect future operations; they do not rewrite existing paths or modal
occurrences. A maximum depth of zero disables new presentations. Lowering the
limit below the current depth retains the stack and rejects new layers until
enough presentations have been dismissed.

This limit bounds accidental or recursive presentation flows while letting the
app choose an appropriate depth.

## Navigate inside a presentation

Every occurrence owns an independent typed path. Address it with the ID
returned from `present`:

```swift
navigation.navigate(
    to: .article(id: 43),
    in: presentation.id
)

navigation.navigateBack(in: presentation.id)
navigation.returnToRoot(in: presentation.id)
navigation.replacePath(
    with: [.article(id: 44)],
    in: presentation.id
)

let path = navigation[presentation: presentation.id]
```

These commands use the same navigation semantics as root commands. Missing
presentation IDs are ignored, and reading one returns an empty path.

## Nested presentation and dismissal

Calling `present` while a modal is active appends a native child presentation:

```swift
navigation.present(.article(id: 42), as: .sheet)
navigation.present(.settings, as: .sheet)
navigation.present(.article(id: 43), as: .fullScreen)
```

Dismiss the top occurrence, several top layers, the complete stack, or one
occurrence and everything it presented:

```swift
navigation.dismissPresentation()
navigation.dismissPresentations(count: 2)
navigation.dismissAllPresentations()
navigation.dismissPresentation(id: presentation.id)
```

Cascading dismissal matches native ownership: a parent modal cannot disappear
while keeping its child modal alive. Interactive sheet dismissal and native
tvOS dismissal update the same controller stack.

An optional callback runs exactly once when its occurrence leaves the stack:

```swift
navigation.present(.settings) {
    // This Settings occurrence was dismissed.
}
```

Callbacks for a cascading dismissal run from top to bottom. The read-only
`navigation.presentations` array is available to custom views that need to
inspect occurrence IDs, destinations, styles, or paths.

## Platform styles

- `.sheet` uses the platform's native sheet.
- `.fullScreen` uses a native full-screen cover on iOS and tvOS.
- macOS and visionOS map `.fullScreen` to a native sheet because SwiftUI does
  not provide the same full-screen-cover API there.

`makeView()` installs presentation rendering automatically. Custom navigation
views must apply `.navigationPresentations(for:)` once around their content.

This modifier owns native modal presentation. Add `.navigationToasts(for:)`
after it to enable toast rendering on those surfaces independently; see
[Toasts](toasts.md). Toasts are optional and use their own controller.

The presenting layout direction is explicitly forwarded to each native modal,
including nested sheets, covers, and toast overlays. For an app-level language
override, apply `.environment(\.layoutDirection, ...)` outside `makeView()` or
`.navigationPresentations(for:)` so the presentation host receives it. An override
inside a destination's content only affects that destination's subtree.
