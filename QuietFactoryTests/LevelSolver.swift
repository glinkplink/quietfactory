import Foundation
@testable import QuietFactory

/// Brute-force win search for validating hand-authored levels in tests only.
enum LevelSolver {
    static func canWin(level: LevelDefinition, maxDepth: Int = 40) -> Bool {
        var initial = level.makeInitialState()
        GameEngine.evaluateOutcome(&initial)
        if initial.status == .won { return true }
        return search(state: initial, depth: 0, maxDepth: maxDepth)
    }

    private static func search(state: GameState, depth: Int, maxDepth: Int) -> Bool {
        if GameEngine.isWin(state) { return true }
        if depth >= maxDepth || state.status == .stuck { return false }

        let moves = GameEngine.legalMoves(in: state)
        for crateID in moves {
            do {
                let result = try GameEngine.apply(move: Move(crateID: crateID), to: state)
                if search(state: result.state, depth: depth + 1, maxDepth: maxDepth) {
                    return true
                }
            } catch {
                continue
            }
        }
        return false
    }
}
