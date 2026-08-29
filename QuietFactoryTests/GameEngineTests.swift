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
        let board = makeBoard(width: 3, height: 3, crates: [
            (0, 0, .south, .red),
            (1, 0, .south, .blue)
        ])
        var state = makeState(board: board, capacity: 3)
        state.conveyor.slots = [
            ConveyorCrate(id: CrateID(rawValue: 100), color: .yellow),
            ConveyorCrate(id: CrateID(rawValue: 101), color: .purple)
        ]
        GameEngine.evaluateOutcome(&state)
        XCTAssertEqual(state.status, .playing)

        let first = state.board.crates.values.sorted { $0.id.rawValue < $1.id.rawValue }[0]
        state = try! GameEngine.apply(move: Move(crateID: first.id), to: state).state

        let second = state.board.crates.values.first!
        XCTAssertFalse(GameEngine.isReleaseValid(crateID: second.id, in: state))
        XCTAssertThrowsError(try GameEngine.apply(move: Move(crateID: second.id), to: state)) { error in
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
        XCTAssertEqual(cleared, [.green])
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
        XCTAssertEqual(cleared, [.red])
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
        let level = LevelCatalog.onboarding[2]
        var state = level.makeInitialState()
        GameEngine.evaluateOutcome(&state)
        XCTAssertEqual(state.status, .stuck)
        XCTAssertTrue(state.conveyor.slots.isEmpty)
    }

    func testRestartResetsState() {
        let level = LevelCatalog.onboarding[0]
        var state = level.makeInitialState()
        let crateID = state.board.crates.values.first!.id
        state = try! GameEngine.apply(move: Move(crateID: crateID), to: state).state

        let restarted = GameEngine.restart(level: level)
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

    func testCatalogLevelsAreSolvableExceptBlockedTutorial() {
        let winnable = LevelCatalog.all.filter { $0.id != "onb-3" }
        for level in winnable {
            XCTAssertTrue(LevelSolver.canWin(level: level), "Expected solvable level: \(level.id)")
        }
    }

    func testBlockedTutorialIsDeadlock() {
        let level = LevelCatalog.onboarding[2]
        XCTAssertFalse(LevelSolver.canWin(level: level))
        var state = level.makeInitialState()
        GameEngine.evaluateOutcome(&state)
        XCTAssertEqual(state.status, .stuck)
    }
}
