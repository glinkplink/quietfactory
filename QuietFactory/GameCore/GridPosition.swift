import Foundation

/// Integer grid coordinate. Origin is top-left; x increases right, y increases down.
struct GridPosition: Hashable, Codable, Sendable {
    let x: Int
    let y: Int

    func translated(by direction: MoveDirection) -> GridPosition {
        let delta = direction.delta
        return GridPosition(x: x + delta.dx, y: y + delta.dy)
    }
}
