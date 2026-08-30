import Foundation

struct MatchClearStep: Equatable, Sendable {
    /// Indices in the conveyor as it existed immediately before this clear.
    let range: Range<Int>
    let color: CrateColor
}

struct ReleasePresentation: Equatable, Sendable {
    let conveyorAfterLanding: [ConveyorCrate]
    let matchSteps: [MatchClearStep]
}

enum ReleaseAnimationPhase: Equatable, Sendable {
    case slide
    case land
    case reveal(range: Range<Int>)
    case clear(range: Range<Int>)
}

/// SpriteKit-free plan derived from a release presentation trace for tests.
struct ReleaseAnimationPlan: Equatable, Sendable {
    let phases: [ReleaseAnimationPhase]

    init(conveyorAfterLanding: [ConveyorCrate], matchSteps: [MatchClearStep]) {
        var phases: [ReleaseAnimationPhase] = [.slide, .land]
        for step in matchSteps {
            phases.append(.reveal(range: step.range))
            phases.append(.clear(range: step.range))
        }
        self.phases = phases
    }
}
