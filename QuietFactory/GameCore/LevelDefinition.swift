import Foundation

struct CrateDefinition: Codable, Sendable {
    let x: Int
    let y: Int
    let direction: MoveDirection
    let color: CrateColor
}

struct LevelDefinition: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let width: Int
    let height: Int
    let crates: [CrateDefinition]
    let matchSize: Int
    let conveyorCapacity: Int
    let category: LevelCategory

    enum LevelCategory: String, Codable, Sendable {
        case onboarding
        case normal
        case sequencing
        case difficult
    }

    func makeInitialState() -> GameState {
        var nextID = 1
        let crates = crates.map { def -> Crate in
            let id = CrateID(rawValue: nextID)
            nextID += 1
            return Crate(
                id: id,
                position: GridPosition(x: def.x, y: def.y),
                direction: def.direction,
                color: def.color
            )
        }
        let board = BoardState(width: width, height: height, crates: crates)
        return GameState(board: board, conveyorCapacity: conveyorCapacity, matchSize: matchSize)
    }
}
