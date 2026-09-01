# Quiet Factory — Next Actions
Last updated: 2026-08-31

This file is intentionally tactical. Keep only the next meaningful work here.

Workflow details: `docs/AUTOMATION_PROTOCOL.md`.

---

## P0 — PR #1 TestFlight packaging, then recertify exact head

Do **not** merge PR #1. Do **not** open a replacement gameplay PR. Do **not** modify `.github/workflows/testflight.yml` on this PR.

`QF — Milestone Orchestrator` is **ENABLED** (Draft opened, PR pushed, `ios-ci.yml` Success). `QF — Next Milestone Starter` remains **DISABLED**.

Seeing `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` in a parent comment is **not itself evidence** that the independent reviewer executed. `QF_FINAL_GATE: WAITING_CI` is not playtest authorization.

Gameplay did **not** change for this packaging pass. The exact-head machine gate still applies because the PR HEAD moves.

Complete in this order:

1. **Land packaging on `agent/mvp-nightly`:** AppIcon catalog, export-compliance plist key, Xcode project + `generate_xcodeproj.py` parity. No gameplay changes.
2. **Wait for exact-head GitHub `iOS CI`** on the new PR #1 SHA. Inspect and fix real failures; do not suppress or weaken CI.
3. **Recertify the playtest gate** for that exact SHA (`QF_GROK_*` → CI green → `pre-playtest-reviewer` → `QF_PLAYTEST_READY`). Any prior `QF_PLAYTEST_READY` is stale.
4. **Owner runs Internal TestFlight** (not the implementation agent unless explicitly asked):
   - GitHub → Actions → TestFlight → Run workflow
   - `source_sha` = the exact `QF_PLAYTEST_READY` SHA
5. Keep PR #1 open. Apple processing may take several minutes after upload.
6. Keep **Next Milestone Starter disabled**.

Treat any prior `QF_PLAYTEST_READY` for an older SHA as **invalid**.

Do not claim automation is validated until the new head has provenance-backed `QF_PLAYTEST_READY`.

---

## P1 — After TestFlight build is available and playtest gate is green

### Human playtest gray-box MVP (PR #1)

Only when PR #1 head has provenance-backed `QF_PLAYTEST_READY` for that exact SHA:

- Define a predefined human question before opening Appetize (see `docs/AUTOMATION_PROTOCOL.md` § E).
- **Without a Mac:** download `QuietFactory-Simulator-<sha>` from the green iOS CI run on GitHub Actions, upload the zip to [Appetize.io](https://appetize.io), and play in the browser — **or** install from Internal TestFlight
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

An implementation agent should not jump ahead into P2/P3 gameplay work while PR #1 is still the open gray-box milestone.

The prototype gate and playtest gate are intentional.

GitHub `iOS CI` is the authoritative Apple/Xcode validation loop. Inspect and fix CI failures; do not suppress tests or weaken the workflow.
