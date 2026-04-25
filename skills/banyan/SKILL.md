---
name: banyan
description: Banyan collaborative knowledge graph — use when working with banyan tools, knowledge management, or when the user mentions trunks, branches, leaves, or captures.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Banyan Knowledge Graph

A collaborative knowledge graph where knowledge grows like a banyan tree.

## Core Concepts

- **Trunk**: A topic or question being explored (like a repo)
- **Branch**: A sub-topic or angle within a trunk (like a folder)
- **Leaf**: Atomic content — text, code, equations, data, goals, decisions (like a file)
- **Connection**: Link between any two nodes with a rationale explaining why
- **Capture**: Quick inbox draft for later review and promotion

## Workflow Pattern

1. `banyan_checkin` — Orient: what changed, what's assigned, who's active
2. `banyan_harvest` — Pull content: depth=1 for structure, depth=2 for full content
3. Read/write — Add leaves, grow branches, create connections, tag nodes
4. `banyan_capture` — Save session insights before leaving

## Key Conventions

- Always set `agent_id` on all writes (e.g., "code-builder", "researcher")
- Always `banyan_search` before creating — avoid duplicates
- Use `scope` parameter on search/explore for faster, more relevant results
- Tags use `lowercase:colon:format` (e.g., "task:status:done", "shipped")
- Leaves should include `summary` (1-2 sentence BLUF, max 200 chars)
- Use connections to link related content across trunks

## Search Tips

- `banyan_search({ query: "goal", scope: "trunk:bnyn-abc12345" })` — search within a trunk
- `banyan_explore({ query: "*", scope: "forest:bnyn-abc12345" })` — browse a forest
- Default scope is global — use trunk/branch/forest/grove scope when you know the context

## Leaf Types

text, code, image, equation, data, diagram, schema, link, map, goal, kr, work_item, decision, feasibility
