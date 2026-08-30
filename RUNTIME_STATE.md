# Quiet Factory — Runtime State
Last updated: 2026-08-30

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

Do **not** use this file for HEAD-SHA bookkeeping or review certification. Machine gate results (`QF_GROK_*`, `QF_SOL_*`, `QF_PLAYTEST_READY`) belong in PR comments, automation output, or commit-adjacent artifacts — not here.

---

## Current phase

**Phase 1 — Gray-box MVP milestone (PR #1) + automation infrastructure**

## Current objective

1. Install and validate the development automation pipeline documented in `docs/AUTOMATION_PROTOCOL.md`.
2. Defer further human playtest until the automated pre-playtest gate is operational.

Do **not** start new gameplay changes on `main` during this pass.

## Current status

### Milestone (PR #1)

- **PR #1** (`agent/mvp-nightly` → `main`) remains the current **gray-box prototype milestone**.
- Draft PR: *MVP: Quiet Factory gray-box prototype*.
- Deterministic `GameCore` + `GameEngine` (SpriteKit-independent)
- Gray-box portrait UI with corrected grid Y-axis (model north = visual up), explicit SpriteKit zPosition layering for crates over grid cells
- `isStuck` covers empty-conveyor deadlocks via dedicated test fixture
- 13 hand-authored levels; all verified solvable via test-only `LevelSolver` in CI
- `onb-3` teaches blocked-path release order (starts `.playing`, blocked crate gives feedback)
- `hard-1` combines spatial column blocking with interleaved conveyor sequencing
- Win overlay rests ~1s before auto-advance; stale auto-advance cancelled on restart/level change; stuck overlay copy is location-neutral
- `GameEngineTests` + catalog solvability tests
- **GitHub iOS CI passing** on the latest implementation tree; PR checks are authoritative for the exact SHA
- iOS CI publishes a downloadable `QuietFactory-Simulator-<sha>` zip (7-day retention) for Appetize.io browser playtest without a Mac

### Automation

| Item | Status |
|------|--------|
| `docs/AUTOMATION_PROTOCOL.md` | **Documented** |
| `.cursor/BUGBOT.md` review rubric | **Documented** |
| `architecture-escalator` project subagent (`.cursor/agents/`) | **Documented** — read-only Grok 4.6; not configured as automation |
| Grok PR reviewer automation (`QF — Grok Milestone Reviewer`) | **Configured externally** |
| Composer review-fixer automation | **Planned** — not configured |
| Sol pre-playtest gate | **Planned** — not configured |
| Playtest-fail fixer | **Planned** — not configured |
| Post-merge next-milestone automation | **Planned** — not configured |

### Human playtest

- Human playtest is **intentionally deferred** until the automated pre-playtest gate (`QF_PLAYTEST_READY`) is operational.
- Appetize time is scarce (~30 free minutes total); do not consume it for routine validation.
- A green CI run or informal review alone does **not** authorize human playtesting.

## Active scope

- Automation infrastructure and operating-protocol docs
- PR #1 remains open as the gray-box milestone (fixes via same PR only)

## Not active yet

- New gameplay features beyond PR #1 milestone scope
- Campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store
- Procedural generation (blocked until gray-box loop passes human validation)

## Immediate success criterion

The automation chain (CI → Grok review → Composer fixes → Sol gate → playtest authorization) is **configured, validated against PR #1, and documented** before another human playtest is scheduled.

## Current blockers

None for documentation. Remaining automation components (Composer fixer, Sol gate, playtest-fail fixer, post-merge automation) are not yet implemented.

## Next checkpoint

Validate the full automation chain against PR #1; only then decide whether PR #1 qualifies for another human playtest.
