# Quiet Factory — Development Automation Protocol

Last updated: 2026-08-30

This document is the **canonical operating procedure** for Quiet Factory development automation.

Any Cursor Cloud Agent, local agent, automation, or reviewer must follow this workflow deterministically. Product and mechanics canon remain in `AGENT_HANDOFF.md`, `DECISIONS.md`, and `MASTER_PLAN.md`. When process rules here conflict with game behavior, **product/mechanics canon wins for gameplay**; automation must never silently reinterpret game rules.

---

## Pipeline overview

The intended development pipeline is:

```
fresh milestone PR
  → Composer implementation
  → CI
  → Grok review
  → Composer fixes
  → repeat
  → Sol final gate
  → human playtest
  → manual merge
  → next fresh milestone PR
```

A PR represents a **playtestable product milestone**, not a single code change. Multiple commits and automated review/fix loops happen **within the same PR**.

After a successful human playtest:

1. The milestone PR is **manually merged**.
2. The next milestone starts from fresh `main`.
3. A new draft PR is created for that next milestone.

**Do not run human playtests for infrastructure, automation, CI, or docs-only PRs.**

---

## A. Core principles

### Human playtest time is scarce

The project has roughly **30 free Appetize minutes total**. Treat human playtesting as a **gated milestone resource**, not routine validation.

### Do not waste playtest time on machine-detectable defects

Do **not** spend Appetize time verifying defects that could have been discovered through:

- unit/integration tests
- GitHub `iOS CI`
- code review (Grok / Sol)
- simulator automation
- screenshot or rendering artifacts
- deterministic model/solver checks

### Human playtesting answers questions machines cannot answer reliably

Use human playtesting only for:

- **comprehension** — does the player understand what is happening?
- **feel** — do interactions feel responsive and satisfying?
- **fun** — is the loop engaging?
- **frustration** — does anything feel unfair or opaque?
- **visual clarity** — can the player read the board and conveyor state?
- **onboarding** — does the game teach the loop without explanation?
- **voluntary continuation** — does the player want to keep playing?

### Milestone PRs stay open through the full cycle

Gameplay milestone PRs remain open through:

- implementation
- automated review
- fix cycles
- human playtesting

**Never open a replacement PR merely because review found defects.** Fix on the same branch and same PR.

### Merge and next milestone

Successful playtest → **human/manual merge** → next milestone begins from current `main`.

### Non-gameplay PRs

Infrastructure, automation, CI, docs, and tooling PRs **do not automatically trigger human playtests**.

---

## B. Model roles

### Composer 2.5 — primary implementation worker

**Use for:**

- normal feature implementation
- routine bug fixes
- tests
- UI implementation
- small refactors
- docs
- high-volume iteration

Composer should perform the **majority of coding work**.

---

### Grok 4.6 High — architecture escalation

**Use only when:**

- gameplay semantics must change
- GameCore/UI ownership boundaries are unclear or must change
- SpriteKit/model synchronization requires architectural judgment
- there are materially different architectural choices with different long-term consequences
- the same defect has resisted **two** Composer implementation attempts

Architecture escalation is **advisory/read-only** unless explicitly authorized otherwise.

---

### Grok 4.6 High — independent PR reviewer

Run on **meaningful PR heads** for gameplay/product milestone PRs.

**Responsibilities:**

- review the **complete PR against `main`**, not only the latest commit
- enforce product/mechanics canon
- detect P0/P1 blockers
- examine architecture, gameplay correctness, UI/model state synchronization, tests, solvability, restart behavior, animation locks, scope drift, and related concerns

**Review classification:**

| Severity | Meaning |
|----------|---------|
| **P0** | Catastrophic / cannot proceed |
| **P1** | Blocks current milestone or human playtest |
| **P2** | Real but nonblocking |
| **P3** | Optional polish |

**Machine-readable result (exact format):**

```
QF_GROK_HEAD: <sha>
QF_GROK_STATUS: PASS
```

or

```
QF_GROK_HEAD: <sha>
QF_GROK_STATUS: BLOCKED
```

**PASS** means no P0/P1 findings.

See `.cursor/BUGBOT.md` for the canonical review rubric.

---

### GPT-5.6 Sol Medium — final pre-playtest gate

**Expensive model. Do not use continuously.**

Run **only after:**

1. `iOS CI` succeeds on the current PR head
2. the latest Grok review for the **exact current head** is `PASS`
3. the PR is actually a **gameplay/playtest milestone**

**Question it must answer:**

> Is there any material defect, contradiction, missing automated test, or machine-detectable uncertainty that should be resolved BEFORE scarce human playtest time is consumed?

Only **P0/P1-level** issues block.

**Machine-readable result (exact format):**

```
QF_SOL_HEAD: <sha>
QF_SOL_STATUS: PASS
```

or

```
QF_SOL_HEAD: <sha>
QF_SOL_STATUS: BLOCKED
```

If `PASS`, also emit:

