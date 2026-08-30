# Quiet Factory — Next Actions
Last updated: 2026-08-30

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — Re-validate orchestrator chain after CI-handoff patch

`QF — Milestone Orchestrator` is **ENABLED** (Draft opened, PR pushed, `ios-ci.yml` Success). `QF — Next Milestone Starter` remains **DISABLED**.

Seeing `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` in a parent comment is **not itself evidence** that the independent reviewer executed. `QF_FINAL_GATE: WAITING_CI` is not playtest authorization.

**P1 machine-detectable fixes** (board hit-testing, release presentation trace, unsolvable solver fixture, UI/smoke tests) are implemented on the same PR. Human playtest remains gated on provenance-backed `QF_PLAYTEST_READY`.

Complete in this order:

1. **Merge corrective docs/rules PR #7** into `main` — **done** (`bf302ad`).
2. **Sync latest `main` into PR #1** (`agent/mvp-nightly`) — **done** (`b74d386`).
3. **Enable only `QF — Milestone Orchestrator`** — **done**.
4. **Add `ios-ci.yml` Success trigger** on that same automation — **done** (leave branch optional).
5. **Push CI-handoff protocol patch** — **this commit**.
6. **Verify exact-head Grok PASS** and `QF_FINAL_GATE: WAITING_CI` (Grok must **not** subscribe-and-exit).
7. **Verify exact-head iOS CI** green for that SHA.
8. **Observe a second orchestrator run** on `ios-ci.yml` success that **actually invokes** `pre-playtest-reviewer` (named Task/subagent — not parent self-review).
9. **Verify returned child contract:**
   - `REVIEWER_ROLE: pre-playtest-reviewer`
   - `REVIEWED_HEAD` matches candidate
   - `ROUTING_OK: true`
   - required review sections present
   - `RESULT` exactly `PASS` or `BLOCKED`
10. **Only after that child result** may `QF_FINAL_STATUS` appear; only after actual child `PASS` may `QF_PLAYTEST_READY` appear.
11. **Confirm the cost-disciplined prompt is used** and inspect Kimi usage after that one run (observed usage only — no invented token counts).
12. **Confirm Automation MCP/tool config** remains Comment on PR only (checkbox only — do not rebuild).
13. **Only then** human Appetize playtest (P1).
14. Keep **Next Milestone Starter disabled**.

Treat any prior `QF_PLAYTEST_READY` for `abb46647…` as **invalid**. Treat the `b7dd80a…` run as **CI-handoff failure** (no Kimi), not as a validated chain.

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
