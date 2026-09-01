# Quiet Factory — Development Automation Protocol

Last updated: 2026-08-30

This document is the **canonical operating procedure** for Quiet Factory development automation.

Any Cursor Cloud Agent, local agent, automation, or reviewer must follow this workflow deterministically. Product and mechanics canon remain in `AGENT_HANDOFF.md`, `DECISIONS.md`, and `MASTER_PLAN.md`. When process rules here conflict with game behavior, **product/mechanics canon wins for gameplay**; automation must never silently reinterpret game rules.

---

## Pipeline overview

The permanent **gameplay milestone** loop is:

```
fresh main
  → QF — Next Milestone Starter opens draft milestone PR
  → Draft opened starts QF — Milestone Orchestrator
  → Grok exact-head review
  → implementation-worker fixes if necessary
  → push
  → PR pushed Grok run owns new SHA
  → if Grok PASS and iOS CI not yet green: emit QF_GROK + QF_FINAL_GATE: WAITING_CI and **end this run**
  → ios-ci.yml success starts the **same** orchestrator on that SHA
  → pre-playtest-reviewer (independent final review)
  → QF_PLAYTEST_READY
  → human playtest
  → PASS = human manual merge
  → PR merged starts QF — Next Milestone Starter for next draft milestone
```

If playtest **FAIL**:

- the same milestone PR remains open
- the orchestrator delegates fixes via `implementation-worker`
- push restarts the full exact-head gate

A PR represents a **playtestable product milestone**, not a single code change. Multiple commits and automated review/fix loops happen **within the same PR**.

**Do not run human playtests for infrastructure, automation, CI, or docs-only PRs.**

There is **no** bot-comment chaining, separate fixer automation, separate final-review automation, dedicated playtest-failure automation, or permanent dispute-adjudicator automation.

---

## Top-level automations

Quiet Factory has **exactly two** top-level Cursor Automations. No other top-level automations are planned.

### A. `QF — Milestone Orchestrator`

| Property | Value |
|----------|-------|
| Status | **Configured externally** — **ENABLED** |
| Model | Cursor Grok 4.6 High, non-Fast |
| Repository | `glinkplink/quietfactory` |
| Triggers | **Draft opened**, **PR pushed**, **Workflow run completed** (`ios-ci.yml`, Success) |
| Tools | Comment on Pull Request; PR approval disabled |

**Trigger note:** `PR opened` is deliberately **not** used. All gameplay milestones begin as drafts; avoiding `PR opened` prevents redundant Grok runs.

This is still **exactly two** top-level automations. The workflow-success trigger is an additional wake-up on the **same** orchestrator, not a third automation.

**CI handoff (empirical; do not “subscribe and end the turn”):**

Cursor Automations do **not** resume a finished run when GitHub CI later completes. “Subscribe to GitHub CI and end the turn” marks the automation **success** and drops the Kimi gate. Observed on PR #1 head `b7dd80a…` ([bc-af922655](https://cursor.com/agents/bc-af922655-6799-47ab-bb51-b045758bdc21)): Grok PASS path ended at 3m52s; `iOS CI` went green ~8–12 minutes later; no follow-up run invoked `pre-playtest-reviewer`.

Therefore:

1. **Draft opened / PR pushed** — do Grok on the exact current head. If `PASS` and exact-head `iOS CI` (`ios-ci.yml` / `Build and test`) is **not** green yet: post `QF_GROK_*` and the non-certifying marker below, then **stop**. Do not invoke Kimi. Do not poll. Do not subscribe-and-exit as if a later resume will happen.
2. **Workflow `ios-ci.yml` finished with Success** — this is the Kimi wake-up. If this SHA already has Grok `PASS` and exact-head iOS CI is green, **skip a second Grok review** and invoke `pre-playtest-reviewer` once. If Grok `PASS` does not yet exist for this SHA, do Grok in this run; if that is `PASS` and CI is already green, continue to Kimi in the **same** run.
3. Treat **only** workflow `ios-ci.yml` / check `Build and test` as iOS CI. The Cursor Automation check is **not** iOS CI (false alarm).
4. `push` and `pull_request` may both succeed for one SHA. Invoke Kimi **at most once per SHA**. If a **validated child result** already produced `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` for this exact head, **no-op**. `QF_FINAL_GATE: WAITING_CI` is **not** a completed final gate — the CI-success run must still invoke Kimi.
5. Branch filter is optional in the Cursor UI. **Quiet no-op** unless the SHA is the current HEAD of an **open gameplay/playtest milestone draft PR**. Do not Grok or Kimi `main`, merged PRs, or docs/CI-only branches.
6. If exact-head iOS CI is **already green** during a PR-pushed run (Grok slower than CI), invoke Kimi in **that** run. The later workflow-success run must then no-op.

