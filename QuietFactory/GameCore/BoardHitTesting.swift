import CoreGraphics
import Foundation

/// SpriteKit-free board tap hit testing using scene coordinates.
enum BoardHitTesting {
    /// Converts a tap location in board-local coordinates to a grid cell.
    /// Returns nil when the point is outside the board rectangle or maps outside valid bounds.
    static func gridPosition(
        at location: CGPoint,
        boardWidth: Int,
        boardHeight: Int,
        cellSize: CGFloat
    ) -> GridPosition? {
        guard location.x >= 0, location.y >= 0 else { return nil }

        let gridX = Int(location.x / cellSize)
        let sceneRow = Int(location.y / cellSize)

        guard gridX >= 0, gridX < boardWidth else { return nil }
        guard sceneRow >= 0, sceneRow < boardHeight else { return nil }

        let gridY = boardHeight - 1 - sceneRow
        return GridPosition(x: gridX, y: gridY)
    }
}
