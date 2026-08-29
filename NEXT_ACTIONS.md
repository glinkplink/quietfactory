# Quiet Factory — Next Actions
Last updated: 2026-08-29

This file is intentionally tactical. Keep only the next meaningful work here.

---

## P0 — Do now

### 1. Bootstrap project
- Create iOS app project at repo-root `QuietFactory.xcodeproj`
- Add a shared scheme named `QuietFactory`
- SwiftUI app shell
- SpriteKit gameplay scene
- Lock primary orientation to portrait
- Establish folder/module structure
- Add basic unit-test target
- Keep GitHub `iOS CI` in the implementation loop; a SHA is not iOS-verified until that workflow passes

### 2. Implement deterministic core model
- Grid coordinate model
- Crate/block model
- Direction enum
- Occupancy lookup
- Release-validity check
- Move execution
- Conveyor state
- Match/clear logic
- Win-state evaluation

**Important:** Keep game rules independent of SpriteKit.

### 3. Build gray-box renderer
Use placeholder geometry only.

Need:
- grid
- crate/block
- arrow/direction indicator
- conveyor slots
- blocked feedback
- movement animation
- clear animation

### 4. Add tactile feedback
- valid tap haptic
- blocked tap haptic
- conveyor landing haptic
- match haptic
- completion haptic

Use placeholder sounds if necessary.

### 5. Hand-author prototype boards
Create at least:
- 3 trivial onboarding boards
- 5 normal boards
- 3 boards with meaningful conveyor sequencing
- 2 deliberately difficult / near-stuck boards

---

## P1 — Prototype evaluation

After gray-box is playable:

- test without verbal explanation where possible
- record misunderstandings
- measure approximate board completion time
- note whether players restart voluntarily
- identify whether conveyor decisions feel strategic or merely annoying
- tune buffer size and match size
- tune animation timing
- remove unnecessary rules

Do not proceed to procedural generation until the loop passes.

---

## P2 — After prototype passes

- formalize level schema
- implement move-history + undo
- implement solver
- implement seeded generator
- define difficulty metrics
- build seed-validation tests
- design first visual theme

---

## Agent rule

An implementation agent should not jump ahead into P2 simply because P0 is straightforward.

The prototype gate is intentional.

GitHub `iOS CI` is the authoritative Apple/Xcode validation loop. Inspect and fix CI failures; do not suppress tests or weaken the workflow.