Non-certifying wait marker (not playtest authorization):

```
QF_FINAL_GATE: WAITING_CI
QF_FINAL_HEAD: <sha>
REASON: exact-head iOS CI not green yet; Kimi deferred to ios-ci.yml success run
```

**Responsibilities:**

1. Own the complete gameplay milestone machine gate for the exact current PR head.
2. Review the **full exact PR head** against `main`.
3. Emit `QF_GROK_HEAD` / `QF_GROK_STATUS`.
4. Delegate routine fixes to **`implementation-worker`** on the **same PR branch**.
5. Delegate architecture questions to **`architecture-escalator`** only when required.
6. Do **not** wait for iOS CI by ending the turn. After Grok `PASS`, either invoke Kimi in this run (CI already green) or emit `QF_FINAL_GATE: WAITING_CI` and stop; the `ios-ci.yml` success trigger owns the Kimi wake-up.
7. **Actually invoke** the named project subagent **`pre-playtest-reviewer`** (Task/subagent delegation) at most **once per eligible candidate SHA**, only after Grok has zero P0/P1 and exact-head CI succeeds — with a supplied **routing pack** (see below). This is a foreground dependency; wait for the child result.
8. Translate a **validated child result** into `QF_FINAL_HEAD` / `QF_FINAL_STATUS` and, only after child `RESULT: PASS` with proven provenance, `QF_PLAYTEST_READY`. Never self-certify the Kimi gate.
9. Wait for human `PLAYTEST: PASS` or `PLAYTEST: FAIL`.
10. **Never** merge.

Any push **invalidates** all prior review/certification and restarts from Grok.

### B. `QF — Next Milestone Starter`

| Property | Value |
|----------|-------|
| Status | **Configured externally** — **DISABLED** pending validation of the current milestone pipeline |
| Model | Composer 2.5, non-Fast |
| Repository | `glinkplink/quietfactory` |
| Trigger | **PR merged** |
| Tools | Open Pull Request; Comment on Pull Request; PR approval disabled |

**Responsibilities:**

1. Normally does **nothing**.
2. Proceeds only after a gameplay milestone has exact-head `QF_PLAYTEST_READY` and subsequent human `PLAYTEST: PASS`.
3. Starts exactly **one** next authorized milestone from fresh current `main`.
4. Opens **one DRAFT PR**.
5. Does **not** merge or playtest.

Does **not** participate in the current-head review/fix loop.

### Deliberately abandoned (historical)

Cursor's generic PR-comment Automation trigger does **not** provide safe regex/body filtering, and bot-generated PR comments cannot reliably trigger another Cursor Automation. Therefore:

- separate Composer review-fixer top-level automation — **abandoned**
- separate final-reviewer top-level automation — **abandoned**
- bot-comment chaining between Cursor Automations — **abandoned**

The **Milestone Orchestrator** owns the complete machine gate for the current head.

---

## A. Core principles

### Human playtest time is scarce

The project has roughly **30 free Appetize minutes total**. Treat human playtesting as a **gated milestone resource**, not routine validation.

### Do not waste playtest time on machine-detectable defects

Do **not** spend Appetize time verifying defects that could have been discovered through:

- unit/integration tests
- GitHub `iOS CI`
- code review (Grok / independent final reviewer)
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

Successful playtest → **human/manual merge** → `QF — Next Milestone Starter` opens the next draft milestone from current `main`.

### Non-gameplay PRs

Infrastructure, automation, CI, docs, and tooling PRs **do not automatically trigger human playtests**.

