# Quiet Factory — Next Actions
Last updated: 2026-08-30

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — Corrective docs, then re-validate PR #1 orchestrator chain

`QF — Milestone Orchestrator` is **DISABLED**. Keep it disabled until this corrective change is on PR #1. `QF — Next Milestone Starter` remains **DISABLED**. Do not run Kimi during the corrective docs PR itself.

Seeing `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` in a parent comment is **not itself evidence** that the independent reviewer executed.

Complete in this order:

1. **Merge this corrective docs/rules PR** into `main` (Kimi cost discipline + fail-closed final-review provenance).
2. **Sync latest `main` into PR #1** (`agent/mvp-nightly`). Required: the orchestrator reads `.cursor/agents/pre-playtest-reviewer.md` from the candidate branch; a `main`-only merge does not affect PR #1 until synced.
3. **Keep orchestrator disabled** until that sync is present on PR #1.
4. **Enable only `QF — Milestone Orchestrator`** — leave Next Milestone Starter disabled.
5. **Produce exactly one fresh PR #1 candidate head** (one push).
6. **Verify exact-head Grok PASS** (`QF_GROK_HEAD` / `QF_GROK_STATUS` for the new SHA).
7. **Verify exact-head iOS CI** green for that SHA.
8. **Observe an actual `pre-playtest-reviewer` child delegation** (named Task/subagent invoke — not parent self-review).
9. **Verify returned child contract:**
   - `REVIEWER_ROLE: pre-playtest-reviewer`
   - `REVIEWED_HEAD` matches candidate
   - `ROUTING_OK: true`
   - required review sections present
   - `RESULT` exactly `PASS` or `BLOCKED`
10. **Only after that child result** may `QF_FINAL_*` appear; only after actual child `PASS` may `QF_PLAYTEST_READY` appear.
11. **Confirm the new cost-disciplined prompt is actually being used** (post-sync branch content) and inspect Kimi usage after that one run for cost validation (observed usage only — no invented token counts).
12. **Confirm Automation MCP/tool config** remains Comment on PR only (already manually checked; re-verify checkbox only — do not rebuild).
13. **Only then** human Appetize playtest (P1).
14. Keep **Next Milestone Starter disabled**.

Treat any prior `QF_PLAYTEST_READY` for `abb46647…` as **invalid for automation-validation purposes**.

Do not claim automation is validated until steps 6–11 pass with provenance.

---

## P1 — After automation is validated

### Human playtest gray-box MVP (PR #1)

Only when PR #1 head has provenance-backed `QF_PLAYTEST_READY` for that exact SHA:

- Define a predefined human question before opening Appetize (see `docs/AUTOMATION_PROTOCOL.md` § E).
- **Without a Mac:** download `QuietFactory-Simulator-<sha>` from the green iOS CI run on GitHub Actions, upload the zip to [Appetize.io](https://appetize.io), and play in the browser
- **With Xcode:** run on iPhone simulator or device from `agent/mvp-nightly`
- Walk onboarding levels `onb-*` through difficult `hard-*`
- On `onb-3`: tap blocked crate first, then release blocker, then finish
- On `hard-1`: confirm both spatial unblocking and conveyor sequencing matter
- Confirm tap → release → conveyor → match → clear feels understandable and satisfying
- Confirm win state is visible for ~1 second before auto-advance
- Note any levels that feel unfair or visually unclear
- Record `PLAYTEST: PASS` or `PLAYTEST: FAIL`.
- On PASS → human manually merges PR #1 → enable `QF — Next Milestone Starter` only when ready for the next milestone.
- On FAIL → orchestrator delegates fixes on same PR, re-run full machine gates, then playtest again.

### Tune from playtest (if needed)

- Animation timing for slide/clear
- Haptic/audio intensity
- Level layouts that confuse new players
- Win pause duration if 1s feels too short/long

---

## P2 — Prototype evaluation (after gray-box playtest passes)

- Test without verbal explanation where possible
- Record misunderstandings and voluntary replay behavior
- Tune buffer/match size and remove unnecessary rules
- Do not proceed to procedural generation until the loop passes

---

## P3 — After prototype passes

- Formalize level schema, undo, solver, seeded generator, difficulty metrics, first visual theme

---

## Agent rule

An implementation agent should not jump ahead into P2/P3 gameplay work while P0 validation remains incomplete.

The prototype gate and playtest gate are intentional.

GitHub `iOS CI` is the authoritative Apple/Xcode validation loop. Inspect and fix CI failures; do not suppress tests or weaken the workflow.
