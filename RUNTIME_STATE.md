# Quiet Factory — Runtime State
Last updated: 2026-08-29

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

---

## Current phase

**Phase 1 — Core prototype (gray-box MVP on branch `agent/mvp-nightly`)**

## Current objective

Build the smallest playable prototype capable of testing this question:

> Is the tap → release → conveyor → match → clear loop intrinsically satisfying and strategically interesting enough to justify production?

## Current status

- Xcode project `QuietFactory.xcodeproj` with shared `QuietFactory` scheme
- Deterministic `GameCore` module: board, crates, conveyor, matching, win/stuck, restart, replay
- `GameEngine` pure functions separated from SpriteKit
- Gray-box `GameScene` with tap-to-release, animations, conveyor display, blocked feedback
- SwiftUI portrait shell with level strip and restart control
- Placeholder haptics and system sounds
- 13 hand-authored prototype levels (3 onboarding, 5 normal, 3 sequencing, 2 difficult)
- `GameEngineTests` unit suite (12 tests) — all passing in CI
- **GitHub `iOS CI` passing on PR #1 head SHA `04ee917`** (verified 2026-08-29)

## Active scope

Prototype only (as implemented above).

## Not active yet

- campaign progression UI
- procedural generation
- solver
- daily puzzle
- stats
- sharing
- level select beyond prototype strip
- final art
- undo
- monetization plumbing
- App Store work

## Immediate success criterion

A tester should:
1. understand the basic rule rapidly;
2. find individual interactions satisfying;
3. encounter meaningful sequencing decisions;
4. voluntarily play another board.

## Current blockers

None for engineering. Next gate is human playtest feedback on the gray-box build.

## Open questions

1. Exact conveyor capacity tuning beyond default 5
2. Match rule variants beyond default groups-of-3 consecutive
3. Telegraphing conveyor consequences in UI
4. Hard stuck vs recoverable failure with undo (undo not in MVP)
5. Optimal color count and board size for one-thumb portrait play

## Next checkpoint

Human playtest of gray-box loop on device/simulator; tune animation timing and level teachability if needed.