---

## Current model bindings

| Role | Binding |
| --- | --- |
| Milestone orchestrator | Cursor Grok 4.6 High, non-Fast |
| Next milestone starter | Composer 2.5, non-Fast |
| Implementation worker | `composer-2.5[fast=false]` |
| Architecture escalator | Grok 4.6, read-only |
| Independent pre-playtest reviewer | `kimi-k3-high`, read-only |

Workflow semantics depend on roles, not providers. Changing a model binding does not require redesigning the automation protocol unless the role behavior itself changes.

---

### Top-level orchestration vs repo subagents

| Role | Where it lives |
|------|----------------|
| Milestone orchestration, Grok review, certification markers | **Top-level automation:** `QF — Milestone Orchestrator` |
| Post-merge next draft milestone | **Top-level automation:** `QF — Next Milestone Starter` |
| Routine code modifications / P0/P1 fixes | **Project subagent:** `.cursor/agents/implementation-worker.md` |
| Implementation-time architecture escalation | **Project subagent:** `.cursor/agents/architecture-escalator.md` (read-only) |
| Independent final pre-playtest review | **Project subagent:** `.cursor/agents/pre-playtest-reviewer.md` (read-only) — invoked **only** by the orchestrator |
| Human playtest | Human — comprehension / feel / fun / frustration / clarity |

**Normal implementation agents must not casually invoke the independent final reviewer.** Only `QF — Milestone Orchestrator` may call `pre-playtest-reviewer`, and only under the cost-discipline and provenance rules in the independent final reviewer section below.

Subagents return **structured results to the parent** and must **not** independently post `QF_GROK_*`, `QF_FINAL_*`, or `QF_PLAYTEST_READY` markers.

Seeing `QF_FINAL_STATUS` or `QF_PLAYTEST_READY` in a parent comment is **not itself evidence** that the independent reviewer executed.

---

### Milestone orchestrator — Grok review

The top-level orchestrator runs on **meaningful PR heads** for gameplay/product milestone PRs.

**Responsibilities:**

- review the **complete PR against `main`**, not only the latest commit
- enforce product/mechanics canon
- detect P0/P1 blockers
- examine architecture, gameplay correctness, UI/model state synchronization, tests, solvability, restart behavior, animation locks, scope drift, and related concerns
- invoke `implementation-worker` for valid P0/P1 fixes
- invoke `architecture-escalator` only when required
- **actually invoke** named `pre-playtest-reviewer` only after Grok PASS + exact-head CI green (on the CI-success run, or in the same run if CI is already green), with routing pack, and only certify from a validated child result. Never wait by ending the turn.
- post all `QF_*` certification markers in PR comments — never self-certify the Kimi gate

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

### Implementation worker (`implementation-worker`)

**Path:** `.cursor/agents/implementation-worker.md`

**Model:** `composer-2.5[fast=false]` — writable

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

The worker may escalate via `ARCHITECTURE_ESCALATION_REQUIRED`; the orchestrator decides whether to invoke `architecture-escalator`.

---

### Architecture escalation (`architecture-escalator`)

**Path:** `.cursor/agents/architecture-escalator.md`

**Model:** Grok 4.6 — read-only

The orchestrator (or implementation worker via escalation signal) may invoke `architecture-escalator` **only when**:

- gameplay semantics must change
- GameCore/UI ownership boundaries are unclear or must change
- SpriteKit/model synchronization requires architectural judgment
- there are materially different architectural choices with different long-term consequences
- the same defect has resisted **two** implementation-worker attempts

Do **not** escalate for ordinary implementation, straightforward fixes, routine tests, docs, small UI polish, or mechanical refactors with an obvious correct approach.

Architecture escalation is **advisory/read-only** unless explicitly authorized otherwise.

---

### Independent final reviewer (`pre-playtest-reviewer`)

**Path:** `.cursor/agents/pre-playtest-reviewer.md`

**Model:** `kimi-k3-high` — read-only

**Expensive final machine gate.** Runs **at most once per eligible candidate SHA**. Do not use continuously. Do not invent usage, token, dollar-cost, or savings estimates in docs or comments.

