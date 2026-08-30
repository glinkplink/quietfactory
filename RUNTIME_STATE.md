# Quiet Factory — Runtime State
Last updated: 2026-08-30

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

Do **not** use this file for HEAD-SHA bookkeeping or review certification. Machine gate results (`QF_GROK_*`, `QF_FINAL_*`, `QF_PLAYTEST_READY`) belong in PR comments, automation output, or commit-adjacent artifacts — not here.

---

## Current phase

**Phase 1 — Gray-box MVP milestone (PR #1) + automation validation**

## Current objective

PR #7 is on `main` and synced into PR #1. Orchestrator is **ENABLED** with Draft opened, PR pushed, and `ios-ci.yml` Success. This head patches the CI-handoff hole (subscribe-and-exit dropped Kimi). Do **not** claim the chain is validated until a CI-success run actually invokes `pre-playtest-reviewer`.

Do **not** start new gameplay changes on `main` during this pass.

## Current status

### Milestone (PR #1)

- **PR #1** (`agent/mvp-nightly` → `main`) remains the current **gray-box prototype milestone**.
- Draft PR: *MVP: Quiet Factory gray-box prototype*.
- Deterministic `GameCore` + `GameEngine` (SpriteKit-independent)
- Gray-box portrait UI with corrected grid Y-axis (model north = visual up), explicit SpriteKit zPosition layering for crates over grid cells
- `isStuck` covers empty-conveyor deadlocks via dedicated test fixture
- 13 hand-authored levels; all verified solvable via test-only `LevelSolver` in CI (plus explicit unsolvable fixture negative test)
- `onb-3` teaches blocked-path release order (starts `.playing`, blocked crate gives feedback)
- `hard-1` combines spatial column blocking with interleaved conveyor sequencing
- Win overlay rests ~1s before auto-advance; stale auto-advance cancelled on restart/level change; stuck overlay copy is location-neutral
- **P1 pre-playtest fixes (same PR):** board tap hit-testing rejects off-board taps; release presentation trace (slide → land → readable match → clear) with atomic `GameEngine.apply`; unsolvable `LevelSolver` fixture; `QuietFactoryUITests` launch smoke + `GameScene` zPosition unit test
- `GameEngineTests` + catalog solvability tests + presentation-trace tests
- **GitHub iOS CI** is authoritative for the exact SHA; local Linux cannot run `xcodebuild`
- iOS CI publishes a downloadable `QuietFactory-Simulator-<sha>` zip (7-day retention) for Appetize.io browser playtest without a Mac

### Automation

| Item | Status |
|------|--------|
| `docs/AUTOMATION_PROTOCOL.md` | **Locked** + CI-handoff correction (workflow-success wake-up) on this PR |
| `.cursor/BUGBOT.md` review rubric | **Locked** |
| `architecture-escalator` project subagent | **Documented** |
| `implementation-worker` project subagent | **Documented** |
| `pre-playtest-reviewer` project subagent | **Documented** — bound to `kimi-k3-high`; cost-disciplined prompt + child-result contract from PR #7 |
| `QF — Milestone Orchestrator` | **Configured externally** — **ENABLED** — Draft opened, PR pushed, `ios-ci.yml` Success |
| `QF — Next Milestone Starter` | **Configured externally** — **DISABLED** |

No additional automation components are planned. The locked two-automation architecture is unchanged.

### Empirical validation — three separate failures

#### 1. Routing/model smoke (cost)

- Kimi K3 High **routing/model binding was observed to work** during an earlier smoke/final-review attempt.
- That attempted final-review run was operationally too expensive, consuming roughly **~2% observed usage**.
- Treat ~2% as an **observed operational fact**, not an estimated token count.
- Therefore: **model routing passed**; **reviewer cost discipline is NOT yet validated**.
- Cost-disciplined prompt/docs from PR #7 address that defect.

#### 2. End-to-end orchestrator provenance (PR #1 head `abb46647…`)

- PR #1 head `abb46647f2e18de8f55ee909c6ad846f54eb19ac` reached exact-head CI PASS.
- The orchestrator posted `QF_GROK_STATUS: PASS`, `QF_FINAL_STATUS: PASS`, and `QF_PLAYTEST_READY` for that SHA, describing an “independent final reviewer” pass.
- Final-review **provenance was not adequately established** (insufficient evidence that the configured `pre-playtest-reviewer` Kimi child was actually invoked and returned that result).
- Do **not** claim definitively that Cursor never launched a child if execution telemetry cannot prove that negative. The defect is that the orchestrator was permitted to certify PASS without possessing/verifying child-result provenance.
- Therefore this does **NOT** count as successful end-to-end Kimi final-gate validation.
- `QF_PLAYTEST_READY` on that SHA is **INVALID / stale for automation-validation purposes**. Do not rewrite or delete the historical GitHub marker merely to hide the failed validation; treat it as invalid/stale for protocol purposes.
- Human playtest remains **blocked / deferred**.

#### 3. CI wait / no Kimi wake-up (PR #1 head `b7dd80a…`)

- Post-enable candidate `b7dd80a1e6b770105832f1ce054c63ae3c46b5b1` got a Grok run ([bc-af922655](https://cursor.com/agents/bc-af922655-6799-47ab-bb51-b045758bdc21)) that ended in 3m52s after intending to wait for iOS CI.
- Exact-head `iOS CI` later succeeded (push + PR runs). No `pre-playtest-reviewer` child ran.
- Root cause: automations with only Draft opened / PR pushed do not resume when CI completes; ending the turn finishes the run.
- Fix: same orchestrator, additional `ios-ci.yml` Success trigger; protocol forbids subscribe-and-exit.

### Human playtest

- Human playtest remains **intentionally deferred** until a provenance-backed `QF_PLAYTEST_READY` exists for a fresh exact head after cost-disciplined Kimi validation.
- The four machine-detectable P1 items (board hit-testing, release presentation trace, unsolvable solver fixture, UI/smoke tests) are implemented on this PR; they do **not** authorize playtest by themselves.
- Appetize time is scarce (~30 free minutes total); do not consume it for routine validation.
- A green CI run, Grok PASS, or a parent comment alone does **not** authorize human playtesting.
- Seeing `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` in a parent comment is **not itself evidence** that the independent reviewer executed.

## Active scope

- One fresh exact-head chain after the CI-handoff protocol patch: Grok `WAITING_CI` then `ios-ci.yml` success → observed `pre-playtest-reviewer` child
- PR #1 remains open as the gray-box milestone (fixes via same PR only)

## Not active yet

- New gameplay features beyond PR #1 milestone scope
- Campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store
- Procedural generation (blocked until gray-box loop passes human validation)
- Re-enabling `QF — Next Milestone Starter` (blocked until provenance-backed playtest PASS and human merge of PR #1)

## Immediate success criterion

Corrective docs are on `main` (PR #7) → synced into PR #1 → CI-handoff trigger + protocol on the candidate → Grok `WAITING_CI` then `ios-ci.yml` success invokes `pre-playtest-reviewer` with a validated child contract — **before** human playtest or enabling `QF — Next Milestone Starter`.

## Current blockers

- Cost discipline not yet validated on a production candidate.
- Final-review provenance rule not yet validated end-to-end.
- CI-handoff (Kimi wake on `ios-ci.yml` success) not yet validated.
- Stale/invalid `QF_PLAYTEST_READY` on `abb46647…` must not be treated as playtest authorization.

## Next checkpoint

1. Sync/merge latest `main` (PR #7) into PR #1 — **done** (`b74d386`).
2. Re-enable **only** `QF — Milestone Orchestrator` — **done**.
3. Add `ios-ci.yml` Success trigger on that same automation — **done** (branch filter optional; protocol no-ops non-milestone SHAs).
4. Push this CI-handoff protocol patch — **this commit**.
5. Validate: Grok `PASS` + `WAITING_CI`, then CI-success run invokes `pre-playtest-reviewer` with a validated child contract.
6. Keep `QF — Next Milestone Starter` disabled.
7. Only after provenance-backed `QF_PLAYTEST_READY` may human playtest proceed.
