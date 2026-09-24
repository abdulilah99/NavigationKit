# Toast engine design and research

Research and repository review: 22 September 2026.
Initial baseline: `0a957d5`.
Release: NavigationKit 1.1.0, 24 September 2026.
See [the toast guide](Guidebook/toasts.md) for the current public API.

## Repository baseline

The review covers the package sources, package tests, example application,
existing UI tests, project configuration, README, changelog, and guidebook.

| Area | Contract before toast support | Implication for toasts |
| --- | --- | --- |
| `Navigable` | One typed destination supplies identity, label metadata, content, and an optional modifier. | Use a separate toast protocol with app-owned content and defaults. Navigation labels and path equality are unnecessary toast requirements. |
| `NavigationController` | Concrete `@Observable`, `@MainActor` owner of roots, paths, and modal occurrences. | Give scheduling and toast mutations one explicit owner with the same concurrency model. |
| Roots and routes | Root paths are independent; native containers own UI behavior. | Toasts should survive root selection and path changes without joining navigation history. |
| Modal state | Each presentation gets a UUID, even when its destination repeats. Dismissal is occurrence-based and callbacks allow reentrancy. | Use independent toast occurrence IDs; identical content must not accidentally share a timer. |
| Standard view | `makeView()` composes adaptive navigation and `.navigationPresentations(for:)`. | This is one integration point, but there is no existing global toast overlay. |
| Native presentations | `NavigationPresentationModifier` and `NavigationPresentationView` recursively present native sheets/covers. Child presentation waits for `onAppear`. | A root overlay alone cannot provide the required frontmost modal behavior. Host placement must participate in this recursion. |
| Custom navigation | Apps render controller state and install the presentation modifier themselves. | Toast support needs equivalent integration here, using the same state and renderer. |
| Platforms | iOS/tvOS 17, macOS 14, visionOS 1; Swift 6. Modern navigation starts one OS generation later. | Preserve all deployment targets. Toast support must not depend on newer tab APIs or assume UIKit everywhere. |
| Example | One app target covers all supported platforms, switches between native/custom navigation, and uses the local package. | Extend this example to exercise both integrations and nested modals. |
| Verification | 37 Swift Testing tests and three existing iOS UI test methods. | Add focused lifecycle tests and real hosting checks; controller tests alone cannot establish modal visibility or touch behavior. |

Baseline: `swift test --scratch-path /tmp/navigationkit-toast-build` passed all
37 tests with Xcode 27.0 before implementation.

## Prior work and useful lessons

These are representative primary sources, not an exhaustive inventory of every
toast implementation. The recommendations below are our design conclusions.

