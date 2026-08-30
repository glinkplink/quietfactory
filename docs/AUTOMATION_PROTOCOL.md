# Quiet Factory — Development Automation Protocol

Last updated: 2026-08-30

This document is the **canonical operating procedure** for Quiet Factory development automation.

Any Cursor Cloud Agent, local agent, automation, or reviewer must follow this workflow deterministically. Product and mechanics canon remain in `AGENT_HANDOFF.md`, `DECISIONS.md`, and `MASTER_PLAN.md`. When process rules here conflict with game behavior, **product/mechanics canon wins for gameplay**; automation must never silently reinterpret game rules.

---

## Pipeline overview

The intended **gameplay milestone** loop is:

```
PR opened / pushed
  → Grok 4.6 High top-level orchestrator reviews full exact PR head
  → if P0/P1: implementation-worker fixes SAME PR branch and pushes
  → new push restarts Grok review
  → if no P0/P1: wait for exact-head CI
  → if CI green: orchestrator invokes pre-playtest-reviewer (readonly Sol)
  → if Sol blocks: implementation-worker fixes SAME PR branch and pushes
  → if Sol passes: orchestrator posts QF_PLAYTEST_READY
  → human playtest
  → manual merge
  → (separate) post-merge next-milestone automation
```

A PR represents a **playtestable product milestone**, not a single code change. Multiple commits and automated review/fix loops happen **within the same PR**.

After a successful human playtest:

1. The milestone PR is **manually merged**.
2. The next milestone starts from fresh `main`.
3. A new draft PR is created for that next milestone.

**Do not run human playtests for infrastructure, automation, CI, or docs-only PRs.**

---

## Top-level automations

### A. `QF — Grok Milestone Orchestrator`

**Configured externally** (currently named `QF — Grok Milestone Reviewer`; instructions should be updated to match this orchestrator role).

| Property | Value |
|----------|-------|
| Model | Grok 4.6 High, non-Fast |
| Triggers | Gameplay milestone PR opened / PR pushed |
| Owns | PR comments and all `QF_*` certification markers |

**Responsibilities:**

1. Review the **full exact PR head** against `main`.
2. Emit `QF_GROK_HEAD` / `QF_GROK_STATUS` itself.
3. If P0/P1 findings exist, invoke **`implementation-worker`** to fix on the **same PR branch** and push when appropriate.
4. Invoke **`architecture-escalator`** only when architecture escalation is required.
5. Wait for **exact-head** `iOS CI` before final certification.
6. Invoke **`pre-playtest-reviewer`** only after:
   - Grok has **zero P0/P1** for the exact head, and
   - **exact-head** `iOS CI` succeeds.
7. Translate `pre-playtest-reviewer` results into `QF_SOL_HEAD` / `QF_SOL_STATUS` and, when appropriate, `QF_PLAYTEST_READY`.

Any push **invalidates** all prior review/certification and restarts from Grok.

**Cost rule:** The orchestrator must invoke `pre-playtest-reviewer` at most **once per exact candidate head**, and only after Grok + CI are already clear.

### B. Post-merge next-milestone automation

- Remains **planned separately**.
- Does **not** participate in the current-head review/fix loop.

### Retired / deliberately not used

The following were considered and **abandoned** because Cursor's generic PR-comment Automation trigger does **not** provide safe regex/body filtering in the current UI, and **bot-generated PR comments cannot be relied upon** to trigger another Cursor Automation:

- Separate **Composer review-fixer** top-level automation
- Separate **Sol pre-playtest** top-level automation
- **Bot-comment chaining** between Cursor Automations

Therefore the **Grok milestone orchestrator** owns the complete machine gate for the current head.

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

### Top-level orchestration vs repo subagents

| Role | Where it lives |
|------|----------------|
| Milestone orchestration, Grok review, certification markers | **Top-level automation:** `QF — Grok Milestone Orchestrator` |
| Routine code modifications / P0/P1 fixes | **Project subagent:** `.cursor/agents/implementation-worker.md` (Composer 2.5 standard, non-Fast) |
| Implementation-time architecture escalation | **Project subagent:** `.cursor/agents/architecture-escalator.md` (read-only Grok 4.6) |
| Final scarce pre-playtest review | **Project subagent:** `.cursor/agents/pre-playtest-reviewer.md` (readonly GPT-5.6 Sol Medium) — invoked **only** by the orchestrator |
| Human playtest | Human — comprehension / feel / fun / frustration / clarity |
| Post-merge next milestone | **Planned** separate top-level automation |

**Normal implementation agents must not casually invoke Sol.** Only the parent orchestrator may call `pre-playtest-reviewer`, and only under the cost rule above.

Subagents return **structured results to the parent** and must **not** independently post `QF_GROK_*`, `QF_SOL_*`, or `QF_PLAYTEST_READY` markers.

---

### Grok 4.6 High — milestone orchestrator and independent PR reviewer

The top-level orchestrator runs on **meaningful PR heads** for gameplay/product milestone PRs.

**Responsibilities:**

- review the **complete PR against `main`**, not only the latest commit
- enforce product/mechanics canon
- detect P0/P1 blockers
- examine architecture, gameplay correctness, UI/model state synchronization, tests, solvability, restart behavior, animation locks, scope drift, and related concerns
- invoke `implementation-worker` for valid P0/P1 fixes
- invoke `architecture-escalator` only when required
- invoke `pre-playtest-reviewer` only after Grok PASS + exact-head CI green
- post all `QF_*` certification markers in PR comments

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

### Composer 2.5 — implementation worker (`implementation-worker`)

**Path:** `.cursor/agents/implementation-worker.md`

**Model:** `composer-2.5[fast=false]` (standard Composer, non-Fast)

**Use for:**

