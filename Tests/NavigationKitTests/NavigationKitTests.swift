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
    configuration: NavigationControllerConfiguration = .default,
    roots: [NavigationRoot<TestPage>] = [
        NavigationRoot(destination: .home),
        NavigationRoot(destination: .library),
    ]
) -> NavigationController<TestPage> {
    NavigationController(
        roots: roots,
        selectedRoot: selectedRoot,
        configuration: configuration
    )
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

@Test
func navigationConfigurationHasSafePresentationDefaults() {
    let configuration = NavigationControllerConfiguration.default

    #expect(configuration.defaultPresentationStyle == .sheet)
    #expect(configuration.maximumPresentationDepth == 8)
}

@MainActor
@Test
func controllerConfigurationIsEditableAndControlsFuturePresentations() throws {
    let navigation = makeController()
    navigation.configuration.defaultPresentationStyle = .fullScreen
    navigation.configuration.maximumPresentationDepth = 1

    let presentation = try #require(navigation.present(.details(1)))

    #expect(presentation.style == .fullScreen)
    #expect(!navigation.canPresent)

    var rejectedDismissalRan = false
    let rejectedPresentation = navigation.present(.details(2)) {
        rejectedDismissalRan = true
    }

    #expect(rejectedPresentation == nil)
    #expect(navigation.presentations.map(\.destination) == [.details(1)])

    navigation.dismissPresentation()

    #expect(!rejectedDismissalRan)
    #expect(navigation.canPresent)
    #expect(navigation.present(.details(2))?.style == .fullScreen)
}

@MainActor
@Test
func explicitPresentationStyleOverridesTheConfiguredDefault() throws {
    let navigation = makeController(
        configuration: NavigationControllerConfiguration(
            defaultPresentationStyle: .fullScreen
        )
    )

    let presentation = try #require(
        navigation.present(.details(1), as: .sheet)
    )

    #expect(presentation.style == .sheet)
}

@MainActor
@Test
func loweringPresentationDepthDoesNotRewriteExistingState() {
    let navigation = makeController()
    navigation.present(.details(1))
    navigation.present(.details(2))

    navigation.configuration.maximumPresentationDepth = 1

    #expect(navigation.presentations.map(\.destination) == [
        .details(1),
        .details(2),
    ])
    #expect(!navigation.canPresent)

    navigation.dismissPresentations(count: 2)

    #expect(navigation.canPresent)
}

@MainActor
@Test
func zeroPresentationDepthDisablesPresentation() {
    let navigation = makeController(
        configuration: NavigationControllerConfiguration(
            maximumPresentationDepth: 0
        )
    )

    #expect(!navigation.canPresent)
    #expect(navigation.present(.details(1)) == nil)
    #expect(navigation.presentations.isEmpty)
}

@MainActor
@Test
func initialPresentationsUseTheConfiguredDepthLimit() {
    let presentation = NavigationPresentation<TestPage>(
        destination: .details(1),
        style: .sheet
    )
    let navigation = NavigationController(
        roots: [NavigationRoot(destination: TestPage.home)],
        presentations: [presentation],
        configuration: NavigationControllerConfiguration(
            maximumPresentationDepth: 1
        )
    )

    #expect(navigation.presentations.map(\.id) == [presentation.id])
    #expect(!navigation.canPresent)
    #expect(navigation.present(.details(2)) == nil)
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

@MainActor
@Test
func presentingTheSameDestinationCreatesDistinctStackOccurrences() throws {
    let navigation = makeController()

    let first = try #require(navigation.present(.details(1), as: .sheet))
    let second = try #require(
        navigation.present(.details(1), as: .fullScreen)
    )

    #expect(first.id != second.id)
    #expect(navigation.presentations.map(\.destination) == [
        .details(1),
        .details(1),
    ])
    #expect(navigation.presentations.map(\.style) == [.sheet, .fullScreen])
}

@MainActor
@Test
func presentationPathsAreIndependentFromRootsAndOtherPresentations() throws {
    let navigation = makeController()
    let first = try #require(
        navigation.present(
            .details(1),
            path: [.details(5)]
        )
    )
    let second = try #require(navigation.present(.details(2)))

    navigation.navigate(to: .details(10), in: first.id)
    navigation.navigate(to: .details(20), in: second.id)

    #expect(navigation[presentation: first.id] == [
        .details(5),
        .details(10),
    ])
    #expect(navigation[presentation: second.id] == [.details(20)])
    #expect(navigation[.home].isEmpty)
    #expect(navigation[.library].isEmpty)
}

