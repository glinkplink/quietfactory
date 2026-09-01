import Foundation

/// Captures the session identity bound to a delayed win auto-advance callback.
struct WinCompletionGuard: Equatable {
    let sessionID: ObjectIdentifier
    let sceneRevision: Int

    init(session: GameSession) {
        sessionID = ObjectIdentifier(session)
        sceneRevision = session.sceneRevision
    }

    func isStillValid(for session: GameSession) -> Bool {
        ObjectIdentifier(session) == sessionID && session.sceneRevision == sceneRevision
    }
}
