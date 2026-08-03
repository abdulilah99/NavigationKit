# Custom navigation views

`makeView()` is optional. An app can render its own tab bar, sidebar, or other
navigation interface while using the same observable controller and commands.

## Render the selected root

Each `NavigationRoot` exposes `content`, which includes its typed
`NavigationStack` and applies the destination's shared modifier:

```swift
struct CustomNavigationView: View {
    let navigation: NavigationController<Page>

    var body: some View {
        VStack(spacing: 0) {
            if let root = navigation.roots.first(
                where: { $0.destination == navigation.selectedRoot }
            ) {
                root.content
            }

            CustomRootBar(navigation: navigation)
        }
        .navigationPresentations(for: navigation)
    }
}
```

Apply `.navigationPresentations(for:)` exactly once around a custom navigation
view so the controller's nested modal stack can be displayed. `makeView()`
already applies this modifier and does not need it again.

## Build custom root controls

The controller exposes stable, `Identifiable` root objects, so custom controls
can iterate without an explicit `id:` key path:

```swift
struct CustomRootBar: View {
    let navigation: NavigationController<Page>

    var body: some View {
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
}
```

Custom navigation views decide layout, styling, root discoverability, and
focus behavior. They may inspect each root's `surfacePolicy`, or apply a
different app-specific placement policy. Navigation semantics remain in the
controller.

On tvOS, use normal focusable SwiftUI controls and allow the focus engine and
remote to behave natively. Focus does not need to be copied into
`NavigationController`.

## Use the controller directly or through the environment

A custom view can receive the controller as an initializer argument, as above,
or read the same concrete type from the environment:

```swift
struct CustomNavigationView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        // Custom content and controls...
    }
}
```

Both approaches reference the same observable object. Choose based on the
app's dependency-injection style; no NavigationKit-specific environment layer
is required.

## Compose navigation into a larger model

`NavigationController` is concrete so it can enforce its state invariants.
When the app has unrelated state, compose the controller into a larger model:

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

The app model does not need to conform to a NavigationKit protocol. Views can
receive either `AppModel` or its `navigation` controller according to what
they actually use.
