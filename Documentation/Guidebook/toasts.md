# Toasts

NavigationKit includes a typed toast engine with independent expiration and
collapsed notification decks. The newest toast is the front card. Two older
cards show scaled edges behind it by default, above top toasts and below bottom
toasts; additional occurrences remain in the controller and may become visible
as newer ones leave.

Top and bottom have separate decks. Each deck uses its front toast's horizontal
alignment. Only the front card is interactive. Swipe it left or right to dismiss
it on platforms supporting drag gestures, or use buttons in your custom content.
Tapping the card does not automatically dismiss it.

## Define your toast content

`Toastable` is independent of `Navigable`. It does not require `Hashable` or
`Identifiable`: each displayed occurrence gets its own stable UUID.

```swift
enum AppToast: Toastable {
    case error(title: LocalizedStringResource, message: LocalizedStringResource)
    case saved

    var expiration: ToastExpiration {
        switch self {
        case .error: .after(.seconds(8))
        case .saved: .after(.seconds(3))
        }
    }

    var edge: VerticalEdge {
        switch self {
        case .error: .top
        case .saved: .bottom
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .error(let title, let message):
            ErrorToastView(title: title, message: message)
        case .saved:
            SavedToastView()
        }
    }
}
```

Only `content` is required. Defaults are `.after(.seconds(4))`, `.bottom`,
`.center`, and a slide/fade transition from the resolved edge. Override
`alignment` with `.leading` or `.trailing`, or return a custom `AnyTransition?`
from `transition`. Returning `nil` uses the default transition. Reduce Motion
uses a short fade instead of the configured movement.

Content owns its typography, colors, shape, materials, progress, and controls.
Prefer content that sizes naturally and fits the available surface. Rear cards
are constrained to the front card's size and aligned toward the exposed edge.
The card bounds clip overflowing drawing. Hidden cards are not rendered; keep
state that must survive hiding in the toast's data or an app-owned model.

## Own and install the engine

Own `ToastController<AppToast>` alongside your navigation controller. It is an
observable main-actor object, so a view can own it in `@State` and descendants
can read it through SwiftUI's type-based environment:

```swift
@State private var toasts = ToastController<AppToast>()

// At the navigation boundary:
navigation.makeView(toasts: toasts)
    .environment(toasts)

// In descendant views:
@Environment(ToastController<AppToast>.self) private var toasts
```

For custom navigation, use the equivalent presentation modifier once:

```swift
CustomNavigationView(navigation: navigation)
    .navigationPresentations(for: navigation, toasts: toasts)
    .environment(toasts)
```

The root host sits outside the navigation stacks. By default, top toasts sit at
the container's safe top edge and may overlap the navigation bar; bottom toasts
clear the active destination's tab bar or bottom toolbar. This keeps top banners
stable as navigation titles expand or collapse. Custom navigation built from
`root.content` reports the same bounds, so a custom root bar outside that content
remains clear too. The placement policy is configurable below.
Native sheets and full-screen covers receive the same overlay, and the parent host is hidden
while its presented child is visible. Toast identity and deadlines persist
through that handoff. Toast placement inside a sheet is relative to the sheet.

For another SwiftUI surface, including an app-owned sheet, install:

```swift
content.toastPresentations(for: toasts)
```

This modifier renders in the surface to which it is attached; it does not create
a separate window or automatically modify unrelated sheets, popovers, or system
alerts. Do not also install it on navigation that already uses the integrated
toast overload. When manually installing multiple hosts, the app controls which
hosts are visible.

For independent windows, create a controller in each window's root view. Sharing
one controller deliberately shares its toast state among those windows.

## Present from a binding

For a toast owned by one screen, use the SwiftUI-style `.toast` modifiers. They
create their own local controller; no controller setup or environment injection
is needed. Their container is the view you attach them to. Attaching inside
native navigation/tab containers inherits the screen's content safe area:

```swift
@State private var showsSaved = false

NavigationStack {
    Form {
        Button("Save") { showsSaved = true }
    }
    .toast(isPresented: $showsSaved, expiration: .after(.seconds(3))) {
        HStack {
            Text("Saved")
            Button("Close") { showsSaved = false }
        }
        .padding()
        .background(.regularMaterial, in: Capsule())
    }
}
```

The custom-content form also accepts `edge`, `alignment`, `configuration`, and
`onDismiss`. Its content updates with the presenting view's state. Expiration
and placement are resolved when the binding becomes true.

A local modifier cannot extend beyond its attached container to cover a native
navigation bar. Use the integrated navigation host for banners that span the
navigation surface and follow its modal presentations.

An enum can supply its own view and defaults:

```swift
// Add Equatable to the app's Toastable enum for binding change detection.
@State private var toast: AppToast?

content
    .toast(item: $toast, onDismiss: { /* presentation ended */ })

// Present:
toast = .saved
```

To control that same enum with a Boolean instead of an optional value, use:

```swift
@State private var showsSaved = false

content.toast(isPresented: $showsSaved, toast: AppToast.saved)
```

This form uses the enum's content, expiration, placement, and transition, and
also accepts `configuration` and `onDismiss`. Dismissal or expiry sets
`showsSaved` back to `false`.

Both enum forms require `Toastable & Equatable`, without an `Identifiable`
requirement. Changing the enum value while presented updates the occurrence's
content while preserving its deadline and placement. Clear the optional binding
or set the Boolean to `false` before starting a new occurrence with different
defaults. Enum content receives the local typed
controller and occurrence in the environment, just like controller-hosted toasts.

