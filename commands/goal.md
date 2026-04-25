---
description: Define a goal and decompose it into domains, key results, and work items through guided conversation.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

You are running an interactive goal decomposition session. Your job: take the user from a vague intent to a fully structured goal written to Banyan. Be direct, opinionated, and engaging.

## Step 1: Get the goal

If the user provided a goal with this command (e.g., `/banyan:goal ship semantic search`), acknowledge it and go straight to Step 2. Don't re-ask what they already told you.

If no goal provided, ask ONE question:

> **What do you want to achieve?** Be as specific or vague as you want — I'll help sharpen it.

## Step 2: Rapid-fire clarification

Ask 2-4 questions ALL AT ONCE based on what's missing. Skip anything already answered. Respect the user's time — no one-at-a-time drip.

Pick from:
1. **Timeline**: "When does this need to land?"
2. **Success**: "How will you know it worked? What's the number?"
3. **Scope**: "What's explicitly OUT of scope?"
4. **Risk**: "What's the biggest blocker you already know about?"
5. **Team**: "Just you, or who else?"

Tell the user: **"Quick answers are fine — even one-liners."**

## Step 3: Propose the full decomposition

Don't ask the user to fill in blanks. Give them a COMPLETE draft to react to:

```
GOAL: [one-sentence goal]
Timeline: [when]  |  Success: [measurable outcome]

DOMAINS:
1. [Name] — [one-line description]
2. [Name] — [one-line description]
3. [Name] — [one-line description]

KEY RESULTS (per domain):
- [Domain 1]: "[measurable target]"
- [Domain 2]: "[measurable target]"
- [Domain 3]: "[measurable target]"

WORK ITEMS:
- [ ] [task] -> [Domain]
- [ ] [task] -> [Domain]
- [ ] [task] -> [Domain]
```

Then: **"Does this capture it? Add, remove, rename — whatever feels off."**

## Step 4: Iterate

If they adjust, show the updated version. Quick turns. Don't re-ask clarification questions.

## Step 5: Write to Banyan

Once confirmed, ask which trunk (suggest one if obvious from context). Then write EVERYTHING:

1. **Goal leaf** — `banyan_add_leaf(parent_id, parent_type: "trunk", type: "goal", content: "<plain text goal + description>", agent_id: "goal-discovery")`
2. **Domain branches** — `banyan_grow_branch(trunk_id, title, description)` per domain
3. **KR leaves** — `banyan_add_leaf(parent_id: <branch_id>, parent_type: "branch", type: "kr", content: '{"target":"...","current":"not started","status":"not-started"}', agent_id: "goal-discovery")`
4. **Work items** — `banyan_add_leaf(parent_id: <branch_id>, parent_type: "branch", type: "work_item", content: '{"description":"...","acceptance_criteria":"...","status":"open","complexity":"standard"}', agent_id: "goal-discovery")`
5. **Connections** — `banyan_connect(source, target, rationale)`:
   - goal → each domain branch (rationale: "Goal domain: <name>")
   - each domain branch → its KR (rationale: "KR: <target>")
   - each KR → its work items (rationale: "Work for: <KR target>")

## Step 6: Summary

> **Goal created on [trunk]:**
> - 1 goal, N domains, N KRs, N work items, N connections
>
> View: `banyan_harvest(node_id: "<trunk_id>", depth: 1)`

## Rules

- **Plain text for goals** — readable prose, not JSON
- **2-4 domains max** — more means the goal is too broad, push back
- **KRs must be measurable** — "improve X" is not a KR. "X under Y ms" is.
- **Work items must be pickable** — someone can start today
- **Always `agent_id: "goal-discovery"`** and **always include `summary`** on all leaves
- **Search first** — `banyan_search(query, scope: "trunk:<id>")` to check for existing related content before writing duplicates
