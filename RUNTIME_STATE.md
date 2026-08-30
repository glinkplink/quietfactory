# Quiet Factory — Runtime State
Last updated: 2026-08-30

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

Do **not** use this file for HEAD-SHA bookkeeping or review certification. Machine gate results (`QF_GROK_*`, `QF_FINAL_*`, `QF_PLAYTEST_READY`) belong in PR comments, automation output, or commit-adjacent artifacts — not here.

---

## Current phase

**Phase 1 — Gray-box MVP milestone (PR #1) + automation validation**

## Current objective

End-to-end validation of the actual PR #1 orchestrator chain.

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
| `docs/AUTOMATION_PROTOCOL.md` | **Locked** |
| `.cursor/BUGBOT.md` review rubric | **Locked** |
| `architecture-escalator` project subagent | **Documented** |
| `implementation-worker` project subagent | **Documented** — custom routing smoke test **passed** (discovered and invoked) |
| `pre-playtest-reviewer` project subagent | **Documented** — bound to `kimi-k3-high`; custom routing smoke test **passed** (discovered and invoked) |
| Child model identity | Cursor does **not** expose child `originalModelName`; exact runtime child model identity cannot be directly observed |
| Routing/fallback warnings | **None** during smoke tests |
| `QF — Milestone Orchestrator` | **Configured externally** — **ENABLED** |
| `QF — Next Milestone Starter` | **Configured externally** — **DISABLED** until PR #1 is ready to lead into the next milestone |

No additional automation components are planned. The locked two-automation architecture is unchanged.

### Human playtest

- Human playtest is **intentionally deferred** until the orchestrator chain is validated and posts `QF_PLAYTEST_READY` for an exact head.
- Appetize time is scarce (~30 free minutes total); do not consume it for routine validation.
- A green CI run or informal review alone does **not** authorize human playtesting.

## Active scope

- End-to-end validation of the actual PR #1 orchestrator chain
- PR #1 remains open as the gray-box milestone (fixes via same PR only)

## Not active yet

- New gameplay features beyond PR #1 milestone scope
- Campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store
- Procedural generation (blocked until gray-box loop passes human validation)

## Immediate success criterion

The orchestrator chain (Grok review → `implementation-worker` fixes if needed → exact-head CI → independent `pre-playtest-reviewer` → `QF_PLAYTEST_READY`) is **validated against PR #1** before human playtest or enabling `QF — Next Milestone Starter`.

## Current blockers

Setup is complete. Remaining work is production end-to-end validation of the enabled orchestrator against PR #1. Exact runtime child model identity cannot be observed because Cursor does not expose child `originalModelName`.

## Next checkpoint

1. Push this synced PR #1 head (triggers `QF — Milestone Orchestrator`).
2. Validate Grok exact-head review.
3. If Grok finds P0/P1, validate delegation to `implementation-worker` and same-PR fix loop.
4. Validate exact-head iOS CI handling.
5. Validate final `pre-playtest-reviewer` invocation.
6. Confirm `QF_GROK_HEAD`, `QF_GROK_STATUS`, `QF_FINAL_HEAD`, `QF_FINAL_STATUS`, and `QF_PLAYTEST_READY` all refer to the same exact head.
7. Only then perform human Appetize playtest.
8. On successful human playtest, prepare for manual PR #1 merge and enable `QF — Next Milestone Starter`.