Architecture remains: Grok orchestrator → worker/escalator as needed → exact-head CI → **named** Kimi final gate. Do **not** introduce another automation or another reviewer role.

Invoked **only** by `QF — Milestone Orchestrator`, **only after**:

1. Grok review for the **exact current head** has zero P0/P1 findings
2. `iOS CI` succeeds on the **exact current head**
3. the PR is actually a **gameplay/playtest milestone**

#### Must actually invoke the named child

After exact-head Grok PASS + exact-head CI green, the parent **must explicitly invoke** `pre-playtest-reviewer` as a Cursor project subagent / Task delegation.

This is **not optional** and must **not** be treated as a conceptual role the parent may perform itself.

The parent **MUST NOT**:

- simulate the final reviewer
- perform another Grok/self-review and label it “independent”
- infer final PASS from Grok PASS
- infer final PASS from green CI
- infer final PASS from absence of known blockers
- synthesize what it believes Kimi would have returned
- emit `QF_FINAL_STATUS: PASS` merely because all earlier gates passed

Grok is the parent/orchestrator. Kimi is the independent final reviewer. Those are deliberately separate model executions.

Green CI + Grok PASS can **never** independently produce `QF_PLAYTEST_READY`.

#### Routing pack required in the parent Task prompt

The parent Task prompt **must** include a routing pack so the child can decide `ROUTING_OK` without repository exploration:

- exact candidate SHA
- `QF_GROK_HEAD` / `QF_GROK_STATUS` for that SHA
- exact-head CI run URL/status
- confirmation that the PR is a gameplay/playtest milestone

If the parent only says “review the PR,” the child correctly returns `ROUTING_OK: false`, or else cheats by reading the repo again. A child contract without a supplied routing pack is incomplete.

#### Cost discipline / review scope

- Route eligibility is checked **before** repository review. Failed routing exits before expensive repo reads/review.
- Production review scope is the **COMPLETE exact candidate diff against `main`** — the full milestone PR — independently reviewed.
- That means the full milestone PR diff, **not** a general repository tour.
- Grok findings must **not** substitute for Kimi independently reviewing that diff. Do not scope the review to Grok’s file list.
- Use minimal relevant canon/tests/context required by the candidate diff.
- No recursive subagents, MCP, browser/web search, or unrelated exploration.
- Do not claim Cursor guarantees literal zero harness/tool overhead on a routing failure; the instruction is to skip the expensive review loop.

#### Child result contract

A valid child result must contain, at minimum near the top:

```
REVIEWER_ROLE: pre-playtest-reviewer
REVIEWED_HEAD: <exact SHA>
ROUTING_OK: true
```

Then:

```
PRE-PLAYTEST FINDINGS

AUTOMATION GAPS

HUMAN-ONLY QUESTIONS

RESULT
```

with `RESULT` exactly `PASS` or `BLOCKED`.

The parent may summarize this result; it may **not** fabricate it. Retain enough child findings in the parent comment to show the final decision came from the independent child.

On routing failure the child returns `ROUTING_OK: false` with `REASON` and stops without production review.

#### Foreground / fail-closed provenance

The `pre-playtest-reviewer` invocation is a **foreground dependency** for certification. Wait for the child result before doing anything with `QF_FINAL_*`.

If any of the following occurs:

- `pre-playtest-reviewer` cannot be found
- Task/subagent invocation is unavailable
- child launch fails, crashes, times out, or returns an error
- child result is missing or lacks the required structure
- `ROUTING_OK` is not exactly `true`
- returned candidate SHA/routing evidence does not match the current candidate
- parent cannot determine whether the actual configured child completed

then **do not** emit `QF_FINAL_STATUS: PASS` or `QF_PLAYTEST_READY`. Do not substitute parent judgment. Stop the final gate and emit a clearly non-certifying operational marker such as:

```
QF_FINAL_GATE: ERROR
QF_FINAL_HEAD: <sha>
REASON: pre-playtest-reviewer result not obtained/validated
```

This is an **automation failure**, not a gameplay P0/P1 and not a Kimi `BLOCKED` review. Do **not** ask `implementation-worker` to “fix” an invocation/infrastructure failure.

