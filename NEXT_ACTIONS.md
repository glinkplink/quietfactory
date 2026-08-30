# Quiet Factory — Next Actions
Last updated: 2026-08-30

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — Install and validate development automation

Complete in roughly this order:

1. **Automation protocol/docs** — merged to `main` (`docs/AUTOMATION_PROTOCOL.md`, `.cursor/BUGBOT.md`, handoff/runtime updates).
2. **Add project subagents** — `architecture-escalator` (read-only Grok 4.6) documented on `main`. Grok PR reviewer and Sol gates are top-level Cloud Agent automations, not nested repo subagents.
3. **Configure Grok PR reviewer statuses** — full-PR review against `main`; emit `QF_GROK_HEAD` / `QF_GROK_STATUS`. **Configured externally** as `QF — Grok Milestone Reviewer`.
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
- **Without a Mac:** download `QuietFactory-Simulator-<sha>` from the green iOS CI run on GitHub Actions, upload the zip to [Appetize.io](https://appetize.io), and play in the browser
- **With Xcode:** run on iPhone simulator or device from `agent/mvp-nightly`
- Walk onboarding levels `onb-*` through difficult `hard-*`
- On `onb-3`: tap blocked crate first, then release blocker, then finish
- On `hard-1`: confirm both spatial unblocking and conveyor sequencing matter
- Confirm tap → release → conveyor → match → clear feels understandable and satisfying
- Confirm win state is visible for ~1 second before auto-advance
- Note any levels that feel unfair or visually unclear
- Record `PLAYTEST: PASS` or `PLAYTEST: FAIL`.
- On PASS → human manually merges PR #1.
- On FAIL → fix on same PR, re-run full machine gates, then playtest again.

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

An implementation agent should not jump ahead into P2/P3 gameplay work while P0 automation remains incomplete.

The prototype gate and playtest gate are intentional.

GitHub `iOS CI` is the authoritative Apple/Xcode validation loop. Inspect and fix CI failures; do not suppress tests or weaken the workflow.