| Source | Relevant behavior | Lesson for NavigationKit |
| --- | --- | --- |
| [AlertToast](https://github.com/elai950/AlertToast) | Binding-driven presentation, preset visuals, duration and tap dismissal. | Convenient for individual notifications; our typed content and simultaneous occurrence stack need a different state model. |
| [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages) | Arbitrary views, configurable presentation, queued messages, identity-based duplicate removal and dismissal. | Separate identity, ordering, and rendering. Its default sequential queue is different from simultaneous stacking. |
| [SwiftEntryKit](https://github.com/huri000/SwiftEntryKit) | Window presentation, priority/queue/override policies, lifetime, keyboard relationships, interaction and lifecycle hooks. | Overflow and interaction timing must be intentional. Avoid introducing the full policy surface without a concrete use case. |
| [PopupView](https://github.com/exyte/PopupView) | Custom SwiftUI content; overlay, sheet, and window modes; positions, animations, keyboard options, and gestures. | Hosting strategy materially changes behavior. Its key-window option explicitly addresses focus and keyboard disruption. |
| [swiftui-toasts](https://github.com/sunghyun-k/swiftui-toasts) | Root installation, environment presentation, action content, and asynchronous loading/result updates. | One installation point and updating an existing toast are useful app-facing patterns. |
| [Sonner](https://sonner.emilkowal.ski/) | Stacked/expanded presentation, visible-count control, positions, and custom content. | Distinguish fully visible stacks from overlapping decks; the latter needs expansion, overflow, and input design. |
| [react-hot-toast](https://react-hot-toast.com/docs/toast) | Per-toast durations, persistent loading, occurrence IDs, updates, explicit duplicate IDs, and custom content. | Return a stable occurrence handle and support updating it, such as loading to success. |

Platform references:

- Apple's [ContinuousClock](https://developer.apple.com/documentation/swift/continuousclock)
  advances while the system sleeps. This supports elapsed-duration deadlines;
  it is not a wall-clock `Date`, and system sleep is different from app inactivity.
- Apple's [UIWindowScene](https://developer.apple.com/documentation/uikit/uiwindowscene)
  owns the windows for one instance of an app's UI. Any separate-window approach
  needs explicit scene association, not a process-wide search for an arbitrary
  active window.
- Apple's [accessibility announcements](https://developer.apple.com/documentation/accessibility/accessibilitynotification/announcement)
  provide a way to announce transient feedback, including speech priorities.
- Apple's [Reduce Motion environment value](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion)
  should inform toast movement and stack transitions.
- Apple's [anchor preferences](https://developer.apple.com/documentation/swiftui/view/anchorpreference(key:value:transform:))
  let the host resolve a descendant's safe content bounds without maintaining
  separate geometry state or assuming fixed bar heights.
- Apple's [binding-driven presentation modifiers](https://developer.apple.com/documentation/swiftui/view-presentation)
  establish the familiar binding reset and dismissal callback pattern used by
  the standalone toast modifiers.

## Selected behavior

- The app defines a `Toastable` enum with content, default expiration, edge,
  alignment, swipe permission, and an optional transition.
- The implementation uses a separate `ToastController<Toast>` alongside the
  navigation controller, preserving the existing navigation generic and API.
- Each show call creates an independent occurrence. Update/dismiss use its ID.
- Expiration supports relative duration, fixed date, and persistence. Durations
  keep counting in the background, including for hidden occurrences.
- Top and bottom have separate collapsed decks. The newest card is in front;
  the next two show scaled edges. The fourth and older entries remain in the
  controller and can be revealed later if they have not expired.
- The front card's alignment places the whole deck. Swiping left or right removes
  the front card when its current `Toastable.swipeToDismiss` permits it. Normal
  buttons remain usable; there is no automatic tap dismissal.
- Hosting uses SwiftUI modifiers outside the main navigation UI and inside the
  recursive sheet/cover hierarchy, as requested. It does not create a new window.
- Automatic placement keeps top banners at the container's safe top and bottom
  banners above the active content's bottom chrome. A single configuration choice
  can instead use container edges or content bounds for both decks.
- View-owned presentation supports both Boolean/custom-content and optional-enum
  bindings. Dismissal and expiry reset the binding; enum updates preserve the
  occurrence's deadline and placement.

## Ownership and integration

`ToastController` owns observable occurrences, commands, callbacks, and one
cancellable task waiting for the next deadline. It does not retain itself across
that wait. A clock-change notification reconciles fixed-date deadlines; the host
also reconciles on scene activation. Monotonic duration deadlines are resolved
once, independently of the estimated `expiresAt` date exposed to callers.

`ToastPresentation` owns stable occurrence identity and mutable content/metadata.
Content updates preserve placement and deadlines unless an override is explicit.
Removal detaches callbacks before invoking them, permitting reentrant commands.

`ToastOverlay`, `ToastStackView`, and `ToastCardView` render the two decks and
handle front-card interactions. A small `Layout` measures the newest card and
proposes its size to older cards, exposing a fixed strip rather than allowing a
taller rear card to spill out. No geometry observation loop is needed.

Navigation and toast hosting compose through separate modifiers. `makeView()`
installs only navigation presentation; custom navigation applies
`.navigationPresentations(for:)` itself. An outer `.navigationToasts(for:)`
installs a toast renderer into the environment. The renderer is a concrete value
holding the toast controller and configuration, with a regular rendering method;
the environment contains no rendering closures or extra mutable coordinator.

Each navigation surface reads the optional internal `NavigationSurfaceOverlay`
contract. Navigation owns native presentation and visibility, and has no toast
controller, configuration, or toast generic parameter. Without a renderer, it
does not construct an overlay geometry reader. SwiftUI passes the renderer to
native child presentations. `AnyView` is confined to the overlay integration;
the navigation content keeps its concrete type. The shared surface helper resolves
geometry, and `ToastOverlay` applies the toast-specific placement policy.

Visibility follows actual child appearance/disappearance, rather than
assuming the requested modal-array count proves that a native child is onscreen.
The covered parent's overlay is removed, preserving engine state and deadlines.
Custom navigation has the same integration via the two separate modifiers.

The revised 1.1.0 tag removes the original combined navigation/toast overloads.
Standalone `ToastPresentationModifier` uses the same geometry helper and typed
toast renderer directly, independently of the navigation environment integration.

The active destination reports its already-inset bounds with an anchor preference.
The host resolves that anchor in its own coordinate space without reading bar
heights or applying safe-area insets a second time. Inactive roots do not report
bounds, and each modal host consumes its own preference before it reaches a parent.
Navigation without a renderer preserves the preference so a standalone outer
toast host can still resolve the active content bounds. Only installed overlay
hosts consume that preference.
The selected region is constrained to the host's own bounds, retaining inherited
safe-area and keyboard layout. Automatic placement uses the content's horizontal
extent and bottom edge with the container's top edge. This avoids moving top
banners as navigation titles expand or collapse.

`ToastBindingState` connects one view-owned occurrence to its binding and dismissal
callback. The item modifier uses `Equatable` to observe enum changes; the Boolean
modifier renders its latest content closure so view-state changes remain visible.
Both reuse the controller's expiration and the deck's rendering/gestures. Their
scope is the attached screen; controller hosting provides shared navigation-wide
stacking and modal handoff.

The standalone `toastPresentations` modifier supports app-owned surfaces. Sheet
placement remains relative to the sheet's content area. Arbitrary system alerts
and unrelated native presentations are not automatically covered.

## Customization

The app's SwiftUI content owns colors, typography, shape, material, progress, and
buttons. `ToastStackConfiguration` owns the surface placement policy, visible count, maximum width, edge insets,
stack spacing and scale, animation, and swipe threshold. Per-show/update overrides
control individual occurrence placement and lifetime.

Swipe permission belongs to `Toastable` and defaults to true. It is read from the
current toast value rather than copied into occurrence metadata, so content
updates can enable or disable swiping without restarting expiration. The custom
Boolean binding modifier observes its lightweight toast value to propagate live
permission changes through the same controller update path. Drag handling checks
the current permission again before dismissing, including when it changes during
a gesture. The permission controls horizontal dragging; other dismissal paths
retain their existing behavior.

Reduced Motion substitutes a short fade. Rear cards disable input and hide their
accessibility content. tvOS retains native buttons/programmatic dismissal because
SwiftUI drag gestures are unavailable there; the engine adds no remote navigation
or focus interception.

## Release validation

The revised 1.1.0 snapshot passes:

- All 58 package tests, including independent deadlines, wall-clock changes,
  content and permission updates, callback reentrancy, hidden occurrences,
  binding synchronization, and controller lifetime.
- All 17 example UI tests in one iOS 26 simulator run. Coverage includes native
  navigation, independent navigation/toast hosting, standalone content bounds,
  native/custom sheets, nested full-screen presentations, deck promotion,
  keyboard clearance, safe-area placement, binding APIs, and live swipe permission.
- Example builds for macOS, tvOS, and visionOS. These platforms have build
  validation; their interactions have not been verified by the iOS UI suite.
- Local documentation links and Git whitespace checks.

Earlier engine validation also exercised iOS 18.6 and focused iOS 17.5 scenarios.
The final hosting and swipe refinements were verified on iOS 26; the package
retains its original minimum deployment targets.

Regression checks protect against empty-overlay input interception, double-counted
safe-area insets, and unsupported tvOS drag gestures. UI tests target the interactive
front card rather than decorative rear cards. The custom-content swipe test uses
leftward gestures to avoid native back navigation when toast swiping is disabled;
root-level enum tests cover both horizontal directions.
