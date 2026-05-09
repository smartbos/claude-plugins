---
description: Capture an item to GTD Inbox in Microsoft To Do (no clarification, fast)
---

Run the **Capture** workflow from the `gtd` skill against the Microsoft To Do backend.

**Backend tools**: `mcp__microsoft_todo__*` MCP tools (e.g. `list_lists`, `create_task`).

**Inbox list**: `📥 Inbox`. If the list does not exist, create it before adding the task.

**Behavior**:
- Add the user's exact phrasing as the task title — do not rewrite, expand, or categorize
- Confirm with one line: `✓ Inbox: "<title>"`
- Do not ask clarifying questions at this stage; capture is intentionally dumb

Item to capture: $ARGUMENTS
