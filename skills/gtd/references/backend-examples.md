# Backend mapping examples

How GTD's abstract primitives (Lists, Tasks, Sub-tasks) map to specific task management backends. The `gtd` skill itself is backend-agnostic; this reference helps you (or a wrapper plugin) bridge.

## Microsoft To Do

**MCP**: `@mag-cie/mcp-microsoft-todo` (or any Microsoft Graph-based MCP)

**Mapping**:

| GTD primitive   | Microsoft To Do equivalent | API surface |
|-----------------|---------------------------|-------------|
| List            | List (`todoTaskList`)     | `GET /me/todo/lists`, `POST /me/todo/lists` |
| Task            | Task (`todoTask`)         | `POST /me/todo/lists/{id}/tasks` |
| Sub-task        | Step (`checklistItem`)    | `POST /me/todo/lists/{id}/tasks/{taskId}/checklistItems` |
| Today           | "My Day"                  | Add task to My Day flag |
| Due date        | `dueDateTime`             | ISO timestamp |
| Notes           | `body.content`            | Plain text or HTML |
| Completed       | `status: completed`       | PATCH on task |

**Today mechanism**: Microsoft To Do has a native "My Day" feature. Adding a task to My Day is non-destructive (the task stays in its original list). Use this for "Plan today" workflow.

**Authentication**: Device code flow. First-time setup runs `npx -y @mag-cie/mcp-microsoft-todo --auth`, user signs in at `https://login.microsoft.com/device`. Token cached at `~/.mcp-microsoft-todo/token-cache.json`.

**Gotchas**:
- Personal accounts (outlook.com/hotmail.com/live.com) require `MS_TENANT=consumers` env var
- Org/tenant policies may block device code consent — admin consent URL: `https://login.microsoftonline.com/{tenant}/adminconsent?client_id=6ea8909b-95e0-4ef0-8b48-d5910f164c6a`
- `linkedResource` field useful for attaching external links (e.g., GitHub issue, Obsidian note path) to a task

## Todoist

**MCP**: Multiple community MCPs exist (search "todoist mcp")

**Mapping**:

| GTD primitive | Todoist equivalent |
|---------------|--------------------|
| List          | Project            |
| Task          | Task               |
| Sub-task      | Sub-task (indented) |
| Today         | Today filter view  |
| Due date      | `due_string` or `due_date` |
| Notes         | `description`      |

**Today mechanism**: Set `due` to "today". Todoist's Today view auto-aggregates.

**Gotchas**:
- Todoist uses "Project" terminology where GTD uses "List". Reuse anyway — naming is internal.
- Labels (Todoist) ≠ Lists. Don't use labels for contexts; use Projects. Labels are for cross-cutting tags.

## Apple Reminders

**MCP**: `realYushi/my-gtd-buddy` patterns; native EventKit access via various MCPs

**Mapping**:

| GTD primitive | Apple Reminders equivalent |
|---------------|----------------------------|
| List          | List                       |
| Task          | Reminder                   |
| Sub-task      | Sub-task (iOS 13+)         |
| Today         | Today smart list           |
| Due date      | `dueDate`                  |
| Notes         | `notes`                    |

**Today mechanism**: Set due date to today. Reminders' "Today" smart list aggregates.

**Gotchas**:
- macOS-only via EventKit; cloud sync required for cross-device
- Sub-tasks API was limited pre-iOS 13; check MCP capabilities

## Generic Markdown (no MCP)

For users without any task backend, fall back to a markdown file structure.

**Mapping**:

```
~/gtd/
├── inbox.md
├── projects.md
├── waiting-for.md
├── someday.md
└── contexts/
    ├── computer.md
    ├── phone.md
    └── ...
```

Each file is a flat checklist (`- [ ] task title`). Sub-tasks via indentation. Today is a query (e.g., a section header or a separate `today.md` regenerated daily).

**Gotchas**:
- No native "completed at" timestamp — append `(✓ 2026-05-09)` to title or use frontmatter
- No native "due date" — embed in title (`- [ ] 2026-05-15 — Submit report`)
- Sub-task semantics weak; consider one task = one file for projects

## Pattern: how a wrapper plugin injects backend context

A `gtd-<backend>` plugin's command typically reads:

```markdown
# /gtd-capture

You are using the `gtd` skill's Capture workflow.

Backend: Microsoft To Do via the `mcp__microsoft_todo__*` MCP tools.
- Inbox list name: "📥 Inbox"
- If list missing, create it with mcp__microsoft_todo__create_list

Proceed with capture for: $ARGUMENTS
```

The skill body (this file's parent SKILL.md) provides the workflow logic; the plugin command wires it to a concrete backend. Skill stays clean; plugin handles dependency injection.
