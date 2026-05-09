---
description: Process GTD Inbox items in Microsoft To Do (interactive clarify & organize)
---

Run the **Clarify & Organize** workflow from the `gtd` skill against the Microsoft To Do backend.

**Backend tools**: `mcp__microsoft_todo__*` MCP tools.

**Standard list mapping** (create any missing on first need):
- Inbox: `📥 Inbox`
- Projects: `🎯 Projects`
- Waiting For: `⏳ Waiting For`
- Someday: `💭 Someday`
- Contexts: `@컴퓨터`, `@전화`, `@사무실`, `@집`, `@외출`, `@언제든`

**Behavior**:
1. Read all items currently in the Inbox list
2. If empty, tell the user "📥 Inbox 비어있음" and stop
3. Walk items one-by-one through the GTD decision tree (skill defines it)
4. For each item: confirm decision with user, then move/transform via MCP tools
5. After all items processed, summarize: `✓ N items processed → moved to: ...`

Do NOT bulk-process or auto-classify. One item, one decision, one user confirmation.

Optional argument (filter or limit): $ARGUMENTS
