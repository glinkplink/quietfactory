import XCTest
@testable import QuietFactory

final class GameEngineTests: XCTestCase {
    private func makeBoard(
        width: Int = 5,
        height: Int = 5,
        crates: [(Int, Int, MoveDirection, CrateColor)]
    ) -> BoardState {
        var nextID = 1
        let crateList = crates.map { x, y, dir, color -> Crate in
            let id = CrateID(rawValue: nextID)
            nextID += 1
            return Crate(id: id, position: GridPosition(x: x, y: y), direction: dir, color: color)
        }
        return BoardState(width: width, height: height, crates: crateList)
    }

    private func makeState(board: BoardState, capacity: Int = 5) -> GameState {
        GameState(board: board, conveyorCapacity: capacity, matchSize: 3)
    }

    func testPathBlocking() {
        let board = makeBoard(width: 5, height: 4, crates: [
            (0, 1, .east, .red),
            (0, 2, .east, .yellow),
            (2, 2, .west, .blue)
        ])
        let state = makeState(board: board)
        let clearCrate = state.board.crates.values.first { $0.color == .red }!
        let blockedCrate = state.board.crates.values.first { $0.color == .blue }!

        XCTAssertTrue(GameEngine.hasClearExitPath(for: clearCrate, on: board))
        XCTAssertFalse(GameEngine.hasClearExitPath(for: blockedCrate, on: board))
    }

    func testLegalAndIllegalReleases() {
        let board = makeBoard(width: 5, height: 4, crates: [
            (0, 1, .east, .red),
            (0, 2, .east, .yellow),
            (2, 2, .west, .blue)
        ])
        let state = makeState(board: board)
        let legalCrate = state.board.crates.values.first { $0.color == .red }!
        let blockedCrate = state.board.crates.values.first { $0.color == .blue }!

        XCTAssertTrue(GameEngine.isReleaseValid(crateID: legalCrate.id, in: state))
        XCTAssertFalse(GameEngine.isReleaseValid(crateID: blockedCrate.id, in: state))

        XCTAssertEqual(GameEngine.legalMoves(in: state).count, 1)
    }

    func testOccupancyUpdatesOnRelease() {
        let board = makeBoard(width: 3, height: 3, crates: [(1, 1, .north, .red)])
        var state = makeState(board: board)
        let crateID = state.board.crates.values.first!.id

        let result = try! GameEngine.apply(move: Move(crateID: crateID), to: state)
        state = result.state

        XCTAssertTrue(state.board.isEmpty)
        XCTAssertEqual(state.conveyor.slots.count, 1)
        XCTAssertEqual(state.conveyor.slots[0].color, .red)
    }

