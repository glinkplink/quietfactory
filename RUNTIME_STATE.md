# Quiet Factory — Runtime State
Last updated: 2026-08-30

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

Do **not** use this file for HEAD-SHA bookkeeping or review certification. Machine gate results (`QF_GROK_*`, `QF_FINAL_*`, `QF_PLAYTEST_READY`) belong in PR comments, automation output, or commit-adjacent artifacts — not here.

---

## Current phase

**Phase 1 — Gray-box MVP milestone (PR #1) + automation validation**

## Current objective

Land corrective Kimi cost-discipline + final-review provenance docs on `main`, sync into PR #1, then re-validate the orchestrator chain. Do **not** claim the overall automation chain is validated.

Do **not** start new gameplay changes on `main` during this pass.

## Current status

### Milestone (PR #1)

- **PR #1** (`agent/mvp-nightly` → `main`) remains the current **gray-box prototype milestone**.
- Draft PR: *MVP: Quiet Factory gray-box prototype*.
- Implementation on that branch includes deterministic `GameCore`, gray-box UI, 13 hand-authored levels, solvability tests, and passing `iOS CI` at last check.

### Automation

| Item | Status |
|------|--------|
| `docs/AUTOMATION_PROTOCOL.md` | **Documented** — corrective cost/provenance update in this PR |
| `.cursor/BUGBOT.md` review rubric | **Documented** |
| `architecture-escalator` project subagent | **Documented** |
| `implementation-worker` project subagent | **Documented** |
| `pre-playtest-reviewer` project subagent | **Documented** — bound to `kimi-k3-high`; cost-disciplined prompt + child-result contract in this PR |
| `QF — Milestone Orchestrator` | **Configured externally** — **DISABLED** (must stay disabled until this corrective change is merged to `main` and synced into PR #1) |
| `QF — Next Milestone Starter` | **Configured externally** — **DISABLED** |

No additional automation components are planned. Do not enable either Cursor automation as part of this docs pass.

### Empirical validation — two separate failures

#### 1. Routing/model smoke (cost)

- Kimi K3 High **routing/model binding was observed to work** during an earlier smoke/final-review attempt.
- That attempted final-review run was operationally too expensive, consuming roughly **~2% observed usage**.
- Treat ~2% as an **observed operational fact**, not an estimated token count.
- Therefore: **model routing passed**; **reviewer cost discipline is NOT yet validated**.
- Cost-disciplined prompt/docs in this PR address that defect.

#### 2. End-to-end orchestrator provenance (PR #1 head `abb46647…`)

- PR #1 head `abb46647f2e18de8f55ee909c6ad846f54eb19ac` reached exact-head CI PASS.
- The orchestrator posted `QF_GROK_STATUS: PASS`, `QF_FINAL_STATUS: PASS`, and `QF_PLAYTEST_READY` for that SHA, describing an “independent final reviewer” pass.
- Final-review **provenance was not adequately established** (insufficient evidence that the configured `pre-playtest-reviewer` Kimi child was actually invoked and returned that result).
- Do **not** claim definitively that Cursor never launched a child if execution telemetry cannot prove that negative. The defect is that the orchestrator was permitted to certify PASS without possessing/verifying child-result provenance.
- Therefore this does **NOT** count as successful end-to-end Kimi final-gate validation.
- `QF_PLAYTEST_READY` on that SHA is **INVALID / stale for automation-validation purposes**. Do not rewrite or delete the historical GitHub marker merely to hide the failed validation; treat it as invalid/stale for protocol purposes.
- Human playtest remains **blocked / deferred**.

### Human playtest

- Human playtest remains **intentionally deferred** until a provenance-backed `QF_PLAYTEST_READY` exists for a fresh exact head after cost-disciplined Kimi validation.
- Appetize time is scarce (~30 free minutes total); do not consume it for routine validation.
- A green CI run, Grok PASS, or a parent comment alone does **not** authorize human playtesting.
- Seeing `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` in a parent comment is **not itself evidence** that the independent reviewer executed.

## Active scope

- Corrective docs/rules for Kimi cost discipline + fail-closed final-review provenance
- After merge: sync `main` into PR #1 before any orchestrator re-enable
- PR #1 remains open as the gray-box milestone (fixes via same PR only)

## Not active yet

- New gameplay features beyond PR #1 milestone scope
- Campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store
- Procedural generation (blocked until gray-box loop passes human validation)
- Re-enabling `QF — Milestone Orchestrator` (blocked until this corrective change is on PR #1)

## Immediate success criterion

Corrective docs merge to `main` → sync into PR #1 → one fresh exact-head chain with observed `pre-playtest-reviewer` child delegation, validated child contract, cost-disciplined prompt in use, and provenance-backed certification — **before** human playtest or enabling `QF — Next Milestone Starter`.

## Current blockers

- Orchestrator **DISABLED** by design during this corrective pass.
- Cost discipline not yet validated on a production candidate.
- Final-review provenance rule not yet validated end-to-end.
- Stale/invalid `QF_PLAYTEST_READY` on `abb46647…` must not be treated as playtest authorization.

## Next checkpoint

Required post-merge sequence (do **not** run Kimi during this corrective docs PR):

1. Merge this corrective docs/rules PR into `main`.
2. Sync/merge latest `main` into PR #1 (`agent/mvp-nightly`). A docs fix on `main` alone does **not** affect PR #1 until synced — the orchestrator reads `.cursor/agents/pre-playtest-reviewer.md` from the candidate PR branch.
3. Only then re-enable **only** `QF — Milestone Orchestrator`.
4. Produce one new PR #1 head/push.
5. Validate the exact-head chain including observed child delegation and provenance.
6. Keep `QF — Next Milestone Starter` disabled.
7. Only after provenance-backed `QF_PLAYTEST_READY` may human playtest proceed.
