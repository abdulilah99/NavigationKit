enum Page: Hashable {
    case home
    case library
    case search
    case settings
    case article(Int)
    case filters
    case player(Int)
}
