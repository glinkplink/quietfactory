import SpriteKit
import XCTest
@testable import QuietFactory

final class GameSceneRenderingTests: XCTestCase {
    func testOnb1BoardCratesRenderAboveGridCells() {
        let session = GameSession(level: LevelCatalog.onboarding[0])
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        let scene = GameScene(size: view.bounds.size)
        view.presentScene(scene)
        scene.attach(session: session)

        let gridCells = collectDescendants(of: scene, named: "gridCell")
        let boardCrates = collectDescendants(of: scene, named: nil, prefix: "crate-")

        XCTAssertEqual(boardCrates.count, 3, "onb-1 should show three board crates")

        let gridZ = gridCells.map(\.zPosition).max() ?? 0
        let crateZ = boardCrates.map(\.zPosition).min() ?? 0
        XCTAssertGreaterThan(crateZ, gridZ, "Board crates must draw above grid cells")
    }

    func testBoardHitTestingRejectsOutsideBoard() {
        let cellSize: CGFloat = 44
        let width = 5
        let height = 4

        XCTAssertNil(BoardHitTesting.gridPosition(
            at: CGPoint(x: -1, y: cellSize / 2),
            boardWidth: width,
            boardHeight: height,
            cellSize: cellSize
        ))
        XCTAssertNil(BoardHitTesting.gridPosition(
            at: CGPoint(x: cellSize / 2, y: -1),
            boardWidth: width,
            boardHeight: height,
            cellSize: cellSize
        ))
        XCTAssertNil(BoardHitTesting.gridPosition(
            at: CGPoint(x: CGFloat(width) * cellSize, y: cellSize / 2),
            boardWidth: width,
            boardHeight: height,
            cellSize: cellSize
        ))
        XCTAssertNil(BoardHitTesting.gridPosition(
            at: CGPoint(x: cellSize / 2, y: CGFloat(height) * cellSize),
            boardWidth: width,
            boardHeight: height,
            cellSize: cellSize
        ))
    }

    func testBoardHitTestingMapsInsideCellWithYFlip() {
        let cellSize: CGFloat = 44
        let width = 5
        let height = 4

        let topLeftModel = BoardHitTesting.gridPosition(
            at: CGPoint(x: cellSize / 2, y: cellSize / 2),
            boardWidth: width,
            boardHeight: height,
            cellSize: cellSize
        )
        XCTAssertEqual(topLeftModel, GridPosition(x: 0, y: height - 1))

        let center = BoardHitTesting.gridPosition(
            at: CGPoint(x: cellSize * 2.5, y: cellSize * 1.5),
            boardWidth: width,
            boardHeight: height,
            cellSize: cellSize
        )
        XCTAssertEqual(center, GridPosition(x: 2, y: height - 2))
    }

    private func collectDescendants(of node: SKNode, named name: String?) -> [SKNode] {
        collectDescendants(of: node, named: name, prefix: nil)
    }

    private func collectDescendants(of node: SKNode, named name: String?, prefix: String?) -> [SKNode] {
        var matches: [SKNode] = []
        if let name {
            if node.name == name {
                matches.append(node)
            }
        } else if let prefix, let nodeName = node.name, nodeName.hasPrefix(prefix) {
            matches.append(node)
        }
        for child in node.children {
            matches.append(contentsOf: collectDescendants(of: child, named: name, prefix: prefix))
        }
        return matches
    }
}
