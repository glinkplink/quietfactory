# Quiet Factory — Runtime State
Last updated: 2026-08-31

This file is the short-lived operational truth for the project.

Do not turn this into product canon. Durable decisions belong in `DECISIONS.md`; the complete product thesis belongs in `MASTER_PLAN.md`.

Do **not** use this file for HEAD-SHA bookkeeping or review certification. Machine gate results (`QF_GROK_*`, `QF_FINAL_*`, `QF_PLAYTEST_READY`) belong in PR comments, automation output, or commit-adjacent artifacts — not here.

---

## Current phase

**Phase 1 — Gray-box MVP milestone (PR #1) + TestFlight distribution readiness**

## Current objective

Make the existing PR #1 app target distributable through the already-merged Internal TestFlight workflow on `main`, without merging PR #1 and without changing gameplay. Recertify the exact-head playtest gate after the packaging push.

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

### TestFlight packaging (same PR, no gameplay change)

- Committed 1024×1024 `AppIcon` asset catalog (neutral gray-box “QF”, RGB, no alpha)
- `ITSAppUsesNonExemptEncryption = NO` in `QuietFactory/Info.plist` (no non-exempt encryption in the app or dependencies)
- `generate_xcodeproj.py` updated so regenerating preserves `Assets.xcassets` and `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`
- The generator still does **not** emit the hand-maintained `QuietFactoryUITests` target; do not run it against the committed project
- Bundle ID remains `com.quietfactory.app`; marketing version remains `0.1.0`; committed `DEVELOPMENT_TEAM` stays empty (workflow supplies it)
- TestFlight workflow lives on **`main`** at `.github/workflows/testflight.yml`. Do not modify it from this PR. Do not run the upload unless the owner asks.

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

The packaging push invalidates any prior `QF_PLAYTEST_READY`. The exact-head machine gate still applies even though gameplay did not change.

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

- Human playtest remains **intentionally deferred** until a provenance-backed `QF_PLAYTEST_READY` exists for the **current** exact PR head.
- The four machine-detectable P1 items (board hit-testing, release presentation trace, unsolvable solver fixture, UI/smoke tests) are implemented on this PR; they do **not** authorize playtest by themselves.
- Appetize time is scarce (~30 free minutes total); do not consume it for routine validation or packaging-only checks.
- A green CI run, Grok PASS, or a parent comment alone does **not** authorize human playtesting.
- Seeing `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` in a parent comment is **not itself evidence** that the independent reviewer executed.

## Active scope

- PR #1 TestFlight packaging (icon, export compliance, Xcode/generator parity)
- Exact-head `iOS CI` + playtest-gate recertification for the new SHA
- PR #1 remains open as the gray-box milestone (fixes via same PR only)

## Not active yet

- New gameplay features beyond PR #1 milestone scope
- Merging PR #1
- Running the TestFlight upload unless the owner asks
- Campaign, generator, solver production pipeline, daily puzzle, undo, final art, App Store listing
- Procedural generation (blocked until gray-box loop passes human validation)
- Re-enabling `QF — Next Milestone Starter` (blocked until provenance-backed playtest PASS and human merge of PR #1)

## Immediate success criterion

PR #1 head is archive/sign/upload-ready for the `main` TestFlight workflow, exact-head `iOS CI` is green, and that exact SHA has provenance-backed `QF_PLAYTEST_READY`.

## Current blockers

- Prior `QF_PLAYTEST_READY` markers are **stale** after packaging changes.
- Human playtest remains blocked until the new exact head is recertified.
- TestFlight upload is owner-triggered, not part of this pass.
- Cost discipline / Kimi provenance still not validated end-to-end on a production candidate.

## Next checkpoint

1. Land packaging on `agent/mvp-nightly` (do not merge).
2. Wait for exact-head GitHub `iOS CI`.
3. Recertify the playtest gate for that SHA (orchestrator owns the machine gate).
4. Owner runs TestFlight with `source_sha` = the certified SHA.