    func testConveyorCapacityBlocksRelease() {
        let board = makeBoard(width: 3, height: 3, crates: [(0, 0, .south, .red)])
        var state = makeState(board: board, capacity: 2)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 100), color: .yellow),
            ConveyorCrate(id: CrateID(rawValue: 101), color: .purple)
        ]

        let crateID = state.board.crates.values.first!.id
        XCTAssertFalse(GameEngine.isReleaseValid(crateID: crateID, in: state))
        XCTAssertThrowsError(try GameEngine.apply(move: Move(crateID: crateID), to: state)) { error in
            XCTAssertEqual(error as? MoveFailure, .conveyorFull)
        }
    }

    func testMatchingClearsThreeSameColor() {
        let board = makeBoard(width: 1, height: 1, crates: [])
        var state = makeState(board: board)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 1), color: .green),
            ConveyorCrate(id: CrateID(rawValue: 2), color: .green),
            ConveyorCrate(id: CrateID(rawValue: 3), color: .green)
        ]

        let cleared = GameEngine.resolveMatches(on: &state)
        XCTAssertEqual(cleared.map(\.color), [.green])
        XCTAssertTrue(state.conveyor.slots.isEmpty)
    }

    func testMatchResolutionOrderingIsLeftToRight() {
        let board = makeBoard(width: 1, height: 1, crates: [])
        var state = makeState(board: board)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 1), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 2), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 3), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 4), color: .blue),
            ConveyorCrate(id: CrateID(rawValue: 5), color: .blue)
        ]

        let cleared = GameEngine.resolveMatches(on: &state)
        XCTAssertEqual(cleared.map(\.color), [.red])
        XCTAssertEqual(state.conveyor.slots.map(\.color), [.blue, .blue])
    }

    func testWinDetection() {
        let board = makeBoard(width: 3, height: 3, crates: [])
        var state = makeState(board: board)
        GameEngine.evaluateOutcome(&state)
        XCTAssertEqual(state.status, .won)
    }

    func testStuckDetectionConveyorFull() {
        let board = makeBoard(width: 3, height: 3, crates: [(1, 1, .north, .red)])
        var state = makeState(board: board, capacity: 3)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 10), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 11), color: .blue),
            ConveyorCrate(id: CrateID(rawValue: 12), color: .green)
        ]
        GameEngine.evaluateOutcome(&state)
        XCTAssertEqual(state.status, .stuck)
    }

    func testStuckDetectionEmptyConveyorDeadlock() {
        let level = LevelDefinition(
            id: "test-deadlock",
            name: "Deadlock Fixture",
            width: 4,
            height: 3,
            crates: [
                CrateDefinition(x: 1, y: 1, direction: .east, color: .green),
                CrateDefinition(x: 2, y: 1, direction: .west, color: .green)
            ],
            matchSize: 3,
            conveyorCapacity: 5,
            category: .normal
        )
        var state = level.makeInitialState()
        GameEngine.evaluateOutcome(&state)
        XCTAssertEqual(state.status, .stuck)
        XCTAssertTrue(state.conveyor.slots.isEmpty)
    }

    func testOnb3StartsPlayingWithBlockedCrate() {
        let level = LevelCatalog.onboarding[2]
        var state = level.makeInitialState()
        GameEngine.evaluateOutcome(&state)
        XCTAssertEqual(state.status, .playing)

        let blocked = state.board.crates.values.first { $0.position == GridPosition(x: 2, y: 0) }!
        let blocker = state.board.crates.values.first { $0.position == GridPosition(x: 2, y: 1) }!
        XCTAssertFalse(GameEngine.hasClearExitPath(for: blocked, on: state.board))
        XCTAssertTrue(GameEngine.hasClearExitPath(for: blocker, on: state.board))
    }

    func testOnb3IsSolvable() {
        let level = LevelCatalog.onboarding[2]
        XCTAssertTrue(LevelSolver.canWin(level: level))
    }

    func testHard1HasSpatialDependency() {
        let level = LevelCatalog.difficult[0]
        var state = level.makeInitialState()
        GameEngine.evaluateOutcome(&state)

        let blockedOrange = state.board.crates.values.first { $0.position == GridPosition(x: 1, y: 1) }!
        XCTAssertFalse(GameEngine.isReleaseValid(crateID: blockedOrange.id, in: state))

        let bottomPurple = state.board.crates.values.first { $0.position == GridPosition(x: 1, y: 2) }!
        state = try! GameEngine.apply(move: Move(crateID: bottomPurple.id), to: state).state
        XCTAssertTrue(GameEngine.isReleaseValid(crateID: blockedOrange.id, in: state))
    }

    func testRestartResetsState() {
        let level = LevelCatalog.onboarding[0]
        var state = level.makeInitialState()
        let crateID = state.board.crates.values.first!.id
        state = try! GameEngine.apply(move: Move(crateID: crateID), to: state).state

        var restarted = GameEngine.restart(level: level)
        GameEngine.evaluateOutcome(&restarted)
        XCTAssertEqual(restarted.board.crates.count, 3)
        XCTAssertTrue(restarted.conveyor.slots.isEmpty)
        XCTAssertEqual(restarted.status, .playing)
    }

    func testDeterministicReplay() {
        let level = LevelDefinition(
            id: "test-replay",
            name: "Replay",
            width: 5,
            height: 3,
            crates: [
                CrateDefinition(x: 0, y: 1, direction: .east, color: .red),
                CrateDefinition(x: 4, y: 2, direction: .west, color: .blue)
            ],
            matchSize: 3,
            conveyorCapacity: 5,
            category: .normal
        )
        let initial = level.makeInitialState()
        let moves = GameEngine.legalMoves(in: initial)
        guard moves.count >= 2 else {
            XCTFail("Expected at least two legal moves for replay test level")
            return
        }

        let sequence = [
            Move(crateID: moves[0]),
            Move(crateID: moves[1])
        ]

        let first = try! GameEngine.replay(level: level, moves: sequence)
        let second = try! GameEngine.replay(level: level, moves: sequence)

        XCTAssertEqual(first.board.crates.count, second.board.crates.count)
        XCTAssertEqual(first.conveyor.slots, second.conveyor.slots)
        XCTAssertEqual(first.status, second.status)
    }

    func testReleaseTriggersMatchAndWin() {
        let level = LevelDefinition(
            id: "test-win",
            name: "Test Win",
            width: 3,
            height: 3,
            crates: [
                CrateDefinition(x: 1, y: 1, direction: .north, color: .red)
            ],
            matchSize: 3,
            conveyorCapacity: 5,
            category: .onboarding
        )

        var state = level.makeInitialState()
        // Pre-fill conveyor with two reds so third release clears all
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 100), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 101), color: .red)
        ]

        let crateID = state.board.crates.values.first!.id
        state = try! GameEngine.apply(move: Move(crateID: crateID), to: state).state

        XCTAssertEqual(state.status, .won)
        XCTAssertTrue(state.board.isEmpty)
        XCTAssertTrue(state.conveyor.slots.isEmpty)
    }

    func testLevelCatalogCounts() {
        XCTAssertEqual(LevelCatalog.onboarding.count, 3)
        XCTAssertEqual(LevelCatalog.normal.count, 5)
        XCTAssertEqual(LevelCatalog.sequencing.count, 3)
        XCTAssertEqual(LevelCatalog.difficult.count, 2)
        XCTAssertEqual(LevelCatalog.all.count, 13)
    }

    func testCatalogLevelsAreSolvable() {
        for level in LevelCatalog.all {
            XCTAssertTrue(LevelSolver.canWin(level: level), "Expected solvable level: \(level.id)")
        }
    }

    func testWinCompletionGuardStillValidForUnchangedSession() {
        let session = GameSession(level: LevelCatalog.onboarding[0])
        let token = WinCompletionGuard(session: session)
        XCTAssertTrue(token.isStillValid(for: session))
    }

    func testWinCompletionGuardInvalidatesOnRestart() {
        let session = GameSession(level: LevelCatalog.onboarding[0])
        let token = WinCompletionGuard(session: session)
        session.restart()
        XCTAssertFalse(token.isStillValid(for: session))
    }

    func testWinCompletionGuardInvalidatesOnDifferentSession() {
        let first = GameSession(level: LevelCatalog.onboarding[0])
        let token = WinCompletionGuard(session: first)
        let second = GameSession(level: LevelCatalog.onboarding[1])
        XCTAssertFalse(token.isStillValid(for: second))
    }

    // MARK: - Board hit testing

    func testBoardHitTestingNegativeCoordinatesReturnNil() {
        let cellSize: CGFloat = 44
        XCTAssertNil(BoardHitTesting.gridPosition(
            at: CGPoint(x: -0.5, y: 22),
            boardWidth: 5,
            boardHeight: 4,
            cellSize: cellSize
        ))
        XCTAssertNil(BoardHitTesting.gridPosition(
            at: CGPoint(x: 22, y: -0.5),
            boardWidth: 5,
            boardHeight: 4,
            cellSize: cellSize
        ))
    }

    func testBoardHitTestingJustOutsideRightAndTopReturnNil() {
        let cellSize: CGFloat = 44
        let width = 5
        let height = 4
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

    func testBoardHitTestingSceneOriginMapsToTopRowModelCell() {
        let cellSize: CGFloat = 44
        let height = 5
        let position = BoardHitTesting.gridPosition(
            at: CGPoint(x: cellSize / 2, y: cellSize / 2),
            boardWidth: 5,
            boardHeight: height,
            cellSize: cellSize
        )
        XCTAssertEqual(position, GridPosition(x: 0, y: height - 1))
    }

    // MARK: - Release presentation trace

    func testApplyRemainsAtomicWithLandingTrace() {
        let board = makeBoard(width: 3, height: 3, crates: [(1, 1, .north, .red)])
        var state = makeState(board: board)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 100), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 101), color: .red)
        ]
        let priorSlots = state.conveyor.slots
        let crateID = state.board.crates.values.first!.id

        let result = try! GameEngine.apply(move: Move(crateID: crateID), to: state)

        XCTAssertEqual(result.state.conveyor.slots, [])
        XCTAssertNotEqual(result.conveyorAfterLanding, result.state.conveyor.slots)
        XCTAssertEqual(result.conveyorAfterLanding, priorSlots + [ConveyorCrate(id: crateID, color: .red)])
        XCTAssertEqual(result.conveyorAfterLanding.last?.id, crateID)
    }

    func testMatchStepsEmptyWhenNoMatchAfterLanding() {
        let board = makeBoard(width: 3, height: 3, crates: [(1, 1, .north, .blue)])
        var state = makeState(board: board)
        let crateID = state.board.crates.values.first!.id

        let result = try! GameEngine.apply(move: Move(crateID: crateID), to: state)

        XCTAssertTrue(result.matchSteps.isEmpty)
        XCTAssertEqual(result.state.conveyor.slots.count, 1)
    }

    func testOneMatchStepCoversLandedConveyorRange() {
        let crateOnBoard = makeBoard(width: 3, height: 3, crates: [(1, 1, .north, .red)])
        var releaseState = makeState(board: crateOnBoard)
        releaseState.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 1), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 2), color: .red)
        ]
        let crateID = releaseState.board.crates.values.first!.id
        let result = try! GameEngine.apply(move: Move(crateID: crateID), to: releaseState)

        XCTAssertEqual(result.matchSteps.count, 1)
        XCTAssertEqual(result.matchSteps[0].range, 0..<3)
        XCTAssertEqual(result.matchSteps[0].color, .red)

        var replay = result.conveyorAfterLanding
        replay.removeSubrange(result.matchSteps[0].range)
        XCTAssertEqual(replay, result.state.conveyor.slots)
    }

    func testMatchStepsLeftToRightOrdering() {
        let board = makeBoard(width: 1, height: 1, crates: [])
        var state = makeState(board: board)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 1), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 2), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 3), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 4), color: .blue),
            ConveyorCrate(id: CrateID(rawValue: 5), color: .blue)
        ]

        let steps = GameEngine.resolveMatches(on: &state)
        XCTAssertEqual(steps.count, 1)
        XCTAssertEqual(steps[0].range, 0..<3)
        XCTAssertEqual(state.conveyor.slots.map(\.color), [.blue, .blue])
    }

    func testReplayingMatchStepsEqualsFinalConveyor() {
        let board = makeBoard(width: 3, height: 3, crates: [(1, 1, .north, .red)])
        var state = makeState(board: board)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 100), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 101), color: .red)
        ]
        let crateID = state.board.crates.values.first!.id
        let result = try! GameEngine.apply(move: Move(crateID: crateID), to: state)

        var replay = result.conveyorAfterLanding
        for step in result.matchSteps {
            replay.removeSubrange(step.range)
        }
        XCTAssertEqual(replay, result.state.conveyor.slots)
    }

    func testSessionAttemptReleaseFinalStateWithLandingTrace() {
        let level = LevelDefinition(
            id: "test-session-trace",
            name: "Session Trace",
            width: 5,
            height: 3,
            crates: [
                CrateDefinition(x: 0, y: 2, direction: .north, color: .red),
                CrateDefinition(x: 2, y: 2, direction: .north, color: .red),
                CrateDefinition(x: 4, y: 2, direction: .north, color: .red)
            ],
            matchSize: 3,
            conveyorCapacity: 5,
            category: .normal
        )
        let session = GameSession(level: level)
        let releaseOrder = session.state.board.crates.values
            .map(\.id)
            .sorted { $0.rawValue < $1.rawValue }

        _ = session.attemptRelease(crateID: releaseOrder[0])
        _ = session.attemptRelease(crateID: releaseOrder[1])
        let result = session.attemptRelease(crateID: releaseOrder[2])

        guard case .released(_, let cleared, let status, let presentation) = result else {
            return XCTFail("Expected released result")
        }
        XCTAssertEqual(status, .won)
        XCTAssertEqual(session.state.status, .won)
        XCTAssertTrue(session.state.conveyor.slots.isEmpty)
        XCTAssertEqual(presentation.conveyorAfterLanding.count, 3)
        XCTAssertEqual(presentation.matchSteps.count, 1)
        XCTAssertEqual(cleared, [.red])
    }

    func testReleaseAnimationPlanNoMatch() {
        let landing = [
            ConveyorCrate(id: CrateID(rawValue: 1), color: .blue)
        ]
        let plan = ReleaseAnimationPlan(conveyorAfterLanding: landing, matchSteps: [])
        XCTAssertEqual(plan.phases, [.slide, .land])
    }

    func testReleaseAnimationPlanWithMatch() {
        let landing = [
            ConveyorCrate(id: CrateID(rawValue: 1), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 2), color: .red),
            ConveyorCrate(id: CrateID(rawValue: 3), color: .red)
        ]
        let steps = [MatchClearStep(range: 0..<3, color: .red)]
        let plan = ReleaseAnimationPlan(conveyorAfterLanding: landing, matchSteps: steps)
        XCTAssertEqual(plan.phases, [.slide, .land, .reveal(range: 0..<3), .clear(range: 0..<3)])
    }

    func testCatalogLevelsAreSolvableExcludesUnsolvableFixture() {
        let unsolvable = LevelDefinition(
            id: "test-unsolvable",
            name: "Unsolvable Fixture",
            width: 4,
            height: 3,
            crates: [
                CrateDefinition(x: 1, y: 1, direction: .east, color: .green),
                CrateDefinition(x: 2, y: 1, direction: .west, color: .green)
            ],
            matchSize: 3,
            conveyorCapacity: 5,
            category: .normal
        )
        XCTAssertFalse(LevelSolver.canWin(level: unsolvable))
    }
}
