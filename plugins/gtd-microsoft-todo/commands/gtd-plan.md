---
description: Plan today's commitments by selecting from GTD Next Action lists in Microsoft To Do
---

Run the **Plan today** workflow from the `gtd` skill against the Microsoft To Do backend.

**Backend tools**: `mcp__microsoft_todo__*` MCP tools.

**Today surface**: Microsoft To Do "My Day". Mark selected tasks with the `isReminderOn` + `My Day` flag (use the MCP's add-to-my-day tool if available, else set due date to today as fallback).

**Behavior**:
1. Read all items from context lists (`@컴퓨터`, `@전화`, `@사무실`, `@집`, `@외출`, `@언제든`)
2. Consider today's day-of-week and (if user mentions) calendar/working hours
3. Propose 3–7 items for today — lean toward fewer, never more than 7
4. Show proposed list to user, await confirmation or adjustment
5. After confirmation, add chosen items to "My Day"
6. Confirm: `✓ 오늘 N개 commit: [titles]`

Do not silently auto-select. Always propose first, then act on user confirmation.

Optional hint (preferred contexts, energy level, time available): $ARGUMENTS
