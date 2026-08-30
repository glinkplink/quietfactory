# Quiet Factory — Automated PR Review Rubric

Last updated: 2026-08-30

This file is the canonical rubric for **Grok 4.6 High** independent PR review (Bugbot-style automated review).

For the full development workflow, read `docs/AUTOMATION_PROTOCOL.md`. Do not treat this file as a duplicate of that protocol.

---

## Required reading before review

Read these files before reviewing:

1. `AGENT_HANDOFF.md`
2. `RUNTIME_STATE.md`
3. `NEXT_ACTIONS.md`
4. `docs/AUTOMATION_PROTOCOL.md`

---

## Review scope

- Review the **COMPLETE PR against `main`**, not only the latest commit.
- Prior review comments from older SHAs do **not** certify the current SHA.
- Every certification must reference the **current PR head SHA**.

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

## Required output format

End every review with **exactly one** of these blocks (replace `<current head SHA>` with the actual PR head commit):

**PASS** (zero P0/P1 findings):

```
QF_GROK_HEAD: <current head SHA>
QF_GROK_STATUS: PASS
```

**BLOCKED** (one or more P0/P1 findings):

```
QF_GROK_HEAD: <current head SHA>
QF_GROK_STATUS: BLOCKED
```

List all findings with severity (P0–P3) above the status block.

**PASS means zero P0/P1 findings.** P2/P3 may be noted but do not block.

---

## Escalation note

If the implementation agent disputes a P0/P1 finding with evidence, they must record `QF_TECHNICAL_DISPUTE: …` per `docs/AUTOMATION_PROTOCOL.md`. Do not use reviewer voting; credible P0/P1 findings block until resolved or explicitly adjudicated by Sol High.
