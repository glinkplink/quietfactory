import Foundation

struct Crate: Hashable, Codable, Sendable {
    let id: CrateID
    let position: GridPosition
    let direction: MoveDirection
    let color: CrateColor
}
