# Quiet Factory — Next Actions
Last updated: 2026-08-30

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — Install and validate development automation

Complete in roughly this order:

1. **Finish automation protocol/docs** — `docs/AUTOMATION_PROTOCOL.md`, `.cursor/BUGBOT.md`, handoff/runtime updates.
2. **Add project subagents** — Composer implementation, Grok reviewer, Sol gate, fixers per protocol.
3. **Configure Grok PR reviewer statuses** — full-PR review against `main`; emit `QF_GROK_HEAD` / `QF_GROK_STATUS`.
4. **Add Composer review-fixer automation** — fix P0/P1 on same PR branch; no replacement PRs.
5. **Add Sol pre-playtest gate** — run only after CI green + Grok PASS; emit `QF_SOL_*` and `QF_PLAYTEST_READY`.
6. **Add playtest-fail fixer** — on `PLAYTEST: FAIL`, fix on same milestone PR and re-run machine gates.
7. **Add post-merge next-milestone automation** — after manual merge, branch fresh from `main` and open next draft PR.
8. **Validate the automation chain against current PR #1** — end-to-end dry run without consuming human playtest time.
9. **Only after the chain works**, decide whether PR #1 qualifies for another human playtest.

Do not claim automation is active until step 8 passes.

---

## P1 — After automation is validated

### Human playtest gray-box MVP (PR #1)

Only when PR #1 head has `QF_PLAYTEST_READY` for that exact SHA:

- Define a predefined human question before opening Appetize (see `docs/AUTOMATION_PROTOCOL.md` § E).
- Download CI simulator artifact or run from `agent/mvp-nightly`.
- Record `PLAYTEST: PASS` or `PLAYTEST: FAIL`.
- On PASS → human manually merges PR #1.
- On FAIL → fix on same PR, re-run full machine gates, then playtest again.

### Tune from playtest (if needed)

- Animation timing, haptic/audio intensity, confusing level layouts, win pause duration.

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

An implementation agent should not jump ahead into P2/P3 gameplay work while P0 automation remains incomplete.

The prototype gate and playtest gate are intentional.

GitHub `iOS CI` is the authoritative Apple/Xcode validation loop. Inspect and fix CI failures; do not suppress tests or weaken the workflow.
