# Quiet Factory — Runtime State
Last updated: 2026-08-29

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

---

## Current phase

**Phase 0 — Product setup / pre-prototype**

## Current objective

Build the smallest playable prototype capable of testing this question:

> Is the tap → release → conveyor → match → clear loop intrinsically satisfying and strategically interesting enough to justify production?

## Current status

- Product thesis defined
- V1 constraints defined
- Technical direction selected: Swift + SpriteKit + SwiftUI
- Core interaction concept defined
- macOS GitHub Actions `iOS CI` is part of the implementation loop and is the authoritative Apple/Xcode validation
- A SHA is not iOS-verified unless `iOS CI` passes for that commit
- QuietFactory.xcodeproj is not created yet; CI is expected to fail until the project and shared `QuietFactory` scheme exist
- Prototype not yet built
- Visual identity not yet finalized
- No generator/solver implemented
- No App Store assets created

## Active scope

Prototype only:

- deterministic board state
- directional crates/blocks
- tap-to-release
- blocked-path feedback
- conveyor/buffer
- matching
- clearing
- simple win state
- restart
- basic haptics
- basic sound
- several manually-authored test boards

## Not active yet

- campaign
- procedural generation
- solver
- daily puzzle
- stats
- sharing
- level select
- final art
- monetization plumbing
- App Store work

## Immediate success criterion

A tester should:
1. understand the basic rule rapidly;
2. find individual interactions satisfying;
3. encounter meaningful sequencing decisions;
4. voluntarily play another board.

## Current blockers

Xcode project missing. `iOS CI` will fail until bootstrap creates `QuietFactory.xcodeproj` and a shared `QuietFactory` scheme.

## Open questions

1. Exact conveyor capacity?
2. Clear rule: groups of 3, groups by fixed target, or another matching rule?
3. Do crates leave only in cardinal directions?
4. How visibly should future conveyor consequences be telegraphed?
5. Is a hard stuck/fail state desirable, or should undo always make failure recoverable?
6. How many colors produce the best readability/depth balance?
7. Should crates have purely directional arrows or path-specific exits?
8. What board size feels best on one-thumb portrait play?

## Next checkpoint

Playable gray-box prototype.