- P0/P1 fixes delegated by the orchestrator
- normal feature implementation when explicitly tasked
- routine bug fixes
- tests
- UI implementation
- small refactors
- docs
- high-volume iteration

The implementation worker performs coding work **on the existing branch** when the orchestrator delegates. It does **not** own review or certification.

Composer may escalate via `ARCHITECTURE_ESCALATION_REQUIRED`; the orchestrator decides whether to invoke `architecture-escalator`.

---

### Grok 4.6 High — architecture escalation (`architecture-escalator`)

Implementation-time architecture escalation uses the read-only project subagent:

- **Path:** `.cursor/agents/architecture-escalator.md`
- **Model:** `grok-4.6`
- **Mode:** `readonly: true` — advisory only; does not edit files

The orchestrator (or implementation worker via escalation signal) may invoke `architecture-escalator` **only when**:

- gameplay semantics must change
- GameCore/UI ownership boundaries are unclear or must change
- SpriteKit/model synchronization requires architectural judgment
- there are materially different architectural choices with different long-term consequences
- the same defect has resisted **two** implementation-worker attempts

Do **not** escalate for ordinary implementation, straightforward fixes, routine tests, docs, small UI polish, or mechanical refactors with an obvious correct approach.

Architecture escalation is **advisory/read-only** unless explicitly authorized otherwise.

---

### GPT-5.6 Sol Medium — final pre-playtest gate (`pre-playtest-reviewer`)

**Path:** `.cursor/agents/pre-playtest-reviewer.md`

**Model:** `gpt-5.6-sol[effort=medium,fast=false]`

**Mode:** `readonly: true`

**Expensive model. Do not use continuously.**

Invoked **only** by the Grok milestone orchestrator, **only after**:

1. Grok review for the **exact current head** has zero P0/P1 findings
2. `iOS CI` succeeds on the **exact current head**
3. the PR is actually a **gameplay/playtest milestone**

**Question it must answer:**

> Is there any material defect, contradiction, missing automated test, or machine-detectable uncertainty that should be resolved BEFORE scarce human playtest time is consumed?

Only **P0/P1-level** issues block.

The subagent returns `PASS` or `BLOCKED` to the parent. The **orchestrator** translates that into:

```
QF_SOL_HEAD: <sha>
QF_SOL_STATUS: PASS
```

or

```
QF_SOL_HEAD: <sha>
QF_SOL_STATUS: BLOCKED
```

If `PASS`, the orchestrator also emits:

```
QF_PLAYTEST_READY: <sha>
```

---

### GPT-5.6 Sol High — rare dispute adjudicator

**Use only when a genuine technical disagreement cannot be resolved normally.**

Will be used only through a separate, explicitly invoked **top-level Cloud Agent adjudication path** if a genuine technical dispute survives normal review/fix cycles.

It is **NOT** a nested repo subagent. Do **not** create additional Sol project subagents for adjudication.

Do **not** use as a routine reviewer. Implementation agents must **not** invoke Sol directly.

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

### Implementation worker should not escalate merely because a task is difficult

Escalate to the **`architecture-escalator`** project subagent (Grok architecture review) when:

1. gameplay semantics must change
2. GameCore vs UI ownership is unclear
3. animation/model synchronization requires architectural judgment
4. two materially different implementations would produce different long-term architecture
5. two reasonable implementation-worker attempts failed on the same defect

### If Grok orchestrator blocks (P0/P1)

1. Orchestrator invokes `implementation-worker` to fix valid P0/P1 issues on the **same PR branch**
2. Do **not** create a second PR
3. Do **not** weaken tests just to make them green
4. Push fixes when the orchestrator delegates push
5. Any new push **invalidates** previous review certification
6. Orchestrator review and `iOS CI` run again from the top

### If Grok PASS + CI green + pre-playtest-reviewer BLOCK

1. Treat the Sol finding as **blocking**
2. Orchestrator invokes `implementation-worker` to fix on the same PR
3. Push
4. Old Grok and Sol certifications become **stale**
5. Run the **full gate** again (Grok → CI → pre-playtest-reviewer)

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
4. Implement (human or orchestrator-delegated `implementation-worker`).
5. Relevant local verification (tests, lint as applicable).
6. **Grok orchestrator** reviews full exact head.
7. If `BLOCKED` (P0/P1) → orchestrator invokes `implementation-worker` → push → repeat from step 6.
8. When Grok `PASS` → wait for **exact-head** `iOS CI`.
9. When CI green → orchestrator invokes `pre-playtest-reviewer` once for that head.
10. If `BLOCKED` → orchestrator invokes `implementation-worker` → push → restart from step 6.
11. When orchestrator posts `QF_PLAYTEST_READY` for the exact SHA, that exact artifact may be used for human playtesting.
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
new push → Grok orchestrator → CI → (if gameplay milestone) pre-playtest-reviewer → QF_PLAYTEST_READY
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
| `architecture-escalator` project subagent | **Documented** |
| `implementation-worker` project subagent | **Documented** |
| `pre-playtest-reviewer` project subagent | **Documented** |
| `QF — Grok Milestone Orchestrator` | **Configured externally** — instructions should be updated to orchestrator role |
| Separate Composer review-fixer automation | **Abandoned** — orchestrator delegates to `implementation-worker` |
| Separate Sol pre-playtest top-level automation | **Abandoned** — orchestrator invokes `pre-playtest-reviewer` |
| Bot-comment automation chaining | **Abandoned** — unsuitable with current Cursor Automation UI |
| Playtest-fail fixer | **Planned** — orchestrator may delegate fixes; dedicated automation TBD |
| Post-merge next-milestone automation | **Planned** — not yet configured |

Do not claim the full orchestrator chain is validated until it has been exercised end-to-end against a gameplay milestone PR.
