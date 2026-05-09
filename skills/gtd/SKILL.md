---
name: gtd
description: Getting Things Done (GTD) workflow — capture, process, plan, query, and weekly review for personal task management. Backend-agnostic: works with any task system that supports lists, tasks, and sub-tasks. Use when the user wants to capture an action item ("inbox에 추가", "할 일로 등록"), process inbox ("inbox 처리", "정리하자"), plan today ("오늘 할 일 정리", "plan today"), query by context ("@phone 보여줘", "waiting for 뭐 있지"), or run weekly review ("주간 리뷰", "weekly review"). Calling commands or wrapper plugins must inject backend tool context; otherwise this skill asks the user which backend to use.
---

# GTD (Getting Things Done)

Procedural knowledge for running David Allen's GTD methodology against an abstract task backend. Backend choice is the responsibility of the calling context (a wrapper plugin, a slash command, or the user directly).

## Backend interface (required)

This skill assumes a backend exposing three primitives:

- **Lists** — named containers for tasks (e.g. "Inbox", "@phone", "Projects")
- **Tasks** — items with: title, optional due date, completion state, optional notes
- **Sub-tasks / checklist items** — nested under a task (used for project next-actions)

Before doing real work, confirm a backend is wired in. Look for these signals:
1. Available MCP tools matching `mcp__*todo*__*`, `mcp__*tasks*__*`, `mcp__*reminders*__*`, etc.
2. An explicit hint in the calling command's body (e.g. "Backend: Microsoft To Do via mcp__microsoft_todo__\*")
3. The user mentioning a backend by name in conversation

If none, ask the user which backend to use and reference `references/backend-examples.md` for setup hints. Do not silently default.

## The five workflows

GTD has five stages. This skill exposes each as an entry point. Pick the one that matches the user's request — do not run all stages on every invocation.

### 1. Capture (입력)

Goal: get the item off the user's mind into Inbox, fast. No clarification yet.

- Add a task to the **Inbox** list with the user's exact phrasing as the title
- Do not rewrite, expand, or categorize at this stage — capture is intentionally dumb
- If the Inbox list does not exist on the backend, create it
- Confirm with one short line: `✓ Inbox: "<title>"`

### 2. Clarify & Organize (처리)

Goal: empty the Inbox by deciding the nature of each item.

For each Inbox item, walk the user through this decision tree:

```
Is it actionable?
├─ No → File as Reference (or delete) / move to Someday/Maybe
└─ Yes → What's the very next physical action?
         ├─ Takes < 2 min → Do it now, mark complete
         ├─ Delegated     → Move to "Waiting For" with who + when
         ├─ Multi-step    → Create a Project (in "Projects" list); add the next action to a context list
         └─ Single-step   → Move to a context list (@phone, @computer, @home, etc.)
```

Critical clarification rules:
- **Next action must be a verb** ("Bob에게 회신할 3줄 초안 작성") not a topic ("Bob 이메일")
- **One next action per project at a time**; the rest stay as project notes
- If the user wrote a vague item, ask one clarifying question before moving it

Process items one at a time and confirm each move. Ask the user before deleting anything.

### 3. Plan today (오늘 계획)

Goal: pick today's focused commitments from Next Actions.

1. Read all context lists (@phone, @computer, @home, @errands, @anywhere)
2. Cross-reference with: today's day of week, working hours, known calendar (if available)
3. Propose 3–7 items for today (not more — overcommitment is the enemy)
4. Move chosen items to the backend's "today" surface (e.g. Microsoft To Do "My Day", or set due date to today)
5. Show the user the final list

Lean toward fewer items. GTD's strength is honest commitment, not maximum throughput.

### 4. Query (조회)

Goal: answer the user's specific question about current task state.

Map the question to a list:
- "@phone에 뭐 있지?" → @phone list
- "Bob한테 기다리는 거?" → Waiting For list, filter title containing "Bob"
- "오늘 뭐 했지?" → completed tasks today, across all lists
- "프로젝트 몇 개?" → Projects list count
- "stale waiting-for?" → Waiting For where age > 14 days

Return the result compactly. Do not auto-modify on a query — read-only by default.

### 5. Weekly Review (주간 리뷰)

Goal: keep the system trustworthy by surfacing what slipped.

This is the most important and most skipped GTD ritual. Run it as an active diagnostic, not just a checklist. Detail in `references/weekly-review.md`.

Quick diagnostic signals:
- **Orphan project** — Project with no next action in any context list
- **Stale waiting-for** — item older than 14 days; nudge or escalate
- **Drift** — completed tasks not yet archived (keeps lists noisy)
- **Empty contexts** — context list with no items for 30+ days; consider removing
- **Inbox not zero** — items lingering more than 48h is a smell

Walk the user through findings interactively, decision by decision.

## List & context conventions

Default list scheme (override per backend if user prefers different):

| GTD bucket          | List name        |
|---------------------|------------------|
| Inbox               | `📥 Inbox`       |
| Projects            | `🎯 Projects`    |
| Waiting For         | `⏳ Waiting For` |
| Someday/Maybe       | `💭 Someday`     |
| Next actions (by context) | `@컴퓨터`, `@전화`, `@사무실`, `@집`, `@외출`, `@언제든` |

Six contexts is the recommended balance. More creates decision fatigue; fewer loses meaning. See `references/list-conventions.md` for rationale and customization.

## When to read references

- **Weekly Review (stage 5)** — always read `references/weekly-review.md` before running. The interactive diagnostic depends on its checklist.
- **Setting up a new backend** — read `references/backend-examples.md` for mappings between GTD primitives and concrete backends (Microsoft To Do, Todoist, Apple Reminders, generic markdown).
- **List naming questions** — `references/list-conventions.md` explains why six contexts, why emoji prefixes, when to deviate.

## Principles to keep

- **Capture is dumb, clarify is smart**: never block capture on classification.
- **Trust the system, not your memory**: if it's not in the system, it doesn't exist.
- **Next action = physical, visible verb**: "이메일 답장" is not a next action; "회신 3줄 초안 작성" is.
- **Two-minute rule wins**: if it takes under 2 min, do it during clarify, never queue it.
- **Weekly review is the contract**: skip it and the whole system rots within a month.
