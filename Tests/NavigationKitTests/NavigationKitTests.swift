import Observation
import SwiftUI
import Testing
@testable import NavigationKit

private enum TestPage: Navigable {
    case home
    case library
    case details(Int)

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .home:
            "Home"
        case .library:
            "Library"
        case .details(let id):
            "Details \(id)"
        }
    }

    var image: Image {
        Image(systemName: "circle")
    }

    var destination: some View {
        Color.clear
    }

    func hash(into hasher: inout Hasher) {
        // Deliberately collide so tests verify that navigation uses equality,
        // never hash values, to identify destinations.
        hasher.combine(0)
    }
}

@MainActor
@Observable
private final class TestRouter: NavigationController {
    var selectedTab: TestPage
    var tabs: [NavigationTab<TestPage>]

    init(
        selectedTab: TestPage = .home,
        tabs: [NavigationTab<TestPage>] = [
            NavigationTab(page: .home),
            NavigationTab(page: .library),
        ]
    ) {
        self.selectedTab = selectedTab
        self.tabs = tabs
    }
}

@MainActor
@Test
func navigateAppendsUnequalDestinationsEvenWhenHashesCollide() {
    let router = TestRouter()

    router.navigate(to: .details(1))
    router.navigate(to: .details(2))

    #expect(router.selectedTab == .home)
    #expect(router[.home] == [.details(1), .details(2)])
    #expect(router[.library].isEmpty)
}

@MainActor
@Test
func navigatingToAnExistingDestinationTrimsEverythingAfterIt() {
    let router = TestRouter()
    router[.home] = [.details(1), .details(2), .details(3)]

    router.navigate(to: .details(2))

    #expect(router[.home] == [.details(1), .details(2)])
}

@MainActor
@Test
func navigateOnAnotherRootMutatesAndSelectsThatRoot() {
    let router = TestRouter()

    router.navigate(to: .details(42), on: .library)

    #expect(router.selectedTab == .library)
    #expect(router[.home].isEmpty)
    #expect(router[.library] == [.details(42)])
}

@MainActor
@Test
func selectingRootPreservesEveryRootPath() {
    let router = TestRouter()
    router[.home] = [.library, .details(1)]
    router[.library] = [.details(2)]

    router.select(tab: .library)
    router.select(tab: .home)

    #expect(router.selectedTab == .home)
    #expect(router[.home] == [.library, .details(1)])
    #expect(router[.library] == [.details(2)])
}

@MainActor
@Test
func aConfiguredRootCanAlsoAppearInAnotherRootPath() {
    let router = TestRouter()

    router.navigate(to: .library, on: .home)

    #expect(router.selectedTab == .home)
    #expect(router[.home] == [.library])
    #expect(router.tabs.contains(where: { $0.page == .library }))
}
