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
private func makeController(
    selectedRoot: TestPage = .home,
    roots: [NavigationRoot<TestPage>] = [
        NavigationRoot(destination: .home),
        NavigationRoot(destination: .library),
    ]
) -> NavigationController<TestPage> {
    NavigationController(roots: roots, selectedRoot: selectedRoot)
}

@MainActor
@Test
func navigateAppendsUnequalDestinationsEvenWhenHashesCollide() {
    let router = makeController()

    router.navigate(to: .details(1))
    router.navigate(to: .details(2))

    #expect(router.selectedRoot == .home)
    #expect(router[.home] == [.details(1), .details(2)])
    #expect(router[.library].isEmpty)
}

@MainActor
@Test
func navigatingToAnExistingDestinationTrimsEverythingAfterIt() {
    let router = makeController()
    router[.home] = [.details(1), .details(2), .details(3)]

    router.navigate(to: .details(2))

    #expect(router[.home] == [.details(1), .details(2)])
}

@MainActor
@Test
func navigateOnAnotherRootMutatesAndSelectsThatRoot() {
    let router = makeController()

    router.navigate(to: .details(42), on: .library)

    #expect(router.selectedRoot == .library)
    #expect(router[.home].isEmpty)
    #expect(router[.library] == [.details(42)])
}

@MainActor
@Test
func selectingRootPreservesEveryRootPath() {
    let router = makeController()
    router[.home] = [.library, .details(1)]
    router[.library] = [.details(2)]

    router.select(root: .library)
    router.select(root: .home)

    #expect(router.selectedRoot == .home)
    #expect(router[.home] == [.library, .details(1)])
    #expect(router[.library] == [.details(2)])
}

@MainActor
@Test
func selectingAnUnconfiguredRootDoesNothing() {
    let router = makeController()

    router.select(root: .details(99))

    #expect(router.selectedRoot == .home)
    #expect(router.roots.map(\.destination) == [.home, .library])
}

@MainActor
@Test
func navigationControllerDefaultsToItsFirstRoot() {
    let controller = NavigationController<TestPage>(roots: [
        NavigationRoot(destination: .library),
        NavigationRoot(destination: .home),
    ])

    #expect(controller.selectedRoot == .library)
    #expect(controller.roots.map(\.destination) == [.library, .home])
}

@MainActor
@Test
func rootCatalogRequiresUniqueDestinations() {
    let uniqueRoots = [
        NavigationRoot(destination: TestPage.home),
        NavigationRoot(destination: TestPage.library),
    ]
    let duplicateRoots = [
        NavigationRoot(destination: TestPage.home),
        NavigationRoot(destination: TestPage.home),
    ]

    // TestPage deliberately gives every value the same hash.
    #expect(NavigationController<TestPage>.hasUniqueDestinations(uniqueRoots))
    #expect(!NavigationController<TestPage>.hasUniqueDestinations(duplicateRoots))
}

@MainActor
@Test
func navigatingOnAnUnconfiguredRootDoesNothing() {
    let router = makeController()

    router.navigate(to: .details(1), on: .details(99))

    #expect(router.selectedRoot == .home)
    #expect(router[.home].isEmpty)
    #expect(router[.library].isEmpty)
    #expect(router.roots.map(\.destination) == [.home, .library])
}

@MainActor
@Test
func aConfiguredRootCanAlsoAppearInAnotherRootPath() {
    let router = makeController()

    router.navigate(to: .library, on: .home)

    #expect(router.selectedRoot == .home)
    #expect(router[.home] == [.library])
    #expect(router.roots.contains(where: { $0.destination == .library }))
}

@Test
func aUniformSurfacePolicyAppliesToEveryContext() {
    let policy = NavigationSurfacePolicy(.sidebar)

    #expect(policy.surfaces(in: .compact) == .sidebar)
    #expect(policy.surfaces(in: .expanded) == .sidebar)
    #expect(policy.surfaces(in: .television) == .sidebar)
    #expect(policy.surfaces(in: .desktop) == .sidebar)
    #expect(policy.surfaces(in: .spatial) == .sidebar)
}

@Test
func aSurfacePolicyCanPlaceTheSameRootDifferentlyByContext() {
    let policy = NavigationSurfacePolicy(
        compact: .tabBar,
        expanded: .sidebar,
        television: .sidebar,
        desktop: .all,
        spatial: []
    )

    #expect(policy.surfaces(in: .compact) == .tabBar)
    #expect(policy.surfaces(in: .expanded) == .sidebar)
    #expect(policy.surfaces(in: .television) == .sidebar)
    #expect(policy.surfaces(in: .desktop) == .all)
    #expect(policy.surfaces(in: .spatial).isEmpty)
}

@MainActor
@Test
func navigationRootDefaultsToAllSurfaces() {
    let root = NavigationRoot(destination: TestPage.home)

    #expect(root.surfaces(in: .compact) == .all)
    #expect(root.surfaces(in: .expanded) == .all)
    #expect(root.surfaces(in: .television) == .all)
    #expect(root.surfaces(in: .desktop) == .all)
    #expect(root.surfaces(in: .spatial) == .all)
}

@MainActor
@Test
func rootSurfacePolicyControlsPlacement() {
    let policy = NavigationSurfacePolicy(
        compact: .sidebar,
        expanded: .tabBar,
        television: .all,
        desktop: [],
        spatial: .sidebar
    )
    let root = NavigationRoot(
        destination: TestPage.home,
        surfacePolicy: policy
    )

    #expect(root.surfaces(in: .compact) == .sidebar)
    #expect(root.surfaces(in: .expanded) == .tabBar)
    #expect(root.surfaces(in: .television) == .all)
    #expect(root.surfaces(in: .desktop).isEmpty)
    #expect(root.surfaces(in: .spatial) == .sidebar)
}

@MainActor
@Test
func readingSurfacePlacementDoesNotChangeControllerState() {
    let policy = NavigationSurfacePolicy(
        compact: .tabBar,
        expanded: .sidebar,
        television: [],
        desktop: .all,
        spatial: .sidebar
    )
    let root = NavigationRoot(
        destination: TestPage.home,
        path: [.details(1)],
        surfacePolicy: policy
    )
    let router = makeController(roots: [
        root,
        NavigationRoot(destination: .library),
    ])

    for context in [
        NavigationPresentationContext.compact,
        .expanded,
        .television,
        .desktop,
        .spatial,
    ] {
        _ = root.surfaces(in: context)
    }

    #expect(router.selectedRoot == .home)
    #expect(router[.home] == [.details(1)])
    #expect(router[.library].isEmpty)
}
