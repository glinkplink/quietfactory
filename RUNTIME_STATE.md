# Quiet Factory — Runtime State
Last updated: 2026-08-30

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

Do **not** use this file for HEAD-SHA bookkeeping or review certification. Machine gate results (`QF_GROK_*`, `QF_FINAL_*`, `QF_PLAYTEST_READY`) belong in PR comments, automation output, or commit-adjacent artifacts — not here.

---

## Current phase

**Phase 1 — Gray-box MVP milestone (PR #1) + automation infrastructure**

## Current objective

1. Land and validate the orchestrator/subagent automation architecture documented in `docs/AUTOMATION_PROTOCOL.md`.
2. Defer further human playtest until the orchestrator chain is validated end-to-end.

Do **not** start new gameplay changes on `main` during this pass.

## Current status

### Milestone (PR #1)

- **PR #1** (`agent/mvp-nightly` → `main`) remains the current **gray-box prototype milestone**.
- Draft PR: *MVP: Quiet Factory gray-box prototype*.
- Implementation on that branch includes deterministic `GameCore`, gray-box UI, 13 hand-authored levels, solvability tests, and passing `iOS CI` at last check.

### Automation

| Item | Status |
|------|--------|
| `docs/AUTOMATION_PROTOCOL.md` | **Documented** |
| `.cursor/BUGBOT.md` review rubric | **Documented** |
| `architecture-escalator` project subagent | **Documented** |
| `implementation-worker` project subagent | **Documented** |
| `pre-playtest-reviewer` project subagent | **Documented** — currently bound to `kimi-k3-high`; **not yet validated** in an actual Cloud subagent run |
| `QF — Grok Milestone Orchestrator` (externally configured as `QF — Grok Milestone Reviewer`) | **Configured externally** — instructions should be updated to orchestrator role |
| Separate Composer review-fixer automation | **Abandoned** — generic PR-comment automation chaining is unsuitable; orchestrator delegates to `implementation-worker` |
| Separate final-reviewer top-level automation | **Abandoned** — orchestrator invokes `pre-playtest-reviewer` subagent |
| Post-merge next-milestone automation | **Planned** — not configured |

### Human playtest

- Human playtest is **intentionally deferred** until the orchestrator chain is validated and posts `QF_PLAYTEST_READY` for an exact head.
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

The orchestrator chain (Grok review → `implementation-worker` fixes → exact-head CI → independent `pre-playtest-reviewer` → `QF_PLAYTEST_READY`) is **documented, configured, and validated against PR #1** before another human playtest is scheduled.

## Current blockers

Orchestrator instructions and subagent delegation paths are not yet validated end-to-end against PR #1. Next validation must confirm the Cloud run for `pre-playtest-reviewer` actually used `kimi-k3-high` rather than silently falling back.

## Next checkpoint

Update the external Grok automation to the orchestrator role and validate the full chain against PR #1, including final-reviewer model binding.
