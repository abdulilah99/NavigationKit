import SwiftUI
import Testing
@testable import NavigationKit

private enum TestToast: Toastable {
    case message(Int)
    case loading

    var content: some View { Text("Toast") }

    var swipeToDismiss: Bool {
        switch self {
        case .loading: false
        case .message: true
        }
    }
}

@MainActor
private final class ToastTestTime {
    var instant = ContinuousClock.now
    var date = Date(timeIntervalSinceReferenceDate: 1_000)

    var clock: ToastClock {
        ToastClock(now: { self.instant }, date: { self.date })
    }

    func advance(seconds: Int) {
        instant = instant.advanced(by: .seconds(seconds))
        date.addTimeInterval(Double(seconds))
    }
}

@MainActor
@Test
func identicalToastsHaveIndependentIdentitiesAndDeadlines() throws {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    let first = try #require(toasts.show(.message(1)))
    time.advance(seconds: 2)
    let second = try #require(toasts.show(.message(1)))

    #expect(first.id != second.id)
    #expect(first.expiresAt == Date(timeIntervalSinceReferenceDate: 1_004))
    #expect(second.expiresAt == Date(timeIntervalSinceReferenceDate: 1_006))
    time.advance(seconds: 2)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations == [second])
    time.advance(seconds: 2)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations.isEmpty)
}

@MainActor
@Test
func toastsCanExpireOutOfOrderAndPersistentToastsRemain() throws {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    let long = try #require(toasts.show(.message(1), expiration: .after(.seconds(10))))
    let persistent = try #require(toasts.show(.message(2), expiration: .never))
    toasts.show(.message(3), expiration: .after(.seconds(2)))
    time.advance(seconds: 3)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations == [long, persistent])
    time.advance(seconds: 1_000)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations == [persistent])
    #expect(persistent.expiresAt == nil)
}

@MainActor
@Test
func wallClockChangesAffectFixedDatesButNotRelativeDurations() throws {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    let elapsed = try #require(toasts.show(.message(1), expiration: .after(.seconds(10))))
    toasts.show(.message(2), expiration: .at(time.date.addingTimeInterval(10)))

    time.date.addTimeInterval(100)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations == [elapsed])
    time.advance(seconds: 10)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations.isEmpty)
}

@MainActor
@Test
func fixedDatesWaitWhenTheWallClockMovesBackward() throws {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    let toast = try #require(toasts.show(.message(1), expiration: .at(time.date.addingTimeInterval(10))))
    time.date.addTimeInterval(-100)
    time.advance(seconds: 10)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations == [toast])
    time.advance(seconds: 100)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations.isEmpty)
}

@MainActor
@Test
func updatingContentPreservesOccurrencePlacementAndDeadline() throws {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    let toast = try #require(toasts.show(.loading, edge: .top, alignment: .trailing))
    #expect(!toast.toast.swipeToDismiss)
    let deadline = toast.expiresAt
    time.advance(seconds: 2)
    toasts.update(id: toast.id, with: .message(2))

    #expect(toasts.presentations == [toast])
    #expect(toast.edge == .top)
    #expect(toast.alignment == .trailing)
    #expect(toast.expiresAt == deadline)
    #expect(toast.toast.swipeToDismiss)
    guard case .message(2) = toast.toast else {
        Issue.record("Expected updated content")
        return
    }
    time.advance(seconds: 2)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations.isEmpty)
}

@MainActor
@Test
func expirationOverridesRestartOrRemoveTheDeadline() throws {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    let toast = try #require(toasts.show(.message(1)))
    time.advance(seconds: 2)
    toasts.update(id: toast.id, with: .message(2), expiration: .after(.seconds(10)), edge: .top)
    time.advance(seconds: 3)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations == [toast])
    #expect(toast.expiresAt == Date(timeIntervalSinceReferenceDate: 1_012))
    #expect(toast.edge == .top)

    toasts.update(id: toast.id, with: .message(3), expiration: .never)
    time.advance(seconds: 100)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations == [toast])
    #expect(toast.expiresAt == nil)
}

@MainActor
@Test
func invalidInitialDeadlinesAreRejectedWithoutCallbacks() {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    for expiration in [ToastExpiration.after(.zero), .after(.seconds(-1)), .at(time.date), .at(.distantPast)] {
        #expect(toasts.show(.message(1), expiration: expiration) { _ in
            Issue.record("Rejected toasts must not call onDismiss")
        } == nil)
    }
    #expect(toasts.presentations.isEmpty)
}

@MainActor
@Test
func expiredUpdatesAndRepeatedDismissalsCallBackExactlyOnce() throws {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    var reasons: [ToastDismissalReason] = []
    let toast = try #require(toasts.show(.message(1)) { reasons.append($0) })
    toasts.update(id: toast.id, with: .message(2), expiration: .at(time.date))
    toasts.dismiss(id: toast.id)
    toasts.update(id: toast.id, with: .message(3), expiration: .never)
    #expect(reasons == [.expired])
    #expect(toasts.presentations.isEmpty)
}

@MainActor
@Test
func toastDismissalCallbacksCanMutateTheControllerReentrantly() {
    let toasts = ToastController<TestToast>()
    var callbacks: [Int] = []
    toasts.show(.message(1), expiration: .never) { _ in
        callbacks.append(1)
        toasts.dismissAll()
        toasts.show(.message(3), expiration: .never)
    }
    toasts.show(.message(2), expiration: .never) { _ in callbacks.append(2) }
    toasts.dismissAll()
    #expect(callbacks == [1, 2])
    #expect(toasts.presentations.count == 1)
    toasts.dismissAll()
}

@MainActor
@Test
func hiddenToastsStillKeepTheirOwnLifetime() {
    let time = ToastTestTime()
    let toasts = ToastController<TestToast>(clock: time.clock)
    for value in 0..<8 {
        toasts.show(.message(value), expiration: .after(.seconds(value + 1)))
    }
    #expect(toasts.presentations.count == 8)
    time.advance(seconds: 5)
    toasts.removeExpiredToasts()
    #expect(toasts.presentations.count == 3)
}

@MainActor
@Test
func expirationTaskDoesNotKeepItsControllerAlive() {
    weak var reference: ToastController<TestToast>?
    do {
        let toasts = ToastController<TestToast>()
        reference = toasts
        toasts.show(.message(1), expiration: .after(.seconds(3_600)))
    }
    #expect(reference == nil)
}

@MainActor
@Test(.timeLimit(.minutes(1)))
func scheduledExpirationRemovesTheToastWithoutAHost() async throws {
    let events = AsyncStream<Void>.makeStream()
    let toasts = ToastController<TestToast>()
    toasts.show(.message(1), expiration: .after(.milliseconds(10))) { reason in
        #expect(reason == .expired)
        events.continuation.yield(())
        events.continuation.finish()
    }
    for await _ in events.stream { break }
    #expect(toasts.presentations.isEmpty)
}
