import Foundation

struct BoardState: Codable, Sendable {
    let width: Int
    let height: Int
    var crates: [CrateID: Crate]

    init(width: Int, height: Int, crates: [Crate]) {
        self.width = width
        self.height = height
        self.crates = Dictionary(uniqueKeysWithValues: crates.map { ($0.id, $0) })
    }

    func isInBounds(_ position: GridPosition) -> Bool {
        position.x >= 0 && position.x < width && position.y >= 0 && position.y < height
    }

    func crateID(at position: GridPosition) -> CrateID? {
        crates.values.first(where: { $0.position == position })?.id
    }

    var occupancy: Set<GridPosition> {
        Set(crates.values.map(\.position))
    }

    var isEmpty: Bool { crates.isEmpty }
}
