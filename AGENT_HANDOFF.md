# Quiet Factory — Agent Handoff
Last updated: 2026-08-29

Use this file to orient any coding agent before implementation.

---

## Read order

1. `MASTER_PLAN.md`
2. `RUNTIME_STATE.md`
3. `DECISIONS.md`
4. `NEXT_ACTIONS.md`
5. this file

If files conflict:
- `DECISIONS.md` controls durable decisions.
- `RUNTIME_STATE.md` controls current execution state.
- `MASTER_PLAN.md` controls overall product intent.
- explicit current user instruction overrides all repo docs.

---

## Product in one sentence

Quiet Factory is a small premium iOS puzzle game combining tap-away spatial blocking with a limited conveyor/matching buffer, sold upfront with no ads or freemium systems.

---

## Current mission

Build a gray-box prototype that tests whether the core loop is actually fun.

Do not optimize for production completeness yet.

---

## Coding constraints

- Swift + SpriteKit + SwiftUI
- deterministic game logic
- separate model from rendering
- no networking
- no account system
- no ad SDK
- no IAP
- no analytics dependency in prototype
- no speculative abstraction
- no architecture astronautics
- prefer small testable types
- add tests around game-rule edge cases

---

## Prototype mechanics

Minimum conceptual state:

### Board
- 2D grid
- occupied/unoccupied cells
- crates/blocks with a release direction

### Release
A crate can move only if the path between it and its board exit is clear according to the current rules.

### Conveyor
Released crate enters a fixed-capacity holding/conveyor area.

### Match
Compatible crates form a clearable group.

Initial default for prototype:
- match size: 3
- buffer capacity: 5

These are **tuning defaults, not durable decisions**.

### Outcome
- board clears = win
- full conveyor with no valid clear may create a stuck/fail state
- restart required
- undo can be added after base interaction works

---

## Implementation preference

Start with the model.

Suggested initial data structures:

- `GridPosition`
- `MoveDirection`
- `CrateID`
- `Crate`
- `BoardState`
- `ConveyorState`
- `GameState`
- `Move`
- `MoveResult`

Suggested pure operations:

- `isReleaseValid(crateID:)`
- `legalMoves()`
- `apply(move:)`
- `resolveMatches()`
- `isWin`
- `isStuck`

The SpriteKit scene should observe/apply model state, not own game truth.

---

## AI-agent guardrails

Do not:
- add monetization
- add backend
- add unnecessary dependencies
- invent progression systems
- generate elaborate art
- create character/story systems
- redesign the core product without documenting the reason
- silently change product constraints
- build generator/solver before the base loop is playable

If a product assumption appears wrong, flag it in runtime docs rather than coding around it.

---

## Required handoff after each meaningful implementation step

Update:
- `RUNTIME_STATE.md`
- `NEXT_ACTIONS.md`

Update `DECISIONS.md` only for actual durable decisions.

Include:
- what changed
- what is now working
- known bugs
- unanswered questions
- exact next action
