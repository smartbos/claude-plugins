---
description: Query GTD lists in Microsoft To Do (read-only — show context, waiting-for, etc.)
---

Run the **Query** workflow from the `gtd` skill against the Microsoft To Do backend.

**Backend tools**: `mcp__microsoft_todo__*` MCP tools (read-only operations).

**Behavior**:
1. Parse the user's natural-language query: $ARGUMENTS
2. Map to the appropriate list(s):
   - "@phone", "@전화" → `@전화` list
   - "@computer", "@컴퓨터" → `@컴퓨터` list
   - "waiting for", "기다리는", "지연" → `⏳ Waiting For` list
   - "projects", "프로젝트" → `🎯 Projects` list
   - "today", "오늘" → My Day surface
   - "completed today", "오늘 한 일" → completed tasks across all lists, filter today
   - "stale", "묵은", "오래된" → run age-based filter (>14d for waiting-for, >21d for next-actions)
3. Read the matching items
4. Return compactly — task titles, optionally with age/due date when relevant
5. Do NOT modify anything. Query is read-only.

If the query is ambiguous, ask one short clarifying question before executing.

Query: $ARGUMENTS
