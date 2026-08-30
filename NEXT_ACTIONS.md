# Quiet Factory — Next Actions
Last updated: 2026-08-30

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — Validate PR #1 orchestrator chain

Automation protocol/docs are locked. Custom routing smoke tests passed for `implementation-worker` and `pre-playtest-reviewer` (discovered and invoked; no routing/fallback warnings). Cursor does not expose child `originalModelName`, so exact runtime child model identity cannot be directly observed. `QF — Milestone Orchestrator` is enabled. `QF — Next Milestone Starter` remains disabled until PR #1 is ready to lead into the next milestone.

Complete in roughly this order:

1. **Push this synced PR #1 head** (`agent/mvp-nightly`) so enabled `QF — Milestone Orchestrator` receives a real PR-pushed event.
2. **Validate exact-head Grok review** — confirm `QF_GROK_HEAD` / `QF_GROK_STATUS` on the new SHA.
3. **If Grok finds P0/P1**, validate delegation to `implementation-worker` and the same-PR fix loop.
4. **Validate exact-head iOS CI handling** — orchestrator waits for green CI before final review.
5. **Validate final `pre-playtest-reviewer` invocation**.
6. **Confirm exact-head certification** — `QF_GROK_HEAD`, `QF_GROK_STATUS`, `QF_FINAL_HEAD`, `QF_FINAL_STATUS`, and `QF_PLAYTEST_READY` all refer to the same exact head.
7. **Only then consume human Appetize time** (see P1 below).
8. **On successful human playtest**, prepare for manual PR #1 merge and enable `QF — Next Milestone Starter`.

Do not claim automation is validated until steps 2–6 pass.

---

## P1 — After automation is validated

### Human playtest gray-box MVP (PR #1)

Only when PR #1 head has `QF_PLAYTEST_READY` for that exact SHA:

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
