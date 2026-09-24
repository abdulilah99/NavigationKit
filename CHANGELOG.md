# Changelog

All notable changes to NavigationKit are documented here.

## 1.1.1 — 2026-09-24

### Fixed

- Native sheets and full-screen covers explicitly preserve the presenting layout
  direction, including nested presentations and their toast overlays. This fixes
  app-level RTL overrides reverting to LTR at a native presentation boundary.

## 1.1.0 — 2026-09-24

Adds a typed toast engine and SwiftUI-style presentation APIs while preserving
the 1.0 navigation API and minimum platform versions.

### Added

- App-defined `Toastable` content with default expiration, top/bottom placement,
  semantic horizontal alignment, per-toast swipe permission, and optional transitions.
- Observable `ToastController` and independent toast occurrences, including
  explicit updates and dismissal, relative durations, fixed dates, and persistence.
- Collapsed notification decks showing three cards by default, horizontal swipe
  dismissal where supported, custom buttons, and configurable stack layout.
- Independent `.navigationToasts(for:configuration:)` hosting for native and custom
  navigation, including nested sheets and covers. Compose it after `makeView()` or
  `.navigationPresentations(for:)` to keep navigation and toast setup separate.
- Standalone `.toastPresentations(for:)` hosting and binding-based `.toast` modifiers
  that work without navigation-wide toast hosting.
- Toast examples, lifecycle tests, UI integration tests, and a guidebook chapter.
- SwiftUI-style `.toast(isPresented:content:)`, `.toast(isPresented:toast:)`, and
  `.toast(item:)` presentation, with binding synchronization on dismissal and expiry.
- Live `Toastable.swipeToDismiss` permission, defaulting to `true`, and the equivalent
  Boolean option for custom-content `.toast` presentation. Permission updates preserve
  occurrence identity and expiration; swipe threshold and animation are shared stack configuration.
- A toast placement choice: automatic (top at the container edge, bottom above
  navigation controls), container edges, or active content bounds.
- Toast hosts use the active destination's bounds to follow native and custom
  navigation chrome without hard-coded bar heights or double-counted safe areas.

### Revision of the original 1.1.0 tag

This revision replaces the initial 1.1.0 implementation. Existing 1.0 navigation
APIs remain unchanged. Code using the original 1.1.0 toast APIs needs these updates:

- Replace `makeView(toasts:toastConfiguration:)` and
  `.navigationPresentations(for:toasts:toastConfiguration:)` with the navigation-only
  call followed by `.navigationToasts(for:configuration:)`.
- Move `ToastStackConfiguration.swipeToDismiss` to `Toastable.swipeToDismiss` or the
  custom-content `.toast` modifier. The combined hosting overloads and stack-wide
  permission have been removed.

## 1.0.0 — 2026-08-03

The first stable NavigationKit release is a breaking redesign of the 0.1.x API.

### Added

- A concrete observable `NavigationController<Destination>` with validated,
  fixed roots and publicly read-only navigation state.
- Independent typed paths for every root and modal presentation occurrence.
- Destination-oriented selection, navigation, backward navigation, root
  return, and complete path-replacement commands.
- Native adaptive root views for iOS, iPadOS, macOS, tvOS, and visionOS, with
  native fallbacks at the declared minimum platform versions.
- Platform-specific root surface policies and a semantic search-root role.
- Nested native modal stacks, sheet and full-screen styles, stable occurrence
  identity, independent presentation paths, dismissal callbacks, and a
  configurable maximum depth.
- A destination-wide `Navigable.modifier` applied consistently to roots,
  routes, and modal presentations.
- Support for app-defined navigation views through public controller state,
  commands, root content, and `.navigationPresentations(for:)`.
- A multiplatform example app, package unit tests, and iOS native-integration
  UI tests.
- A focused GitHub guidebook and a 0.1.x migration guide.

### Changed

- Tabs, sidebar entries, routes, and modal destinations now share one
  `Navigable` destination model.
- `NavigationController` is a concrete generic class instead of an
  application-conformed protocol.
- `NavigationTab` is replaced by `NavigationRoot`.
- Root placement and search role metadata move from `Navigable` to each root.
- `Navigable.image` is renamed to `icon`, and `destination` to `content`.
- Navigation terminology now uses `navigate`, `navigateBack`, `returnToRoot`,
  `present`, and `dismiss` rather than UIKit-style push/pop vocabulary.
- SwiftUI's type-based observable environment replaces custom erased
  navigation environment values.

### Removed

- The separate `Sheet` destination protocol and controller modal generic.
- The legacy app-defined controller protocol and mutable public path API.
- The package's hand-built tab bar/sidebar implementation.
- Obsolete `Serotonin` environment entries and naming.

See [Migrating from 0.1.x to 1.0](Documentation/Guidebook/migration-to-1.0.md)
for replacement APIs and examples.
