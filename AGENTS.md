# Agent instructions

Read in this order:

1. [MASTER_PLAN.md](./MASTER_PLAN.md) — durable product thesis, scope, architecture, and constraints.
2. [RUNTIME_STATE.md](./RUNTIME_STATE.md) — current project state and active objective.
3. [DECISIONS.md](./DECISIONS.md) — durable decisions; treat these as authoritative unless explicitly superseded.
4. [NEXT_ACTIONS.md](./NEXT_ACTIONS.md) — current tactical work queue.
5. [AGENT_HANDOFF.md](./AGENT_HANDOFF.md) — implementation conventions and handoff requirements.

**Specialist exception:** Narrowly scoped read-only specialist subagents may follow the smaller read set defined in their own `.cursor/agents/<role>.md` when that role file explicitly overrides this bootstrap read order. This exists so expensive final reviewers (for example `pre-playtest-reviewer`) are not forced to ingest the full implementation bootstrap merely to perform one review. Normal implementation agents retain the order above.

Rules:

- Read the runtime docs before making substantive changes.
- Explicit current user instructions override repo docs.
- Do not silently change product scope or durable decisions.
- Keep game rules deterministic and independent from rendering.
- Do not jump ahead of the current prototype gate.
- After meaningful implementation work, update RUNTIME_STATE.md and NEXT_ACTIONS.md.
- Update DECISIONS.md only when an actual durable decision changes.
- Keep AGENTS.md lean; canonical detail belongs in the linked docs.
- GitHub `iOS CI` is the authoritative Apple/Xcode validation loop.
- A commit is not iOS-verified unless CI passes for that exact SHA.
- Inspect and fix CI failures; do not suppress tests or weaken the workflow.
