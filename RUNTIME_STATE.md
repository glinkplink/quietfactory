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
- `isStuck` covers empty-conveyor deadlocks via dedicated test fixture
- 13 hand-authored levels; all verified solvable via test-only `LevelSolver` in CI
- `onb-3` teaches blocked-path release order (starts `.playing`, blocked crate gives feedback)
- `hard-1` combines spatial column blocking with interleaved conveyor sequencing
- Win overlay rests ~1s before auto-advance; stale auto-advance cancelled on restart/level change; stuck overlay copy is location-neutral
- `GameEngineTests` + catalog solvability tests
- **GitHub iOS CI passing** on the latest implementation tree; PR checks are authoritative for the exact SHA
- Review-fix pass complete: onboarding blocking tutorial, spatial hard-1, completion pause, overlay copy, test-only solver

## Active scope

Prototype gray-box MVP only.

## Not active yet

- campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store

## Immediate success criterion

Human playtest: understand rules quickly, satisfying interactions, meaningful conveyor sequencing, voluntary replay.

## Current blockers

None engineering-side. **Human playtest** is the prototype gate.

## Next checkpoint

Human playtest on device/simulator (prototype gate).
