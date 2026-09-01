import CoreGraphics
import Foundation

enum MoveDirection: String, CaseIterable, Codable, Sendable {
    case north
    case south
    case east
    case west

    struct Delta: Sendable {
        let dx: Int
        let dy: Int
    }

    var delta: Delta {
        switch self {
        case .north: Delta(dx: 0, dy: -1)
        case .south: Delta(dx: 0, dy: 1)
        case .east: Delta(dx: 1, dy: 0)
        case .west: Delta(dx: -1, dy: 0)
        }
    }

    /// Unit vector for rendering arrow orientation (SpriteKit uses y-up; north points up).
    var displayVector: (dx: CGFloat, dy: CGFloat) {
        switch self {
        case .north: (0, 1)
        case .south: (0, -1)
        case .east: (1, 0)
        case .west: (-1, 0)
        }
    }
}
