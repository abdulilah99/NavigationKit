import SwiftUI
import Testing
@testable import NavigationKit

private struct BindingTestToast: Toastable {
    var expiration: ToastExpiration = .never
    var content: some View { Text("Bound toast") }
}

@MainActor
@Test
func boundToastDismissalResetsOnceAndCanPresentAgain() throws {
    let state = ToastBindingState<BindingTestToast>()
    var resets = 0
    var dismissals = 0
    state.synchronize(.init(), resetBinding: { resets += 1 }, onDismiss: { dismissals += 1 })
    let first = try #require(state.toasts.presentations.first)
    state.toasts.dismiss(id: first.id)
    state.dismiss()
    #expect(resets == 1)
    #expect(dismissals == 1)
    state.synchronize(.init(), resetBinding: { resets += 1 }, onDismiss: { dismissals += 1 })
    #expect(state.toasts.presentations.first?.id != first.id)
    state.synchronize(nil, resetBinding: {}, onDismiss: nil)
    #expect(resets == 2)
    #expect(dismissals == 2)
}

@MainActor
@Test
func boundToastUpdatesPreserveDeadlineAndUseLatestBindingReset() throws {
    var now = ContinuousClock.now
    let clock = ToastClock(now: { now }, date: { Date(timeIntervalSinceReferenceDate: 1_000) })
    let state = ToastBindingState(toasts: ToastController<BindingTestToast>(clock: clock))
    var oldReset = false
    var newReset = false
    state.synchronize(.init(expiration: .after(.seconds(4))), resetBinding: { oldReset = true }, onDismiss: nil)
    let first = try #require(state.toasts.presentations.first)
    now = now.advanced(by: .seconds(2))
    state.synchronize(.init(expiration: .never), resetBinding: { newReset = true }, onDismiss: nil)
    #expect(state.toasts.presentations.first?.id == first.id)
    now = now.advanced(by: .seconds(2))
    state.toasts.removeExpiredToasts()
    #expect(state.toasts.presentations.isEmpty)
    #expect(!oldReset)
    #expect(newReset)
}

@MainActor
@Test
func rejectedBoundToastClearsBindingWithoutDismissalCallback() {
    let state = ToastBindingState<BindingTestToast>()
    var resets = 0
    var dismissals = 0
    state.synchronize(.init(expiration: .after(.zero)), resetBinding: { resets += 1 }, onDismiss: { dismissals += 1 })
    #expect(state.toasts.presentations.isEmpty)
    #expect(resets == 1)
    #expect(dismissals == 0)
}

@MainActor
@Test
func boundToastDismissalCanReentrantlyPresentAnotherToast() {
    let state = ToastBindingState<BindingTestToast>()
    state.synchronize(.init(), resetBinding: {}, onDismiss: {
        state.synchronize(.init(), resetBinding: {}, onDismiss: nil)
    })
    state.dismiss()
    #expect(state.toasts.presentations.count == 1)
    state.dismiss()
    #expect(state.toasts.presentations.isEmpty)
}

@MainActor
@Test
func immediatelyExpiredBoundToastDoesNotLeaveAStaleOccurrence() {
    var now = ContinuousClock.now
    let clock = ToastClock(now: {
        defer { now = now.advanced(by: .seconds(2)) }
        return now
    })
    let state = ToastBindingState(toasts: ToastController<BindingTestToast>(clock: clock))
    var resets = 0
    state.synchronize(.init(expiration: .after(.seconds(1))), resetBinding: { resets += 1 }, onDismiss: nil)
    #expect(resets == 1)
    #expect(state.toasts.presentations.isEmpty)
    state.synchronize(.init(), resetBinding: {}, onDismiss: nil)
    #expect(state.toasts.presentations.count == 1)
    state.dismiss()
}
