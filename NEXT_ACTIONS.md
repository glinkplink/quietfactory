# Quiet Factory — Next Actions
Last updated: 2026-08-30

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — Install and validate development automation

Complete in roughly this order:

1. **Land orchestrator/subagent architecture** — `docs/AUTOMATION_PROTOCOL.md`, `.cursor/agents/implementation-worker.md`, `.cursor/agents/pre-playtest-reviewer.md`, handoff/runtime updates.
2. **Edit existing `QF — Grok Milestone Reviewer` automation** — update instructions so it becomes the **milestone orchestrator** (review, delegate fixes, wait for CI, invoke `pre-playtest-reviewer`, post `QF_*` markers).
3. **Validate Grok → Composer fix path on PR #1** — if a P0/P1 exists, confirm orchestrator delegates to `implementation-worker` and fixes land on the same branch.
4. **Validate Grok → CI → final-review path on PR #1** — confirm exact-head CI gates `pre-playtest-reviewer` invocation.
5. **Verify actual subagent model usage** — Composer is non-Fast (`composer-2.5[fast=false]`); `pre-playtest-reviewer` uses `kimi-k3-high` rather than silently falling back.
6. **Only then allow `QF_PLAYTEST_READY`** — orchestrator posts certification only after Grok PASS + CI green + independent final reviewer PASS (`QF_FINAL_STATUS: PASS`).
7. **Human playtest** — only when `QF_PLAYTEST_READY` exists for the exact head (see P1 below).
8. **Configure post-merge next-milestone automation** — after the current milestone gate is proven.

Do not claim automation is validated until steps 3–5 pass.

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

An implementation agent should not jump ahead into P2/P3 gameplay work while P0 automation remains incomplete.

The prototype gate and playtest gate are intentional.

GitHub `iOS CI` is the authoritative Apple/Xcode validation loop. Inspect and fix CI failures; do not suppress tests or weaken the workflow.