```
QF_PLAYTEST_READY: <sha>
```

---

### GPT-5.6 Sol High — rare dispute adjudicator

**Use only when a genuine technical disagreement cannot be resolved normally.**

Do **not** use as a routine reviewer.

Feed it only:

- the disputed finding
- the implementation agent's counterargument
- the relevant Grok conclusion
- relevant code
- relevant canon

**Expected decision:**

- `UPHOLD` — reviewer finding stands; fix required
- `OVERRULE` — reviewer finding rejected with evidence

Do **not** use reviewer "voting." A credible P0/P1 blocks until resolved or explicitly adjudicated.

---

## C. Escalation rules

### Composer should not escalate merely because a task is difficult

Escalate to **Grok architecture review** when:

1. gameplay semantics must change
2. GameCore vs UI ownership is unclear
3. animation/model synchronization requires architectural judgment
4. two materially different implementations would produce different long-term architecture
5. two reasonable Composer attempts failed on the same defect

### If Grok reviewer blocks

1. Composer fixes valid P0/P1 issues on the **same PR branch**
2. Do **not** create a second PR
3. Do **not** weaken tests just to make them green
4. Push fixes
5. Any new push **invalidates** previous review certification
6. `iOS CI` and Grok review run again

### If Grok PASS + Sol BLOCK

1. Treat the Sol finding as **blocking**
2. Composer fixes it on the same PR
3. Push
4. Old Grok and Sol certifications become **stale**
5. Run the **full gate** again (CI → Grok → Sol)

### Technical disputes

If the implementation agent believes a reviewer finding is factually wrong, it must explicitly record:

```
QF_TECHNICAL_DISPUTE: <concise evidence-backed explanation>
```

Only then may the rare **Sol High adjudication** path be used.

---

## D. PR lifecycle

Exact lifecycle for a **gameplay milestone PR**:

1. Start from current `main`.
2. Create a fresh milestone branch.
3. Open **one draft PR** for that milestone.
4. Composer implements.
5. Relevant local verification (tests, lint as applicable).
6. `iOS CI`.
7. Grok full-PR review.
8. If `BLOCKED` → Composer fixes on same branch → repeat from step 6.
9. When CI green + Grok `PASS` → Sol Medium final gate.
10. If Sol `BLOCKED` → fix on same PR → restart gates from step 6.
11. When the exact SHA receives `QF_PLAYTEST_READY`, that exact artifact may be used for human playtesting.
12. Human records one of:
    - `PLAYTEST: PASS`
    - `PLAYTEST: FAIL`
13. **FAIL** → same milestone PR stays open; fix and re-run machine gates before another playtest.
14. **PASS** → human manually merges.
15. Only **after merge** does the next milestone begin from new `main`.

### What does NOT authorize human playtesting

| Condition | Authorizes playtest? |
|-----------|---------------------|
| Green CI alone | **No** |
| Grok PASS alone | **No** |
| Sol PASS against a stale SHA | **No** |
| `QF_PLAYTEST_READY` for the **exact artifact SHA** | **Yes** |

---

## E. Human playtest policy

### Require a predefined human question before consuming Appetize time

Examples:

- Can a new player understand why this crate is blocked?
- Is conveyor sequencing legible?
- Does matching feel satisfying?
- Does onboarding teach the loop without explanation?
- Does `hard-1` feel strategic rather than arbitrary?

### Human playtesting should NOT be used for

- checking whether crates render at all
- validating level solvability (use `LevelSolver` / CI tests)
- checking restart state
- checking obvious animation locks
- confirming CI-testable behavior
- discovering issues detectable from screenshots or simulator automation

---

## F. Freshness / SHA rules

Every machine certification is tied to an **exact commit SHA**.

Any code change after:

- Grok PASS
- Sol PASS
- `QF_PLAYTEST_READY` certification

makes those certifications **stale**.

The new head must pass the appropriate gates again:

```
new push → CI → Grok → (if gameplay milestone) Sol → QF_PLAYTEST_READY
```

Do **not** resume human playtesting on a stale artifact.

---

## G. Scope discipline

Automation must **not** become permission to:

- broaden product scope
- add backend, accounts, analytics, or monetization
- introduce procedural generation before the prototype loop passes human validation
- change gameplay semantics without explicit milestone authorization
- bypass deterministic GameCore ownership

Preserve all existing Quiet Factory constraints from `AGENT_HANDOFF.md` and `DECISIONS.md`.

---

## Implementation status

| Component | Status |
|-----------|--------|
| This protocol document | **Documented** |
| Grok PR reviewer automation | **Planned** — not yet configured |
| Composer review-fixer automation | **Planned** — not yet configured |
| Sol pre-playtest gate | **Planned** — not yet configured |
| Playtest-fail fixer | **Planned** — not yet configured |
| Post-merge next-milestone automation | **Planned** — not yet configured |

Do not claim any automation is active until it is actually configured and validated.