Swipe dismissal or expiration resets the binding to `false`/`nil`. Clearing the
binding dismisses the occurrence. `onDismiss` runs once after logical dismissal,
including when the presenting view disappears; it does not wait for the exit
animation. Invalid initial expiration clears the binding without calling
`onDismiss`, since no toast was presented.

Each modifier owns one local occurrence. Use the controller API for a shared
stack of simultaneous occurrences that survives navigation and follows native
modal presentations. Local modifiers render on their attached surface and do
not automatically move into unrelated sheets.

## Show, update, and dismiss

```swift
let occurrence = toasts.show(
    .error(title: "Upload failed", message: "Try again."),
    expiration: .after(.seconds(10)),
    edge: .top,
    alignment: .trailing
)

if let occurrence {
    toasts.update(
        id: occurrence.id,
        with: .saved,
        expiration: .after(.seconds(3))
    )

    toasts.dismiss(id: occurrence.id)
}

toasts.dismissAll()
```

Every accepted `show` creates a new occurrence, even for identical enum values.
It returns `nil` for a nonpositive duration or an invalid/already elapsed date.

`update` preserves identity, placement, and expiration unless you explicitly
override them. It does not implicitly read the replacement enum case's defaults.
For a loading-to-success update, explicitly supply the success duration.
An already elapsed expiration override removes the occurrence. Missing IDs are
ignored, including delayed updates after a toast has expired or been dismissed.

The read-only `presentations` array contains all active occurrences, oldest
first, including those hidden behind the three visible cards. There is no
implicit queue delay, duplicate suppression, or removal of the fourth card.

## Expiration

| Policy | Behavior |
| --- | --- |
| `.after(.seconds(4))` | Starts when `show` accepts the toast; elapsed time continues in the background and during system sleep. |
| `.at(date)` | Expires at a fixed wall-clock date and responds to system clock changes. |
| `.never` | Remains until explicitly dismissed or given another expiration. |

The controller resolves defaults once. Re-rendering, navigating, changing the
front card, and presenting a sheet do not restart a toast's lifetime. Hidden
occurrences expire on the same schedule as visible ones. Returning to an active
scene removes expired occurrences. A custom renderer can call
`removeExpiredToasts()` to perform the same reconciliation.

`expiresAt` exposes the date resolved when the expiration was last set. For
relative durations this is an estimate of wall-clock time at that moment;
scheduling uses `ContinuousClock`, so changing the system clock does not change
the elapsed duration. Persistent occurrences have no expiration date.

Persistent occurrences remain retained even while hidden. Use explicit
dismissal when their associated app operation finishes.

## Buttons and dismissal callbacks

Each rendered toast receives both its controller and occurrence in the typed
environment. A custom close button can dismiss exactly its own occurrence:

```swift
struct ToastCloseButton: View {
    @Environment(ToastController<AppToast>.self) private var toasts
    @Environment(ToastPresentation<AppToast>.self) private var occurrence

    var body: some View {
        Button("Dismiss") {
            toasts.dismiss(id: occurrence.id)
        }
    }
}
```

Use ordinary buttons for Retry, Undo, or navigation actions. The engine does not
intercept a normal tap to dismiss the card. Toast content retains the host's
environment, and the toast's controller is explicitly available within it.

An optional callback receives `.dismissed` or `.expired` exactly once when an
occurrence leaves the model. This is logical removal, not exit-animation
completion. The callback can show or dismiss other toasts safely:

```swift
toasts.show(.saved) { reason in
    // Observe this occurrence's removal.
}
```

On tvOS, provide focusable buttons in your content or dismiss programmatically.
SwiftUI's drag gesture is unavailable there. NavigationKit does not install
remote direction/back handlers or automatically transfer focus to a toast.

## Configure the decks

```swift
let style = ToastStackConfiguration(
    maximumVisibleToasts: 3,
    maximumWidth: 460,
    stackSpacing: 10,
    scaleStep: 0.06,
    insets: EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20),
    animation: .spring(duration: 0.35),
    swipeToDismiss: true,
    swipeThreshold: 70,
    placement: .automatic
)

navigation.makeView(toasts: toasts, toastConfiguration: style)
```

The same configuration is accepted by the custom-navigation overload,
`.toastPresentations(for:configuration:)`, and all `.toast` binding modifiers.
Maximum visible count changes rendering only; it does not discard hidden occurrences.

| Placement | Top deck | Bottom deck |
| --- | --- | --- |
| `.automatic` (default) | Container's safe top edge; may overlap navigation chrome. | Active content's bottom edge, above tab bars and bottom toolbars. |
| `.container` | Container's safe top edge. | Container's safe bottom edge; may overlap navigation chrome. |
| `.content` | Below the active content's top chrome. | Above the active content's bottom chrome. |

Automatic and content placement also use the active content's horizontal bounds,
keeping decks out of sidebars. When no NavigationKit content bounds are available,
both fall back to the attached container. The container is the hosting view or
sheet, not the entire display. Every mode retains that host's safe area and
inherits its native keyboard avoidance; none ignores the safe area. Insets add
spacing inside the selected region, including room for the exposed rear cards.
Changing the configuration repositions existing toasts without restarting them.
