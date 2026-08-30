import SpriteKit

final class GameScene: SKScene {
    private static let levelCompleteActionKey = "levelCompleteAdvance"
    private static let releaseSequenceActionKey = "releaseSequence"

    /// Explicit draw order when SKView.ignoresSiblingOrder is true.
    enum Layer {
        static let gridCell: CGFloat = 0
        static let boardCrate: CGFloat = 10
        static let crateBody: CGFloat = 0
        static let crateArrow: CGFloat = 1
        static let conveyorSlot: CGFloat = 0
        static let conveyorCrate: CGFloat = 10
        static let gameplay: CGFloat = 20
        static let overlay: CGFloat = 100
    }

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
        conveyorNode.zPosition = Layer.gameplay
        boardNode.zPosition = Layer.gameplay
        overlayNode.zPosition = Layer.overlay
        addChild(conveyorNode)
        addChild(boardNode)
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
        cancelPendingLevelComplete()
        cancelPendingReleaseSequence()
        isSceneAnimating = false
        for node in crateNodes.values {
            node.removeAllActions()
        }
        conveyorNode.enumerateChildNodes(withName: "conveyorCrate") { node, _ in
            node.removeAllActions()
        }
        self.session = session
        layoutIfNeeded()
        refreshFromSession(animated: false)
    }

    private func cancelPendingLevelComplete() {
        removeAction(forKey: Self.levelCompleteActionKey)
    }

    private func cancelPendingReleaseSequence() {
        removeAction(forKey: Self.releaseSequenceActionKey)
    }

    private func scheduleLevelComplete(after session: GameSession) {
        cancelPendingLevelComplete()
        let guardToken = WinCompletionGuard(session: session)
        let wait = SKAction.wait(forDuration: 1.0)
        let advance = SKAction.run { [weak self] in
            guard let self,
                  let currentSession = self.session,
                  guardToken.isStillValid(for: currentSession) else { return }
            self.onLevelComplete?()
        }
        run(SKAction.sequence([wait, advance]), withKey: Self.levelCompleteActionKey)
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
            slot.zPosition = Layer.conveyorSlot
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
                cell.zPosition = Layer.gridCell
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
                node.zPosition = Layer.boardCrate
                let target = gridToScene(x: crate.position.x, y: crate.position.y)
                if animated {
                    node.run(SKAction.move(to: target, duration: 0.2))
                } else {
                    node.position = target
                }
                styleCrateNode(node, crate: crate, isLegal: legalIDs.contains(id))
            } else {
                let node = makeCrateNode(crate: crate, isLegal: legalIDs.contains(id))
                node.zPosition = Layer.boardCrate
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
        body.zPosition = Layer.crateBody
        container.addChild(body)

        let arrow = makeArrowNode(direction: crate.direction, size: size * 0.35)
        arrow.zPosition = Layer.crateArrow
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
        renderConveyorSlots(conveyor.slots, animated: animated)
    }

    private func renderConveyorSlots(_ slots: [ConveyorCrate], animated: Bool = false) {
        conveyorNode.enumerateChildNodes(withName: "conveyorCrate") { node, _ in node.removeFromParent() }

        guard !conveyorSlotNodes.isEmpty else { return }
        let capacity = conveyorSlotNodes.count
        let slotSpacing: CGFloat = 4
        let boardWidth = CGFloat(capacity) * conveyorSlotNodes[0].frame.width + slotSpacing * CGFloat(capacity - 1)
        let slotWidth = (boardWidth - slotSpacing * CGFloat(capacity - 1)) / CGFloat(capacity)

        for (index, crate) in slots.enumerated() {
            let hue = crate.color.displayHue
            let node = SKShapeNode(rectOf: CGSize(width: slotWidth * 0.8, height: 36), cornerRadius: 5)
            node.name = "conveyorCrate"
            node.fillColor = SKColor(red: hue.red, green: hue.green, blue: hue.blue, alpha: 1)
            node.strokeColor = SKColor.white
            node.lineWidth = 1
            node.zPosition = Layer.conveyorCrate
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
        label.zPosition = Layer.overlay
        label.position = CGPoint(x: size.width / 2, y: size.height - 60)
        overlayNode.addChild(label)

        if status == .stuck {
            let hint = SKLabelNode(text: "Restart to try again")
            hint.fontName = "HelveticaNeue"
            hint.fontSize = 16
            hint.fontColor = SKColor(white: 0.8, alpha: 1)
            hint.zPosition = Layer.overlay
            hint.position = CGPoint(x: size.width / 2, y: size.height - 90)
            overlayNode.addChild(hint)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isSceneAnimating, let session, session.state.status == .playing else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: boardNode)
        guard let position = BoardHitTesting.gridPosition(
            at: location,
            boardWidth: session.state.board.width,
            boardHeight: boardHeight,
            cellSize: cellSize
        ) else { return }
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

        let guardToken = WinCompletionGuard(session: session)

        isSceneAnimating = true
        let result = session.attemptRelease(crateID: crateID)

        switch result {
        case .blocked:
            isSceneAnimating = false
            HapticsManager.blocked()
            AudioManager.playBlocked()
            animateBlocked(crateID: crateID)
        case .released(_, _, let finalStatus, let presentation):
            HapticsManager.release()
            AudioManager.playRelease()
            playReleasePresentation(
                crate: crate,
                presentation: presentation,
                finalStatus: finalStatus,
                guardToken: guardToken
            )
        }
    }

    private func playReleasePresentation(
        crate: Crate,
        presentation: ReleasePresentation,
        finalStatus: GameStatus,
        guardToken: WinCompletionGuard
    ) {
        cancelPendingReleaseSequence()

        let finish: () -> Void = { [weak self] in
            guard let self,
                  let session = self.session,
                  guardToken.isStillValid(for: session) else { return }

            self.refreshFromSession(animated: false)
            self.isSceneAnimating = false

            switch finalStatus {
            case .won:
                HapticsManager.completion()
                AudioManager.playWin()
                self.scheduleLevelComplete(after: session)
            case .stuck:
                HapticsManager.failure()
                AudioManager.playStuck()
            case .playing:
                break
            }
        }

        let afterSlide: () -> Void = { [weak self] in
            guard let self,
                  let session = self.session,
                  guardToken.isStillValid(for: session) else { return }

            self.renderConveyorSlots(presentation.conveyorAfterLanding)
            AudioManager.playConveyorLanding()
            HapticsManager.conveyorLanding()

            if presentation.matchSteps.isEmpty {
                finish()
            } else {
                self.playMatchSteps(
                    steps: presentation.matchSteps,
                    slots: presentation.conveyorAfterLanding,
                    stepIndex: 0,
                    guardToken: guardToken,
                    completion: finish
                )
            }
        }

        animateSlideOffBoard(crate: crate, guardToken: guardToken, completion: afterSlide)
    }

    private func playMatchSteps(
        steps: [MatchClearStep],
        slots: [ConveyorCrate],
        stepIndex: Int,
        guardToken: WinCompletionGuard,
        completion: @escaping () -> Void
    ) {
        guard stepIndex < steps.count else {
            completion()
            return
        }

        let step = steps[stepIndex]
        let readableHold: TimeInterval = 0.2
        let clearDuration: TimeInterval = 0.15

        let hold = SKAction.wait(forDuration: readableHold)
        let matchCue = SKAction.run { [weak self] in
            guard let self,
                  let session = self.session,
                  guardToken.isStillValid(for: session) else { return }
            AudioManager.playMatch()
            HapticsManager.match()
        }

        let clear = SKAction.run { [weak self] in
            guard let self,
                  let session = self.session,
                  guardToken.isStillValid(for: session) else { return }

            self.animateConveyorClear(range: step.range, duration: clearDuration) { [weak self] in
                guard let self,
                      let session = self.session,
                      guardToken.isStillValid(for: session) else { return }

                var remaining = slots
                for priorStep in steps.prefix(stepIndex + 1) {
                    remaining.removeSubrange(priorStep.range)
                }
                self.renderConveyorSlots(remaining)

                self.playMatchSteps(
                    steps: steps,
                    slots: slots,
                    stepIndex: stepIndex + 1,
                    guardToken: guardToken,
                    completion: completion
                )
            }
        }

        run(
            SKAction.sequence([hold, matchCue, clear]),
            withKey: Self.releaseSequenceActionKey
        )
    }

    private func animateConveyorClear(
        range: Range<Int>,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        let crateNodes = conveyorNode.children
            .filter { $0.name == "conveyorCrate" }
            .sorted { $0.position.x < $1.position.x }

        guard range.upperBound <= crateNodes.count else {
            completion()
            return
        }

        let targets = Array(crateNodes[range])
        guard !targets.isEmpty else {
            completion()
            return
        }

        var remaining = targets.count
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let remove = SKAction.removeFromParent()

        for node in targets {
            node.run(SKAction.sequence([fadeOut, remove])) {
                remaining -= 1
                if remaining == 0 {
                    completion()
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

    private func animateSlideOffBoard(
        crate: Crate,
        guardToken: WinCompletionGuard,
        completion: @escaping () -> Void
    ) {
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
        ])) { [weak self] in
            guard let self,
                  let session = self.session,
                  guardToken.isStillValid(for: session) else { return }
            self.crateNodes.removeValue(forKey: crate.id)
            completion()
        }
    }
}
