import Foundation

enum GameStatus: String, Codable, Sendable {
    case playing
    case won
    case stuck
}

struct GameState: Codable, Sendable {
    var board: BoardState
    var conveyor: ConveyorState
    var status: GameStatus
    let matchSize: Int

    init(board: BoardState, conveyorCapacity: Int, matchSize: Int, status: GameStatus = .playing) {
        self.board = board
        self.conveyor = ConveyorState(capacity: conveyorCapacity)
        self.status = status
        self.matchSize = matchSize
    }
}
