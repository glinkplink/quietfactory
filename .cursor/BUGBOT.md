# Quiet Factory — Automated PR Review Rubric

Last updated: 2026-08-30

This file is the canonical rubric for **Grok 4.6 High** independent PR review (Bugbot-style automated review).

Cursor automation settings and the paste-ready prompt live in
`docs/QF_GROK_MILESTONE_REVIEWER.md`. For the full development workflow, read
`docs/AUTOMATION_PROTOCOL.md`. Do not treat this file as a duplicate of that protocol.

---

## Hard constraints

- Never edit files, push commits, or open another PR.
- Comment on the pull request only. Do not approve, request changes, or dismiss reviews.
- Do not quote stale `QF_*` status blocks from prior reviews in the final comment.

---

## Classify first

If the PR is docs-only, CI-only, automation-only, tooling-only, or otherwise **not** a
gameplay/product playtest milestone:

- do **not** emit `QF_GROK_HEAD` or `QF_GROK_STATUS`;
- do **not** trigger downstream playtest gates;
- exit without changing files.

Only gameplay/product milestone PRs may emit `QF_GROK_*`.

---

## Required reading before review

Read these files before reviewing:

1. `AGENT_HANDOFF.md`
2. `RUNTIME_STATE.md`
3. `NEXT_ACTIONS.md`
4. `docs/AUTOMATION_PROTOCOL.md`
5. this file

---

## Review scope

- Review the **COMPLETE PR against `main`**, not only the latest commit.
- Prior review comments from older SHAs do **not** certify the current SHA.
- Every certification must reference the **current PR head SHA**.
- Re-check all prior P0/P1 findings and whether they are actually resolved on this head.

---

## Minimum enforcement checklist

Block (P0/P1) when any of the following fail:

| Area | Requirement |
|------|-------------|
| **Determinism** | Game rules remain deterministic and independent of SpriteKit. |
| **Authority** | Renderer/UI must never become authoritative game state. |
| **Solvability** | Every catalog level must remain mechanically solvable. |
| **Direction sync** | Directional rendering must agree with model direction. |
| **Input/animation locks** | Restart and level transitions may not leave animation or input locks. |
| **Regression coverage** | Gameplay behavior changes require meaningful regression coverage. |
| **Test quality** | Tests must be non-vacuous; do not accept tests that can always pass. |
| **Prototype gate** | No procedural generation until gray-box loop passes human validation. |
| **Scope** | No backend, monetization, account, analytics, or unrelated scope drift. |
| **Playtest readiness** | Human playtest time is scarce; any P0/P1 defect discoverable automatically blocks `PLAYTEST_READY`. |
| **Visual artifacts** | Review screenshot/rendering artifacts when available. |

Also examine: architecture boundaries, gameplay correctness, UI/model synchronization, solvability proofs, restart behavior, animation locks, and scope drift.

---

## Severity classification

| Severity | Meaning |
|----------|---------|
| **P0** | Catastrophic / cannot proceed |
| **P1** | Blocks current milestone or human playtest |
| **P2** | Real but nonblocking |
| **P3** | Optional polish |

---

## CI and freshness (gameplay milestones only)

If any P0/P1 code/design defect is already found, comment immediately and end `BLOCKED`.
Do **not** wait for CI.

If there are **zero** P0/P1 findings:

1. Inspect GitHub `iOS CI` for the **exact current head**.
2. If CI is still running, subscribe/wait for that exact-head CI result.
3. Before posting after waking, re-read the PR and verify the head SHA has not changed.
4. If the PR head changed, **stop without certifying**; the PR-pushed run for the new head owns review.
5. If exact-head CI fails, treat that as **P1** and end `BLOCKED`.
6. If exact-head CI succeeds, end `PASS`.

---

## Required output format

Gameplay/product milestone reviews must end with **exactly one** of these blocks
(replace `<current head SHA>` with the actual PR head commit). Non-milestone PRs must
not emit this block.

**PASS** (zero P0/P1 findings **and** successful exact-head `iOS CI`):

```
QF_GROK_HEAD: <current head SHA>
QF_GROK_STATUS: PASS
```

**BLOCKED** (one or more P0/P1 findings, including exact-head CI failure):

```
QF_GROK_HEAD: <current head SHA>
QF_GROK_STATUS: BLOCKED
```

List all findings with severity (P0–P3) above the status block.

**PASS means zero P0/P1 plus successful exact-head CI.** P2/P3 may be noted but do not block.

---

## Escalation note

If the implementation agent disputes a P0/P1 finding with evidence, they must record `QF_TECHNICAL_DISPUTE: …` per `docs/AUTOMATION_PROTOCOL.md`. Do not use reviewer voting; credible P0/P1 findings block until resolved or explicitly adjudicated by Sol High.
