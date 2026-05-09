# Weekly Review

The contract that keeps GTD trustworthy. Run weekly — typically Friday afternoon or Sunday evening. Walk through these stages interactively with the user, surfacing diagnostic findings as you go.

## Stage 1 — Get clear (수집)

- [ ] **Inbox to zero** — process any remaining captured items
- [ ] **Mind sweep** — ask the user: "이번 주에 머릿속에 떠다닌 것 중 시스템에 안 들어간 게 있나요?" Capture any that surface.
- [ ] **Email/messaging** — flagged or starred items not yet captured? Process them.

## Stage 2 — Get current (정리)

For each list, run these diagnostic checks:

### Projects list
- [ ] **Each project has a next action** — query each project, confirm it has at least one item in a context list or sub-task. Flag orphans. **Why**: a project without a next action is dead weight; rename it to Someday/Maybe or define the action.
- [ ] **Each active project still matters** — confirm with user; move outdated to Someday/Maybe or archive
- [ ] **No "in progress forever" projects** — flag projects older than 90 days with no recent task completion

### Next Action context lists (@phone, @computer, etc.)
- [ ] **Stale items** — flag items older than 21 days. Ask: still relevant? Reword? Escalate to today?
- [ ] **Mis-categorized** — items that should be Waiting For (delegated) or Someday (not actionable now)

### Waiting For
- [ ] **Stale waiting-for** — flag items older than 14 days. Ask: nudge the person? Escalate? Drop?
- [ ] **Each item has a "who" + "since when"** — items missing context get a quick clarification

### Someday/Maybe
- [ ] **Quick scan** — anything ready to promote to active Project?
- [ ] **Anything to drop** — interest faded?

### Calendar (if available)
- [ ] **Past week reviewed** — anything to capture from completed events (notes, follow-ups)?
- [ ] **Next 2 weeks scanned** — preparation tasks needed?

## Stage 3 — Get creative (창의)

This is the often-skipped half of GTD. Reserve 5–10 minutes.

- [ ] **Higher horizons check** — ask the user briefly:
  - "이번 주에 했던 일들이 분기 목표와 맞았나?" (3-month horizon)
  - "Someday/Maybe 중에 이번 분기에 시작해볼 만한 게 있나?"
- [ ] **System health** — anything about the GTD system itself feeling clunky? List names off? Too many or too few contexts? Note for adjustment.

## Diagnostic queries (suggested)

When running the review, these are the high-value automated checks:

| Diagnostic            | Query pattern                                                | Action |
|-----------------------|--------------------------------------------------------------|--------|
| Orphan project        | Projects list items not referenced as next-action source     | Define next action OR move to Someday |
| Stale waiting-for     | Waiting For items where created_at > 14 days ago             | Nudge/escalate/drop |
| Stale next-action     | Context list items where created_at > 21 days ago            | Re-evaluate |
| Completed clutter     | Tasks completed > 7 days ago still showing in lists          | Archive or hide |
| Empty context         | Context list with 0 items for 30+ days                       | Consider removing |
| Inbox lingering       | Inbox items where created_at > 48h ago                       | Process now |
| Long-running project  | Projects in "Projects" list with no completed task in 30 days| Reality check |

## Output style

Present findings as a punch list, not a wall of text. Example:

```
🔴 4개 정리 필요
  - Orphan project: "사이드 프로젝트 X" — next action 없음
  - Stale waiting-for: "팀장님 승인" (18일 됨)
  - Stale waiting-for: "법무 검토 회신" (21일 됨)
  - Long-running: "블로그 리브랜딩" (45일 째, 최근 완료 없음)

🟡 7개 검토 권장
  - @컴퓨터: "AWS 비용 분석" (24일 됨)
  - ...

🟢 시스템 건강도: OK
  - Inbox 0
  - 완료된 항목 12개 archive 필요
```

Walk through 🔴 with the user one at a time, take their decision, apply it. Move to 🟡 if time allows. 🟢 is informational.

## Anti-patterns

- **Reading the whole list aloud** — bad. Surface diagnostic signals only.
- **Auto-archiving without confirmation** — destructive; always confirm.
- **Trying to do all stages every time** — if user has 15 minutes, prioritize Stage 1 + Projects diagnostic. Skip Creative.
- **Letting it become a chore** — review should feel like decompression, not work. Keep it crisp (30–60 min total).
