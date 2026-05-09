# List & Context Conventions

Why the default scheme looks the way it does, and when to deviate.

## Default lists

| Bucket           | Name             | Purpose |
|------------------|------------------|---------|
| Inbox            | `📥 Inbox`       | Unprocessed captures. Should trend toward zero daily. |
| Projects         | `🎯 Projects`    | Multi-step outcomes. One task per project; sub-tasks for milestones. |
| Waiting For      | `⏳ Waiting For` | Delegated/blocked items. Title format: `<who> — <what>` |
| Someday/Maybe    | `💭 Someday`     | Possible-but-not-now. Reviewed weekly. |
| Reference        | (not in backend) | Knowledge → goes to notes/wiki, not task system |

## Default contexts (six)

| Context     | Use when |
|-------------|----------|
| `@컴퓨터`   | Requires laptop/desktop (writing, coding, research) |
| `@전화`     | Requires phone calls or messaging |
| `@사무실`   | Requires being at the office (printers, in-person, hardware) |
| `@집`       | Home-bound (errands, family, deliveries) |
| `@외출`     | Out-and-about (shops, banks, in-person services) |
| `@언제든`   | Pure thinking, planning, low-cost any-time tasks |

## Why six contexts

- **Fewer than 4** loses GTD's filtering value. The point of contexts is "I'm at the airport with 20 minutes — what can I knock out right now?" Without enough granularity, every context feels the same.
- **More than 8** creates decision fatigue at capture time. "Is this @phone or @계약? @외부미팅 or @사무실?" The categorization itself becomes a chore.
- **Six is empirically the sweet spot** for most knowledge workers. Sales/field roles may need different splits (e.g., `@고객사`, `@차량이동`).

## Why emoji prefixes

- Visual scanning — `📥` jumps out faster than reading "Inbox"
- Sort order — emoji typically sorts above `@` and ASCII letters, so meta-lists rise to the top
- Backend-friendly — Microsoft To Do, Todoist, etc. all render emoji in list names

If a backend doesn't render emoji well or the user prefers plain ASCII, use:
- `_Inbox`, `_Projects`, `_Waiting`, `_Someday` (underscore sorts above letters)
- Plain: `Inbox`, `Projects`, etc.

## Context customization patterns

### Energy-based contexts (alternative)
For users whose constraint isn't location but cognitive state:
- `@deep` (focus blocks)
- `@shallow` (low-energy, admin)
- `@creative` (writing, design)
- `@social` (calls, meetings)

### Person-based contexts (for managers)
- `@1:1-Bob`, `@1:1-Alice` — items to discuss in next 1:1 with that person
- Emptied at each 1:1, refilled as items accumulate

### Time-bound contexts
- `@morning` — only do before noon (cognitive)
- `@evening` — only after work (personal)

Mix-and-match is fine. Just keep the total around 6.

## What NOT to do

- **Don't make a context per project** — that's just project lists with extra steps
- **Don't make a context per priority** — priority is dynamic, contexts are situational
- **Don't make a "Today" context** — use the backend's native today surface (My Day, Today view)
- **Don't make a "This Week" context** — use due dates or the projects list

## Migration

If the user already has lists in their backend with different names:
- **Don't rename automatically** — confirm first
- **Map mentally** without forcing a rename if their scheme works for them
- **Suggest convention** only if their scheme has clear gaps (e.g., no Waiting For, no Inbox)
