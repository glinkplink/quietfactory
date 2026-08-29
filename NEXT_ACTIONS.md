# Quiet Factory — Next Actions
Last updated: 2026-08-29

This file is intentionally tactical. Keep only the next meaningful work here.

---

## P0 — Do now

### 1. Human playtest gray-box MVP (PR #1)
- Run on iPhone simulator or device from `agent/mvp-nightly`
- Walk onboarding levels `onb-*` through difficult `hard-*`
- On `onb-3`: tap blocked crate first, then release blocker, then finish
- On `hard-1`: confirm both spatial unblocking and conveyor sequencing matter
- Confirm tap → release → conveyor → match → clear feels understandable and satisfying
- Confirm win state is visible for ~1 second before auto-advance
- Note any levels that feel unfair or visually unclear

### 2. Tune from playtest (if needed)
- Animation timing for slide/clear
- Haptic/audio intensity
- Level layouts that confuse new players
- Win pause duration if 1s feels too short/long

---

## P1 — Prototype evaluation

After gray-box playtesting:

- test without verbal explanation where possible
- record misunderstandings
- measure approximate board completion time
- note whether players restart voluntarily
- identify whether conveyor decisions feel strategic or merely annoying
- tune buffer size and match size
- remove unnecessary rules

Do not proceed to procedural generation until the loop passes.

---

## P2 — After prototype passes

- formalize level schema
- implement move-history + undo
- implement solver
- implement seeded generator
- define difficulty metrics
- build seed-validation tests
- design first visual theme

---

## Agent rule

An implementation agent should not jump ahead into P2 simply because P0 is straightforward.

The prototype gate is intentional.

GitHub `iOS CI` is the authoritative Apple/Xcode validation loop. Inspect and fix CI failures; do not suppress tests or weaken the workflow.