#### PASS / BLOCKED provenance

The parent may emit:

```
QF_FINAL_HEAD: <sha>
QF_FINAL_STATUS: PASS
```

**only when all** of these are true:

1. exact-head Grok PASS exists
2. exact-head iOS CI is green
3. the parent actually delegated to the named `pre-playtest-reviewer`
4. that child completed
5. that child returned `ROUTING_OK: true`
6. that child returned the required structured result
7. that child's `RESULT` is exactly `PASS`
8. the result corresponds to the same exact candidate SHA

Only then may the parent emit:

```
QF_PLAYTEST_READY: <sha>
```

If the actual child result is `RESULT: BLOCKED`, the parent may emit:

```
QF_FINAL_HEAD: <sha>
QF_FINAL_STATUS: BLOCKED
```

and handle the actual P0/P1 findings via the existing same-PR fix loop.

**Question the child must answer:**

> Is there any material defect, contradiction, missing automated test, or machine-detectable uncertainty that should be resolved BEFORE scarce human playtest time is consumed?

The independent final reviewer must also:

- **not** assume Grok is correct merely because Grok passed
- block only for **P0/P1** machine-detectable issues
- **not** claim native visual inspection of screenshots (textual evidence only; visual inspection remains the orchestrator's responsibility)

**Desired certification sequence on pass (only with proven child provenance):**

```
QF_GROK_HEAD: <sha>
QF_GROK_STATUS: PASS

QF_FINAL_HEAD: <sha>
QF_FINAL_STATUS: PASS

QF_PLAYTEST_READY: <sha>
```

---

## C. Escalation rules

### Implementation worker should not escalate merely because a task is difficult

Escalate to the **`architecture-escalator`** project subagent when:

1. gameplay semantics must change
2. GameCore vs UI ownership is unclear
3. animation/model synchronization requires architectural judgment
4. two materially different implementations would produce different long-term architecture
5. two reasonable implementation-worker attempts failed on the same defect

### If orchestrator blocks (P0/P1)

1. Orchestrator invokes `implementation-worker` to fix valid P0/P1 issues on the **same PR branch**
2. Do **not** create a second PR
3. Do **not** weaken tests just to make them green
4. Push fixes when the orchestrator delegates push
5. Any new push **invalidates** previous review certification
6. Orchestrator review and `iOS CI` run again from the top

### If Grok PASS + CI green + pre-playtest-reviewer BLOCK

1. Treat the final-review finding as **blocking**
2. Orchestrator invokes `implementation-worker` to fix on the same PR
3. Push
4. Old Grok and final-review certifications become **stale**
5. Run the **full gate** again (Grok → CI → pre-playtest-reviewer)

### If final-gate WAITING_CI

Expected after Grok `PASS` when exact-head iOS CI is not green yet. Not an error. The `ios-ci.yml` success run continues the gate.

### If final-gate ERROR (child result not obtained/validated)

1. Treat as an **automation failure**, not a gameplay P0/P1
2. Emit `QF_FINAL_GATE: ERROR` (non-certifying)
3. Do **not** emit `QF_FINAL_STATUS: PASS` or `QF_PLAYTEST_READY`
4. Do **not** ask `implementation-worker` to “fix” invocation/infrastructure failure
5. Stop for human/operator resolution of the automation defect
6. Do **not** confuse `WAITING_CI` with `ERROR`

### Technical disputes

If Grok and the independent final reviewer genuinely disagree on a P0/P1, or if the implementation agent believes a reviewer finding is factually wrong, record:

```
QF_TECHNICAL_DISPUTE: <concise evidence-backed explanation>
```

Then **stop** and require **human resolution**. Do **not** hard-code another model as a permanent adjudicator.

---

## D. PR lifecycle

Exact lifecycle for a **gameplay milestone PR**:

1. Fresh `main` (from prior merge or bootstrap).
2. `QF — Next Milestone Starter` opens **one draft PR** for the next milestone (after prior `PLAYTEST: PASS`; disabled until validated).
3. **Draft opened** triggers `QF — Milestone Orchestrator`.
4. Implement (human or orchestrator-delegated `implementation-worker`).
5. Relevant local verification (tests, lint as applicable).
6. **Orchestrator** reviews full exact head.
7. If `BLOCKED` (P0/P1) → orchestrator invokes `implementation-worker` → push → **PR pushed** retriggers orchestrator from step 6.
8. When Grok `PASS` and exact-head `iOS CI` is not green: emit `QF_GROK_*` plus `QF_FINAL_GATE: WAITING_CI` and **end this run** (do not subscribe-and-exit).
9. When `ios-ci.yml` succeeds on that exact head (or when Grok `PASS` and CI are both already true in one run) → orchestrator **actually invokes** `pre-playtest-reviewer` once for that head with a routing pack, waits for the child result, and validates the child contract. Duplicate success events for the same SHA are a no-op.
10. If child `RESULT: BLOCKED` → orchestrator invokes `implementation-worker` → push → restart from step 6. If child result missing/invalid → emit `QF_FINAL_GATE: ERROR` and stop (do not self-certify).
11. When orchestrator posts provenance-backed `QF_PLAYTEST_READY` for the exact SHA, that exact artifact may be used for human playtesting.
12. Human records one of:
    - `PLAYTEST: PASS`
    - `PLAYTEST: FAIL`
13. **FAIL** → same milestone PR stays open; orchestrator delegates fixes; push restarts full exact-head gate before another playtest.
14. **PASS** → human manually merges.
15. **PR merged** triggers `QF — Next Milestone Starter` for the next draft milestone.

### What does NOT authorize human playtesting

| Condition | Authorizes playtest? |
|-----------|---------------------|
| Green CI alone | **No** |
| Grok PASS alone | **No** |
| Green CI + Grok PASS without proven `pre-playtest-reviewer` child result | **No** |
| `QF_FINAL_GATE: WAITING_CI` | **No** |
| Parent comment claiming final PASS without validated child contract | **No** |
| Final review PASS against a stale SHA | **No** |
| `QF_PLAYTEST_READY` for the **exact artifact SHA** with proven child PASS provenance | **Yes** |

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
- final review PASS
- `QF_PLAYTEST_READY` certification

makes those certifications **stale**.

The new head must pass the appropriate gates again:

```
new push → Milestone Orchestrator (Grok) → WAITING_CI if needed → ios-ci.yml success → pre-playtest-reviewer → QF_PLAYTEST_READY
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

## Protocol stability

This protocol is considered **stable** after the initial automation configuration merge.

- Do **not** redesign or rewrite automation architecture because a different model becomes fashionable or available.
- Model bindings are intentionally isolated from workflow semantics.
- Changing a model provider normally requires changing only the binding, not the pipeline.
- Modify this protocol only when observed production/validation behavior proves an assumption wrong, or the user explicitly changes workflow requirements.

After merge of the docs-lock PR, treat this document as **LOCKED** unless empirical validation exposes a real workflow defect.

---

## Implementation status

| Component | Status |
|-----------|--------|
| This protocol document | **Documented** — locked after docs-lock merge; CI-handoff correction (workflow-success wake-up) in this revision |
| `architecture-escalator` project subagent | **Documented** |
| `implementation-worker` project subagent | **Documented** |
| `pre-playtest-reviewer` project subagent | **Documented** — bound to `kimi-k3-high`; routing/model smoke observed; cost discipline and end-to-end provenance **not** validated |
| `QF — Milestone Orchestrator` | **Configured externally** — **ENABLED** — triggers: Draft opened, PR pushed, `ios-ci.yml` Success |
| `QF — Next Milestone Starter` | **Configured externally** — **DISABLED** pending validation |
| Bot-comment automation chaining | **Abandoned** — unsuitable with current Cursor Automation UI |
| Separate review-fixer / final-reviewer top-level automations | **Abandoned** — orchestrator owns full gate |

No additional automation components are planned before end-to-end validation.

Do not claim the orchestrator chain is validated until exact-head Grok PASS, exact-head CI, an observed `pre-playtest-reviewer` child delegation with a validated child contract, and provenance-backed `QF_FINAL_*` / `QF_PLAYTEST_READY` have all been exercised against gameplay milestone PR #1.
