# Quiet Factory — Decision Log
Last updated: 2026-08-30

Record durable product/architecture decisions here.

Format:
- date
- decision
- rationale
- status

---

## 2026-08-29 — Premium upfront model

**Decision:** Launch target is $1.99 paid upfront.

**Rationale:** The product thesis is built around eliminating freemium friction. Ads, subscriptions, coins, energy systems, and consumable IAP would undermine positioning.

**Status:** Active.

---

## 2026-08-29 — iOS-first

**Decision:** V1 targets iOS only.

**Rationale:** Reduces scope and allows a native stack optimized for App Store launch within 2–4 weeks.

**Status:** Active.

---

## 2026-08-29 — Native technical stack

**Decision:** Prefer Swift + SpriteKit + SwiftUI over Unity for V1.

**Rationale:** Game scope is mechanically small, 2D, portrait, and iOS-only. Native tooling minimizes runtime/build overhead and integrates cleanly with Apple platform APIs.

**Status:** Active unless prototype reveals a concrete blocker.

---

## 2026-08-29 — Gameplay rules separated from rendering

**Decision:** Core game state and rules must be deterministic and independent of SpriteKit.

**Rationale:** Required for solver, procedural generation, automated tests, difficulty scoring, reproducible bugs, and deterministic daily puzzles.

**Status:** Active.

---

## 2026-08-29 — Conveyor sequencing is the differentiator

**Decision:** The initial prototype combines tap-away spatial blocking with a limited conveyor/buffer matching layer.

**Rationale:** Basic tap-away alone risks being too shallow. The buffer creates a second decision layer without increasing control complexity.

**Status:** Prototype hypothesis; must be validated.

---

## 2026-08-29 — No backend in V1

**Decision:** Gameplay and daily puzzle must work without a server.

**Rationale:** Lowest GTM/operational friction, lower cost, fewer failure modes, faster App Store path.

**Status:** Active.

---

## 2026-08-29 — Procedural generation requires solver validation

**Decision:** Generated levels may not ship solely because a generator produced them.

**Rationale:** Random-feeling or unsolvable content would destroy trust. Every generated campaign/daily board must be solver-valid.

**Status:** Active after prototype gate.

---

## 2026-08-29 — Prototype before production

**Status:** Active.

---

## 2026-08-30 — CI handoff is a new orchestrator run, not a paused turn

**Decision:** `QF — Milestone Orchestrator` stays one of exactly two automations. iOS CI success wakes that **same** orchestrator via **Workflow run completed** (`ios-ci.yml`, Success). Grok must not “subscribe and end the turn” to wait for CI.

**Rationale:** Cursor Automations do not resume a finished run when GitHub CI later completes. Observed on PR #1 `b7dd80a…`: Grok ended after PASS; iOS CI went green; Kimi never ran. A third automation is not required.

**Status:** Active.
