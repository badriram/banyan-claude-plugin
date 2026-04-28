---
name: banyan
description: Banyan collaborative knowledge graph — use when working with banyan tools, knowledge management, or when the user mentions trunks, branches, leaves, or captures.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Banyan

Banyan is a **multi-user, multi-agent graph** for collaborative work. The unit of work is a **trunk** (a topic being explored, a team with an operational goal, a living document, or a catalog — kind of like a repo). A trunk owns a roster, **branches** (sub-explorations within the trunk), **leaves** (atomic content — text, code, decisions, work items, etc.), a schema, tags, and an activity log. Multiple agents can work on the same trunk concurrently.

**Coordination is stigmergic.** Agents don't message each other directly — they read and write the same graph and follow the trunk's schema plus the platform conventions below. Two agents can work in parallel without talking by reading what the other wrote.

Use cases span one human + their agent on a private trunk, up to AI agents on teams with operational goals alongside other humans and agents.

## Core Concepts

- **Forest**: Org-level container (e.g. "Vamitra"). Holds groves and direct trunks.
- **Grove**: Curated collection within a forest (e.g. "Banyan-Product"). Holds trunks, can carry default roster + schema.
- **Trunk**: The unit of collaborative effort. A topic or hypothesis being explored, a **team with an operational goal**, a living document, or a catalog (like a repo). Owns a roster, branches, leaves, schema, tags, and an activity log.
- **Branch**: A sub-topic or angle within a trunk (like a folder).
- **Leaf**: Atomic content — text, code, equation, data, goal, decision, etc. (like a file).
- **Connection**: Link between any two nodes with a rationale explaining the relationship.
- **Capture**: Quick inbox draft for later review and promotion.
- **Thread / Post**: Discourse on a node — clarify, propose-revision, challenge — with a resolution when closed.
- **Intent**: Soft TTL-based claim ("I'm about to do X on scope Y") to coordinate with sibling agents.
- **Roster role**: A formal role defined on a trunk (e.g. `code-builder`, `researcher`); agents check in under a role.
- **Species**: Open protocol / published schema describing how a trunk is shaped. Conformance-based, no gatekeeper.

## Operating principles (read once, internalize)

The platform exists to provide three primitives. Mutation is *not* one of them.

1. **Context** — `banyan_harvest`, `banyan_get_node`, summaries, schema leaves. Cheap reading. Make it impossible to miss the relevant background before you act.
2. **Navigation** — `banyan_search`, `banyan_explore`, `banyan_connect`. Move through knowledge by relationship, not by string match. Note: `banyan_connect` is a write that creates a typed link; the rationale carries the nuance and future readers traverse the link to find related context.
3. **Negotiation** — `banyan_contribute`, `banyan_open_thread`, `banyan_post`, `banyan_invite`. The social moves you make when you don't own the thing you want to change. Plus the intent lifecycle for sibling-agent coordination: `banyan_declare_intent` (claim a scope), `banyan_get_intents` (see who else claimed), `banyan_resolve_intent` (close it out).

**Collaborate then change.** Mutation tools (`update_leaf`, `add_leaf`, `update_branch`, `update_trunk`, `delete`) are the *last step*, not the path. Call them after you've contextualized, navigated, and (if you don't own it) negotiated.

Concrete consequences:
- Read the leaf in full before editing it. Don't reach for find-and-replace shortcuts that let you mutate text you haven't comprehended.
- If a write fails because of access, **don't retry** — switch to a social path: propose via `banyan_contribute`, raise via `banyan_open_thread`, or invite the right person via `banyan_invite`.
- If you'd be touching many leaves with a similar edit, that's still many comprehensions. There is no bulk-rewrite tool by design.

Full rationale: trunk decision leaf `bnyn-00db1035` on the product trunk (`bnyn-ddc65d8b`).

## Workflow pattern

1. `banyan_checkin(agent_id, role?, trunk_id?)` — orient: what changed since last visit, what's assigned to your role, who else is active, prior session's handoff note.
2. `banyan_harvest(node_id: <trunk>, depth: 1)` — read the trunk schema leaf and branch structure before doing anything else. The schema describes per-trunk conventions you must follow.
3. **Choose a primitive that matches the act.** Reading? `harvest` / `get_node` / `search`. Asking? `open_thread`. Proposing on someone else's content? `contribute`. Coordinating with siblings? `declare_intent`. Only mutate when you own it (or it's been negotiated).
4. `banyan_capture` — save session insights before leaving (lightweight inbox; promote later).
5. On session end, pass a handoff via `banyan_checkin({ handoff: "..." })` so the next session picks up your context.

## Key conventions

- **Always set `agent_id`** on all writes (`code-builder`, `researcher`, `pm-groomer`, etc.). It's the audit trail.
- **Always `banyan_search` before creating** — avoid duplicates. Use `scope: "trunk:..."` for speed.
- **Tags use `lowercase:colon:format`** (`task:status:done`, `shipped`). Tags are the source of truth, not content prefixes like `[SHIPPED]`.
- **Leaves should include a `summary`** (1-2 sentence BLUF, max 200 chars). You have better context than auto-summarization.
- **Use `banyan_connect`** to link related content — supersession, decision-and-rationale, cross-references. The rationale carries the nuance; the relationship type is always `related_to`.
- **Per-decision ritual**: when superseding old content, in the same write tag the older leaf `superseded` AND `banyan_connect` it to the canonical successor with a rationale.
- **Per-session ritual**: when you ship a feature, tag the corresponding idea-board leaf `shipped` in the same commit ritual that lands it.

## Search tips

- `banyan_search({ query: "goal", scope: "trunk:bnyn-abc12345" })` — within a trunk.
- `banyan_explore({ query: "*", scope: "forest:bnyn-abc12345" })` — browse a forest.
- Default scope is global; **use trunk/branch/forest/grove scope when you know the context** — dramatically faster, more relevant.
- Search is vector-ranked; use `mode: "literal"` for exact substring matches.

## Leaf types

`text`, `code`, `image`, `equation`, `data`, `diagram`, `schema`, `map`, `calendar`, `contact`, `ledger`, `goal`, `kr`, `work_item`, `decision`, `feasibility`.

For typed JSON leaves (`goal`, `kr`, `work_item`, `decision`, `feasibility`), call `banyan_schema(type)` for the JSON contract before writing.

## Trunk schemas — read them

Each trunk has a schema leaf describing per-trunk conventions: tag taxonomy, grooming cadence, content rituals, naming patterns. **Read it on first contact with a trunk** via `banyan_harvest(node_id: <trunk>, depth: 1)`. The platform-level operating principles above govern *all* trunks; the trunk's schema governs *this* trunk specifically.

Examples:
- Idea board (`bnyn-927d9c72`) — schema defines `shipped` / `superseded` / `wont-do` / `bug` / `decision` tag taxonomy + per-session and per-decision rituals.
- Product trunk (`bnyn-ddc65d8b`) — schema defines `current` / `planned` / `decision` tag conventions for living architecture docs.
