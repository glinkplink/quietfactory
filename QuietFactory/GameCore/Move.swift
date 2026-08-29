import Foundation

struct Move: Hashable, Codable, Sendable {
    let crateID: CrateID
}

enum MoveFailure: Error, Equatable, Sendable {
    case gameNotPlaying
    case crateNotFound
    case pathBlocked
    case conveyorFull
}

struct MoveResult: Sendable {
    let state: GameState
    let clearedMatchColors: [CrateColor]
    let releasedCrateID: CrateID
}
