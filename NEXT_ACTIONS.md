# Quiet Factory — Next Actions
Last updated: 2026-08-29

This file is intentionally tactical. Keep only the next meaningful work here.

---

## P0 — Do now

### 1. Verify iOS CI on `agent/mvp-nightly`
- Confirm `QuietFactory.xcodeproj` builds and tests pass on macOS/Xcode
- Fix any compile or test failures without weakening CI

### 2. Playtest gray-box prototype
- Run onboarding → difficult levels on device/simulator
- Tune animation timing and haptic/audio if needed
- Note sequencing puzzles that feel strategic vs annoying

### 3. Address P0/P1 PR review findings
- Fix legitimate defects before expanding scope

---

## P1 — Prototype evaluation

After gray-box is playable and CI-green:

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
