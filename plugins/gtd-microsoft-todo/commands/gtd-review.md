---
description: Run GTD Weekly Review against Microsoft To Do (active diagnostic, interactive)
---

Run the **Weekly Review** workflow from the `gtd` skill against the Microsoft To Do backend.

**Backend tools**: `mcp__microsoft_todo__*` MCP tools (read + write, but always confirm before write).

**Required reading**: load `references/weekly-review.md` from the gtd skill before starting. The diagnostic checklist there is the source of truth for what to check.

**Diagnostic queries to run** (in order):

1. **Inbox count** — items in `📥 Inbox`. Goal: zero.
2. **Orphan projects** — items in `🎯 Projects` whose title doesn't appear in any next-action context list (heuristic: no shared substring with any item across `@*` lists). Flag for user review.
3. **Stale waiting-for** — items in `⏳ Waiting For` where `createdDateTime` is more than 14 days ago. List with age.
4. **Stale next-actions** — items in `@*` context lists where `createdDateTime` is more than 21 days ago.
5. **Completed clutter** — tasks completed more than 7 days ago still showing in active lists. Suggest archive (Microsoft To Do does not auto-archive; user can hide completed).
6. **Long-running projects** — projects with no completed sub-task in the last 30 days.

**Output format**:

Group findings by severity (use the punch-list pattern from `references/weekly-review.md`):

```
🔴 정리 필요 N개
  - <description>
🟡 검토 권장 N개
  - <description>
🟢 시스템 건강도: <one-liner>
```

**Walk-through**:
After showing the punch list, walk the user through 🔴 items one at a time. For each, present options (define next action / move to Someday / drop / nudge / etc.) and apply their choice via MCP. Move to 🟡 if user wants to continue.

**Important**:
- Always confirm before destructive actions (delete, archive)
- If user has limited time, prioritize: Inbox-zero → Projects orphans → Stale waiting-for. Skip the rest.
- Optional Stage 3 (Creative — higher horizons reflection): only if user explicitly asks or there's clearly time

Optional argument (skip stages, time-budget hint): $ARGUMENTS
