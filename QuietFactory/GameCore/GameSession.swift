import Combine
import Foundation

/// Observable game session bridging pure model and UI.
final class GameSession: ObservableObject {
    @Published private(set) var state: GameState
    let level: LevelDefinition

    init(level: LevelDefinition) {
        self.level = level
        var initial = level.makeInitialState()
        GameEngine.evaluateOutcome(&initial)
        self.state = initial
    }

    func restart() {
        var reset = GameEngine.restart(level: level)
        GameEngine.evaluateOutcome(&reset)
        state = reset
    }

    func attemptRelease(crateID: CrateID) -> ReleaseAttemptResult {
        guard GameEngine.isReleaseValid(crateID: crateID, in: state) else {
            return .blocked(crateID: crateID)
        }
        do {
            let result = try GameEngine.apply(move: Move(crateID: crateID), to: state)
            state = result.state
            return .released(
                crateID: result.releasedCrateID,
                clearedColors: result.clearedMatchColors,
                newStatus: state.status
            )
        } catch {
            return .blocked(crateID: crateID)
        }
    }

    var legalMoveIDs: Set<CrateID> {
        Set(GameEngine.legalMoves(in: state))
    }
}

enum ReleaseAttemptResult {
    case released(crateID: CrateID, clearedColors: [CrateColor], newStatus: GameStatus)
    case blocked(crateID: CrateID)
}
