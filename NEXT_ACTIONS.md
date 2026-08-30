# Quiet Factory — Next Actions
Last updated: 2026-08-30

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — Validate automation chain

Complete in roughly this order:

1. **Merge this final docs-lock PR.**
2. **Sync current `main` into PR #1** (`agent/mvp-nightly`).
3. **Enable `QF — Milestone Orchestrator` only** — keep `QF — Next Milestone Starter` disabled.
4. **Produce one new PR #1 head** — push once to trigger the exact-head validation chain.
5. **Validate exact-head Grok review** — confirm `QF_GROK_*` markers on the new SHA.
6. **Validate routine Composer delegation** — if P0/P1 occurs, confirm orchestrator delegates to `implementation-worker` on the same branch.
7. **Validate `architecture-escalator` only if naturally required** — do not create an artificial architecture defect merely to exercise it.
8. **Validate exact-head iOS CI handling** — orchestrator waits for green CI before final review.
9. **Validate `pre-playtest-reviewer` invocation** — confirm Kimi K3 High binding with no silent model fallback; confirm `QF_FINAL_*` markers.
10. **Confirm exact certification sequence** — `QF_GROK_*` → `QF_FINAL_*` → `QF_PLAYTEST_READY` for the same SHA.
11. **Only then consume human Appetize time** (see P1 below).
12. **Keep `QF — Next Milestone Starter` disabled** until the successful human playtest is ready to lead into a merge.

Do not claim automation is validated until steps 5–10 pass.

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
