import UIKit

enum HapticsManager {
    static func selection() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func blocked() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    static func release() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func conveyorLanding() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func match() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func completion() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func failure() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
