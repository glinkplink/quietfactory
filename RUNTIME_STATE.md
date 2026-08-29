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

- Deterministic `GameCore` + `GameEngine` (SpriteKit-independent)
- Gray-box portrait UI with corrected grid Y-axis (model north = visual up), chevron arrows, tap/release animations
- `isStuck` covers empty-conveyor deadlocks (e.g. `onb-3`)
- 13 hand-authored levels; all except `onb-3` verified solvable via `LevelSolver` in CI
- `GameEngineTests` + catalog solvability tests
- **GitHub `iOS CI` passing** on PR #1 head SHA `d8045bd` (verified 2026-08-29)

## Active scope

Prototype gray-box MVP only.

## Not active yet

- campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store

## Immediate success criterion

Human playtest: understand rules quickly, satisfying interactions, meaningful conveyor sequencing, voluntary replay.

## Current blockers

None engineering-side pending CI on review-fix push.

## Next checkpoint

Green `iOS CI` on PR head after P1 review fixes; then device playtest.
