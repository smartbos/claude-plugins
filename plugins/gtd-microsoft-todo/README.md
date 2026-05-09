# gtd-microsoft-todo

Getting Things Done (GTD) workflow for Claude Code, powered by Microsoft To Do.

## What it does

Implements David Allen's GTD methodology against Microsoft To Do as the task backend. Five entry points cover the GTD lifecycle:

| Slash command | When to use |
|---------------|-------------|
| `/gtd-capture <item>` | Quickly throw an item into Inbox without thinking |
| `/gtd-process` | Walk the Inbox interactively, classify each item |
| `/gtd-plan` | Pick today's 3–7 commitments from Next Actions |
| `/gtd-query <question>` | Ask about your lists ("@phone 보여줘", "stale waiting-for") |
| `/gtd-review` | Weekly review with active diagnostics (orphan projects, stale items, etc.) |

You can also invoke via natural language — the underlying `gtd` skill responds to phrases like "inbox 처리하자", "오늘 할 일", "주간 리뷰".

## Architecture

This plugin is a thin wrapper:
- The **`gtd` skill** (in `skills/gtd/`, shared across plugins) holds the methodology
- This plugin's **commands** inject Microsoft To Do as the concrete backend
- The **`.mcp.json`** auto-registers `@mag-cie/mcp-microsoft-todo` so users don't need to set it up separately

The same `gtd` skill could be wrapped by `gtd-todoist`, `gtd-reminders`, etc. — backend selection is per-plugin.

## Installation

### Via marketplace (recommended)

```bash
claude plugin marketplace add smartbos/claude-plugins
claude plugin install gtd-microsoft-todo
```

### First-time Microsoft authentication

After install, authenticate once via device code flow:

```bash
npx -y @mag-cie/mcp-microsoft-todo@latest --auth
```

Sign in at the URL it prints. Token caches at `~/.mcp-microsoft-todo/token-cache.json` and auto-refreshes.

**Personal Microsoft accounts** (outlook.com / hotmail.com / live.com): prefix with `MS_TENANT=consumers`:

```bash
MS_TENANT=consumers npx -y @mag-cie/mcp-microsoft-todo@latest --auth
```

**Org accounts** with strict admin policies: an Azure AD admin may need to consent first at  
`https://login.microsoftonline.com/<tenant>/adminconsent?client_id=6ea8909b-95e0-4ef0-8b48-d5910f164c6a`

## List conventions

The plugin uses these list names by default (creates them on first need):

- `📥 Inbox` — captures
- `🎯 Projects` — multi-step outcomes
- `⏳ Waiting For` — delegated/blocked
- `💭 Someday` — not-now possibilities
- `@컴퓨터`, `@전화`, `@사무실`, `@집`, `@외출`, `@언제든` — next-action contexts

Already have lists with different names? The skill respects what exists; it only creates missing ones. See the gtd skill's `references/list-conventions.md` for customization rationale.

## Examples

```
/gtd-capture 부모님 5/15 어버이날 선물 알아보기

/gtd-process
→ Inbox에 3개 있음. 첫 번째: "부모님 5/15 어버이날 선물 알아보기"
   actionable? (Y/n) ...

/gtd-plan
→ 오늘 6개 제안: 
   1. ...
   confirm? (Y/n)

/gtd-query stale waiting-for
→ ⏳ Waiting For 중 2주 이상 묵은 항목 3개:
   - 팀장 승인 (18d)
   - ...

/gtd-review
→ 🔴 정리 필요 4개
   🟡 검토 권장 7개
   🟢 시스템 건강도: OK
   walk through 🔴? (Y/n)
```

## License

MIT — see top-level repo LICENSE.

## Credits

- GTD methodology: David Allen
- MCP server: [@mag-cie/mcp-microsoft-todo](https://github.com/MAG-Cie/mcp-microsoft-todo)
- Microsoft To Do API: Microsoft Graph
