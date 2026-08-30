# Quiet Factory — Runtime State
Last updated: 2026-08-30

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

Do **not** use this file for HEAD-SHA bookkeeping or review certification. Machine gate results (`QF_GROK_*`, `QF_FINAL_*`, `QF_PLAYTEST_READY`) belong in PR comments, automation output, or commit-adjacent artifacts — not here.

---

## Current phase

**Phase 1 — Gray-box MVP milestone (PR #1) + automation validation**

## Current objective

1. Finalize automation docs/config to match externally configured Cursor automations.
2. Validate the orchestrator chain end-to-end before enabling automations or human playtest.

Do **not** start new gameplay changes on `main` during this pass.

## Current status

### Milestone (PR #1)

- **PR #1** (`agent/mvp-nightly` → `main`) remains the current **gray-box prototype milestone**.
- Draft PR: *MVP: Quiet Factory gray-box prototype*.
- Implementation on that branch includes deterministic `GameCore`, gray-box UI, 13 hand-authored levels, solvability tests, and passing `iOS CI` at last check.

### Automation

| Item | Status |
|------|--------|
| `docs/AUTOMATION_PROTOCOL.md` | **Documented** — final reconciliation in progress; locked after merge |
| `.cursor/BUGBOT.md` review rubric | **Documented** |
| `architecture-escalator` project subagent | **Documented** |
| `implementation-worker` project subagent | **Documented** |
| `pre-playtest-reviewer` project subagent | **Documented** — bound to `kimi-k3-high`; **not yet validated** in an actual Cloud subagent run |
| `QF — Milestone Orchestrator` | **Configured externally** — **DISABLED** pending validation |
| `QF — Next Milestone Starter` | **Configured externally** — **DISABLED** pending validation |

No additional automation components are planned before validation.

### Human playtest

- Human playtest is **intentionally deferred** until the orchestrator chain is validated and posts `QF_PLAYTEST_READY` for an exact head.
- Appetize time is scarce (~30 free minutes total); do not consume it for routine validation.
- A green CI run or informal review alone does **not** authorize human playtesting.

## Active scope

- Automation docs/config finalization
- PR #1 remains open as the gray-box milestone (fixes via same PR only)

## Not active yet

- New gameplay features beyond PR #1 milestone scope
- Campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store
- Procedural generation (blocked until gray-box loop passes human validation)

## Immediate success criterion

The orchestrator chain (Grok review → `implementation-worker` fixes → exact-head CI → independent `pre-playtest-reviewer` → `QF_PLAYTEST_READY`) is **validated against PR #1** before human playtest or enabling `QF — Next Milestone Starter`.

## Current blockers

Both external automations remain disabled. Orchestrator/subagent delegation and Kimi model binding are not yet validated in production.

## Next checkpoint

After docs-lock PR merges:

1. Sync latest `main` into PR #1 branch.
2. Enable **only** `QF — Milestone Orchestrator`.
3. Push PR #1 once to trigger the exact-head validation chain.
4. Validate Grok → worker/escalator if needed → CI → Kimi final reviewer.
5. Verify actual model routing/usage (no silent fallback).
6. If `QF_PLAYTEST_READY` succeeds, human playtest.
7. Keep `QF — Next Milestone Starter` disabled until PR #1 passes human playtest and is ready to merge.
