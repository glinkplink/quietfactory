import SpriteKit

final class GameScene: SKScene {
    weak var session: GameSession?

  var onRestart: (() -> Void)?
  var onLevelComplete: (() -> Void)?

    private var boardNode = SKNode()
    private var conveyorNode = SKNode()
    private var overlayNode = SKNode()
    private var crateNodes: [CrateID: SKNode] = [:]
    private var conveyorSlotNodes: [SKShapeNode] = []
    private var cellSize: CGFloat = 44
    private var boardOrigin: CGPoint = .zero
    private var boardHeight: Int = 0
    private(set) var isSceneAnimating = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.15, alpha: 1)
        addChild(boardNode)
        addChild(conveyorNode)
        addChild(overlayNode)
        layoutIfNeeded()
        refreshFromSession(animated: false)
    }

    func attach(session: GameSession) {
        self.session = session
        layoutIfNeeded()
        if !isSceneAnimating {
            refreshFromSession(animated: false)
        }
    }

    /// Clears animation locks and re-syncs after restart or level change.
    func resetAndAttach(session: GameSession) {
        isSceneAnimating = false
        for node in crateNodes.values {
            node.removeAllActions()
        }
        self.session = session
        layoutIfNeeded()
        refreshFromSession(animated: false)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutIfNeeded()
        if !isSceneAnimating {
            refreshFromSession(animated: false)
        }
    }

    private func layoutIfNeeded() {
        guard let session else { return }
        let width = session.state.board.width
        let height = session.state.board.height
        boardHeight = height
        let capacity = session.state.conveyor.capacity

        let margin: CGFloat = 16
        let conveyorHeight: CGFloat = 56
        let topLabel: CGFloat = 40
        let availableWidth = size.width - margin * 2
        let availableHeight = size.height - margin * 2 - conveyorHeight - topLabel

        cellSize = min(availableWidth / CGFloat(width), availableHeight / CGFloat(height))
        let boardPixelWidth = cellSize * CGFloat(width)
        let boardPixelHeight = cellSize * CGFloat(height)

        boardOrigin = CGPoint(
            x: (size.width - boardPixelWidth) / 2,
            y: margin + conveyorHeight + (availableHeight - boardPixelHeight) / 2
        )

        boardNode.position = boardOrigin
        conveyorNode.position = CGPoint(x: margin, y: margin)

        setupConveyorSlots(capacity: capacity, boardWidth: boardPixelWidth)
        drawGrid(width: width, height: height)
    }

    private func setupConveyorSlots(capacity: Int, boardWidth: CGFloat) {
        conveyorNode.removeAllChildren()
        conveyorSlotNodes = []
        let slotSpacing: CGFloat = 4
        let slotWidth = (boardWidth - slotSpacing * CGFloat(capacity - 1)) / CGFloat(capacity)
        for index in 0..<capacity {
            let slot = SKShapeNode(rectOf: CGSize(width: slotWidth, height: 48), cornerRadius: 6)
            slot.fillColor = SKColor(white: 0.25, alpha: 1)
            slot.strokeColor = SKColor(white: 0.45, alpha: 1)
            slot.lineWidth = 2
            slot.position = CGPoint(
                x: slotWidth / 2 + CGFloat(index) * (slotWidth + slotSpacing),
                y: 24
            )
            conveyorNode.addChild(slot)
            conveyorSlotNodes.append(slot)
        }
    }

    private func drawGrid(width: Int, height: Int) {
        boardNode.enumerateChildNodes(withName: "gridCell") { node, _ in node.removeFromParent() }
        for y in 0..<height {
            for x in 0..<width {
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize - 2, height: cellSize - 2), cornerRadius: 4)
                cell.name = "gridCell"
                cell.fillColor = SKColor(white: 0.22, alpha: 1)
                cell.strokeColor = SKColor(white: 0.35, alpha: 1)
                cell.lineWidth = 1
                cell.position = gridToScene(x: x, y: y)
                boardNode.addChild(cell)
            }
        }
    }

    private func gridToScene(x: Int, y: Int) -> CGPoint {
        let flippedY = boardHeight - 1 - y
        return CGPoint(
            x: CGFloat(x) * cellSize + cellSize / 2,
            y: CGFloat(flippedY) * cellSize + cellSize / 2
        )
    }

    private func sceneToGrid(location: CGPoint) -> GridPosition {
        let gridX = Int(location.x / cellSize)
        let sceneRow = Int(location.y / cellSize)
        let gridY = boardHeight - 1 - sceneRow
        return GridPosition(x: gridX, y: gridY)
    }

    func refreshFromSession(animated: Bool) {
        guard let session else { return }
        updateOverlay(for: session.state.status)
        syncConveyorCrates(session.state.conveyor, animated: animated)
        syncBoardCrates(session.state.board, legalIDs: session.legalMoveIDs, animated: animated)
    }

    private func syncBoardCrates(_ board: BoardState, legalIDs: Set<CrateID>, animated: Bool) {
        let existingIDs = Set(crateNodes.keys)
        let modelIDs = Set(board.crates.keys)

        for id in existingIDs.subtracting(modelIDs) {
            crateNodes[id]?.removeFromParent()
            crateNodes.removeValue(forKey: id)
        }

        for (id, crate) in board.crates {
            if let node = crateNodes[id] {
                let target = gridToScene(x: crate.position.x, y: crate.position.y)
                if animated {
                    node.run(SKAction.move(to: target, duration: 0.2))
                } else {
                    node.position = target
                }
                styleCrateNode(node, crate: crate, isLegal: legalIDs.contains(id))
            } else {
                let node = makeCrateNode(crate: crate, isLegal: legalIDs.contains(id))
                node.position = gridToScene(x: crate.position.x, y: crate.position.y)
                boardNode.addChild(node)
                crateNodes[id] = node
            }
        }
    }

    private func makeCrateNode(crate: Crate, isLegal: Bool) -> SKNode {
        let container = SKNode()
        container.name = "crate-\(crate.id.rawValue)"

        let size = cellSize * 0.72
        let body = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 6)
        let hue = crate.color.displayHue
        body.fillColor = SKColor(red: hue.red, green: hue.green, blue: hue.blue, alpha: 1)
        body.strokeColor = isLegal ? SKColor.white : SKColor(white: 0.55, alpha: 1)
        body.lineWidth = isLegal ? 3 : 1
        body.name = "body"
        container.addChild(body)

        let arrow = makeArrowNode(direction: crate.direction, size: size * 0.35)
        container.addChild(arrow)

        return container
    }

    private func styleCrateNode(_ node: SKNode, crate: Crate, isLegal: Bool) {
        if let body = node.childNode(withName: "body") as? SKShapeNode {
            let hue = crate.color.displayHue
            body.fillColor = SKColor(red: hue.red, green: hue.green, blue: hue.blue, alpha: 1)
            body.strokeColor = isLegal ? SKColor.white : SKColor(white: 0.55, alpha: 1)
            body.lineWidth = isLegal ? 3 : 1
        }
    }

    private func makeArrowNode(direction: MoveDirection, size: CGFloat) -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: -size * 0.35))
        path.addLine(to: CGPoint(x: 0, y: size * 0.45))
        path.addLine(to: CGPoint(x: -size * 0.35, y: -size * 0.05))
        path.addLine(to: CGPoint(x: size * 0.35, y: -size * 0.05))
        path.closeSubpath()

        let arrow = SKShapeNode(path: path)
        arrow.fillColor = SKColor(white: 0.95, alpha: 1)
        arrow.strokeColor = .clear

        switch direction {
        case .north:
            arrow.zRotation = 0
        case .south:
            arrow.zRotation = .pi
        case .east:
            arrow.zRotation = -.pi / 2
        case .west:
            arrow.zRotation = .pi / 2
        }

        return arrow
    }

    private func syncConveyorCrates(_ conveyor: ConveyorState, animated: Bool) {
        conveyorNode.enumerateChildNodes(withName: "conveyorCrate") { node, _ in node.removeFromParent() }

        guard !conveyorSlotNodes.isEmpty else { return }
        let capacity = conveyor.capacity
        let slotSpacing: CGFloat = 4
        let boardWidth = CGFloat(capacity) * conveyorSlotNodes[0].frame.width + slotSpacing * CGFloat(capacity - 1)
        let slotWidth = (boardWidth - slotSpacing * CGFloat(capacity - 1)) / CGFloat(capacity)

        for (index, crate) in conveyor.slots.enumerated() {
            let hue = crate.color.displayHue
            let node = SKShapeNode(rectOf: CGSize(width: slotWidth * 0.8, height: 36), cornerRadius: 5)
            node.name = "conveyorCrate"
            node.fillColor = SKColor(red: hue.red, green: hue.green, blue: hue.blue, alpha: 1)
            node.strokeColor = SKColor.white
            node.lineWidth = 1
            node.position = CGPoint(
                x: slotWidth / 2 + CGFloat(index) * (slotWidth + slotSpacing),
                y: 24
            )
            if animated {
                node.alpha = 0
                node.run(SKAction.fadeIn(withDuration: 0.15))
            }
            conveyorNode.addChild(node)
        }
    }

    private func updateOverlay(for status: GameStatus) {
        overlayNode.removeAllChildren()
        guard status != .playing else { return }

        let label = SKLabelNode(text: status == .won ? "Complete!" : "Stuck")
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 28
        label.fontColor = status == .won ? SKColor.green : SKColor.orange
        label.position = CGPoint(x: size.width / 2, y: size.height - 60)
        overlayNode.addChild(label)

        let hint = SKLabelNode(text: "Tap RESTART below")
        hint.fontName = "HelveticaNeue"
        hint.fontSize = 16
        hint.fontColor = SKColor(white: 0.8, alpha: 1)
        hint.position = CGPoint(x: size.width / 2, y: size.height - 90)
        overlayNode.addChild(hint)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isSceneAnimating, let session, session.state.status == .playing else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: boardNode)
        let position = sceneToGrid(location: location)
        guard let crateID = session.state.board.crateID(at: position) else { return }

        handleRelease(crateID: crateID)
    }

    private func handleRelease(crateID: CrateID) {
        guard let session else { return }
        guard let crate = session.state.board.crates[crateID] else { return }

        if !GameEngine.isReleaseValid(crateID: crateID, in: session.state) {
            HapticsManager.blocked()
            AudioManager.playBlocked()
            animateBlocked(crateID: crateID)
            return
        }

        let capturedCrate = crate
        let result = session.attemptRelease(crateID: crateID)

        switch result {
        case .blocked:
            HapticsManager.blocked()
            AudioManager.playBlocked()
            animateBlocked(crateID: crateID)
        case .released(_, let cleared, let status):
            HapticsManager.release()
            AudioManager.playRelease()
            isSceneAnimating = true
            animateRelease(crate: capturedCrate) {
                AudioManager.playConveyorLanding()
                HapticsManager.conveyorLanding()
                if !cleared.isEmpty {
                    AudioManager.playMatch()
                    HapticsManager.match()
                }
                self.refreshFromSession(animated: true)
                self.isSceneAnimating = false
                switch status {
                case .won:
                    HapticsManager.completion()
                    AudioManager.playWin()
                    self.onLevelComplete?()
                case .stuck:
                    HapticsManager.failure()
                    AudioManager.playStuck()
                case .playing:
                    break
                }
            }
        }
    }

    private func animateBlocked(crateID: CrateID) {
        guard let node = crateNodes[crateID] else { return }
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -6, y: 0, duration: 0.05),
            SKAction.moveBy(x: 12, y: 0, duration: 0.1),
            SKAction.moveBy(x: -6, y: 0, duration: 0.05)
        ])
        node.run(shake)
    }

    private func animateRelease(crate: Crate, completion: @escaping () -> Void) {
        guard let node = crateNodes[crate.id] else {
            completion()
            return
        }

        let delta = crate.direction.delta
        var exitX = crate.position.x
        var exitY = crate.position.y
        if let session {
            while session.state.board.isInBounds(GridPosition(x: exitX + delta.dx, y: exitY + delta.dy)) {
                exitX += delta.dx
                exitY += delta.dy
            }
        }
        let offBoard = GridPosition(x: exitX + delta.dx, y: exitY + delta.dy)
        let target = gridToScene(x: offBoard.x, y: offBoard.y)

        node.run(SKAction.sequence([
            SKAction.move(to: target, duration: 0.25),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ])) {
            self.crateNodes.removeValue(forKey: crate.id)
            completion()
        }
    }
}
