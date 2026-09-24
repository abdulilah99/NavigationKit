/// Every location used by the example. The same value type can act as a root,
/// a destination inside a path, or a modal presentation.
enum Page: Hashable {
    case home
    case library
    case search
    case settings
    case article(Int)
    case filters
    case player(Int)
    case toastBindings
}
