import Foundation

/// Pure deterministic game rules — no SpriteKit dependency.
enum GameEngine {
    static func isReleaseValid(crateID: CrateID, in state: GameState) -> Bool {
        guard state.status == .playing else { return false }
        guard state.conveyor.hasSpace else { return false }
        guard let crate = state.board.crates[crateID] else { return false }
        return hasClearExitPath(for: crate, on: state.board)
    }

    static func legalMoves(in state: GameState) -> [CrateID] {
        guard state.status == .playing else { return [] }
        guard state.conveyor.hasSpace else { return [] }
        return state.board.crates.values
            .filter { hasClearExitPath(for: $0, on: state.board) }
            .map(\.id)
            .sorted { $0.rawValue < $1.rawValue }
    }

    static func hasClearExitPath(for crate: Crate, on board: BoardState) -> Bool {
        var position = crate.position
        let delta = crate.direction.delta
        while true {
            let next = GridPosition(x: position.x + delta.dx, y: position.y + delta.dy)
            if !board.isInBounds(next) {
                return true
            }
            if board.crateID(at: next) != nil {
                return false
            }
            position = next
        }
    }

    static func apply(move: Move, to state: GameState) throws -> MoveResult {
        guard state.status == .playing else { throw MoveFailure.gameNotPlaying }
        guard state.conveyor.hasSpace else { throw MoveFailure.conveyorFull }
        guard let crate = state.board.crates[move.crateID] else { throw MoveFailure.crateNotFound }
        guard hasClearExitPath(for: crate, on: state.board) else { throw MoveFailure.pathBlocked }

        var newState = state
        newState.board.crates.removeValue(forKey: move.crateID)
        newState.conveyor.slots.append(ConveyorCrate(id: crate.id, color: crate.color))

        let cleared = resolveMatches(on: &newState)
        evaluateOutcome(&newState)

        return MoveResult(state: newState, clearedMatchColors: cleared, releasedCrateID: move.crateID)
    }

    /// Removes the first eligible match repeatedly until none remain. Deterministic: left-to-right scan.
    static func resolveMatches(on state: inout GameState) -> [CrateColor] {
        var clearedColors: [CrateColor] = []
        while let match = findFirstMatch(in: state.conveyor.slots, matchSize: state.matchSize) {
            let color = state.conveyor.slots[match.lowerBound].color
            state.conveyor.slots.removeSubrange(match)
            clearedColors.append(color)
        }
        return clearedColors
    }

    private static func findFirstMatch(in slots: [ConveyorCrate], matchSize: Int) -> Range<Int>? {
        guard slots.count >= matchSize else { return nil }
        let limit = slots.count - matchSize + 1
        for start in 0..<limit {
            let color = slots[start].color
            var matched = true
            for offset in 1..<matchSize {
                if slots[start + offset].color != color {
                    matched = false
                    break
                }
            }
            if matched {
                return start..<(start + matchSize)
            }
        }
        return nil
    }

    static func hasResolvableMatch(in state: GameState) -> Bool {
        findFirstMatch(in: state.conveyor.slots, matchSize: state.matchSize) != nil
    }

    static func isWin(_ state: GameState) -> Bool {
        state.board.isEmpty && state.conveyor.slots.isEmpty
    }

    static func isStuck(_ state: GameState) -> Bool {
        guard state.status == .playing else { return false }
        if state.conveyor.isFull && !hasResolvableMatch(in: state) {
            return true
        }
        let moves = legalMoves(in: state)
        if moves.isEmpty && !state.conveyor.slots.isEmpty && !hasResolvableMatch(in: state) {
            return true
        }
        return false
    }

    static func evaluateOutcome(_ state: inout GameState) {
        if isWin(state) {
            state.status = .won
        } else if isStuck(state) {
            state.status = .stuck
        } else {
            state.status = .playing
        }
    }

    static func restart(level: LevelDefinition) -> GameState {
        level.makeInitialState()
    }

    /// Replays a move sequence from a level's initial state. Throws if any move is illegal.
    static func replay(level: LevelDefinition, moves: [Move]) throws -> GameState {
        var state = level.makeInitialState()
        for move in moves {
            let result = try apply(move: move, to: state)
            state = result.state
        }
        return state
    }
}