@MainActor
@Test
func navigatingInsideAPresentationUsesFirstMatchReuseBehavior() throws {
    let navigation = makeController()
    let presentation = try #require(navigation.present(.details(1)))
    navigation[presentation: presentation.id] = [
        .details(10),
        .details(20),
        .details(30),
    ]

    navigation.navigate(to: .details(20), in: presentation.id)

    #expect(navigation[presentation: presentation.id] == [
        .details(10),
        .details(20),
    ])
}

@MainActor
@Test
func missingPresentationPathOperationsAreNoOps() {
    let navigation = makeController()
    let missingID = NavigationPresentation<TestPage>(
        destination: .details(99),
        style: .sheet
    ).id

    navigation.navigate(to: .details(1), in: missingID)
    navigation[presentation: missingID] = [.details(2)]

    #expect(navigation[presentation: missingID].isEmpty)
    #expect(navigation.presentations.isEmpty)
    #expect(navigation[.home].isEmpty)
}

@MainActor
@Test
func dismissPresentationRemovesOnlyTheTopLayer() throws {
    let navigation = makeController()
    let first = try #require(navigation.present(.details(1)))
    let second = try #require(navigation.present(.details(2)))

    navigation.dismissPresentation()

    #expect(navigation.presentations.map(\.id) == [first.id])
    #expect(!navigation.presentations.contains(where: { $0.id == second.id }))
}

@MainActor
@Test
func dismissingAPresentationRemovesItsDescendantsTopFirst() throws {
    let navigation = makeController()
    var dismissalOrder: [Int] = []

    let first = try #require(
        navigation.present(.details(1)) {
            dismissalOrder.append(1)
        }
    )
    navigation.present(.details(2)) {
        dismissalOrder.append(2)
    }
    navigation.present(.details(3)) {
        dismissalOrder.append(3)
    }

    navigation.dismissPresentation(id: first.id)

    #expect(navigation.presentations.isEmpty)
    #expect(dismissalOrder == [3, 2, 1])

    navigation.dismissPresentation(id: first.id)
    #expect(dismissalOrder == [3, 2, 1])
}

@MainActor
@Test
func dismissPresentationCountClampsToTheExistingStack() {
    let navigation = makeController()
    navigation.present(.details(1))
    navigation.present(.details(2))
    navigation.present(.details(3))

    navigation.dismissPresentations(count: 2)
    #expect(navigation.presentations.map(\.destination) == [.details(1)])

    navigation.dismissPresentations(count: 10)
    #expect(navigation.presentations.isEmpty)

    navigation.dismissPresentations(count: 0)
    navigation.dismissPresentations(count: -1)
    #expect(navigation.presentations.isEmpty)
}

@MainActor
@Test
func dismissAllPresentationsRunsEveryCallbackExactlyOnce() {
    let navigation = makeController()
    var dismissalCount = 0

    for id in 1...3 {
        navigation.present(.details(id)) {
            dismissalCount += 1
        }
    }

    navigation.dismissAllPresentations()
    navigation.dismissAllPresentations()

    #expect(navigation.presentations.isEmpty)
    #expect(dismissalCount == 3)
}

@MainActor
@Test
func dismissalCallbacksCanPresentAReplacementWithoutLosingIt() {
    let navigation = makeController()

    navigation.present(.details(1)) {
        navigation.present(.details(99))
    }

    navigation.dismissPresentation()

    #expect(navigation.presentations.map(\.destination) == [.details(99)])
}

@MainActor
@Test
func configuredPresentationIDsMustBeUnique() {
    let identifier = NavigationPresentation<TestPage>(
        destination: .details(1),
        style: .sheet
    ).id
    let uniquePresentations = [
        NavigationPresentation(
            id: identifier,
            destination: TestPage.details(1),
            style: .sheet
        ),
        NavigationPresentation(
            destination: TestPage.details(1),
            style: .sheet
        ),
    ]
    let duplicatePresentations = [
        NavigationPresentation(
            id: identifier,
            destination: TestPage.details(1),
            style: .sheet
        ),
        NavigationPresentation(
            id: identifier,
            destination: TestPage.details(2),
            style: .sheet
        ),
    ]

    #expect(
        NavigationController<TestPage>.hasUniquePresentationIDs(
            uniquePresentations
        )
    )
    #expect(
        !NavigationController<TestPage>.hasUniquePresentationIDs(
            duplicatePresentations
        )
    )
}
