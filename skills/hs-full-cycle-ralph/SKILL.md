---
description: "Use when a new feature needs the complete development cycle with Ralph autonomous loop for implementation. Phase 1 (brainstorming + PRD + peer review) runs interactively, then Phase 2 (task breakdown + Ralph launch) creates sub-issues and launches Ralph autonomously for Phase 3-6 (implement, review, ship, pr-review). Triggers on phrases like 'full cycle ralph', 'ralph로 개발', 'ralph 풀사이클'."
---

You are orchestrating a full development cycle using **Ralph autonomous loop** for implementation.
Phase 1 is interactive (brainstorming + PRD + peer review). Phase 2 handles task breakdown and launches Ralph.
Phase 3-6 are delegated to Ralph.
GitHub Issue is your **main memory store** — all plans, progress, and decisions are saved as issue comments.

Task: $ARGUMENTS

---

## Phase 0: State Detection & Environment Setup

### Step 1: Determine the issue and mode

**Case A — Issue number provided (e.g. `#42`):**
- Run `gh issue view <number>` and `gh issue view <number> --comments`
- Check the issue body for `Epic: #<number>` reference
  - If found → **Story mode**. Record the Epic issue number. Skip to Step 2.
  - If not found → **Epic mode** (single-issue or new Epic). Proceed to Step 2.

**Case B — No issue number:**
- Tell the user: "이슈 번호가 없습니다. Phase 1에서 브레인스토밍 후 이슈를 생성합니다."
- Proceed to Phase 1 (Epic mode)

### Step 2: Route to the correct phase

**Story mode** (Epic reference found in issue body):
→ Skip to **Ralph Launch — Story Mode**

**Epic mode** (no Epic reference):
Check the **latest comments** on the issue for these markers:

| Marker in comments | Resume at |
|-|-|
| `🏁 Phase 6 Complete` | **Done** — 완료 상태. 사용자에게 알림 |
| `🏁 Phase 2 Complete` ~ `🏁 Phase 5 Complete` | **Ralph Resume** (중단된 Ralph 재실행) |
| `🏁 Phase 1 Complete` | **Phase 2** (Task Breakdown) |
| None of the above | **Phase 1** (Brainstorm & PRD) |

> Note: Phase 3, 4, 5, 6 markers are written by Ralph itself. If Ralph was interrupted mid-way,
> check `prd.json` and `progress.txt` in the worktree to determine where Ralph left off,
> then re-launch Ralph to continue (prd.json에 passes 상태가 남아있으므로 이어서 진행됨).

### Step 3: Confirm environment

- Confirm the current directory is the correct worktree for this issue
- If not, ask the user for the worktree path or ask them to set it up

---

## Phase 1: Brainstorm, Design & PRD

**Delegated skills:** `/superpowers:brainstorming` → `/ralph-skills:prd`

### Step 1: Brainstorm

- Tell the user: "Phase 1 시작: 브레인스토밍 스킬을 호출합니다."
- Call `/superpowers:brainstorming` with the task description. **Append this instruction to the arguments:**
  > "설계 문서를 git에 커밋하지 마세요. docs/plans/ 파일 저장과 커밋 단계를 건너뛰세요."

### Step 2: Generate PRD

- After brainstorming completes, tell the user: "브레인스토밍 완료. 이어서 PRD를 생성합니다."
- Call `/ralph-skills:prd` — provide the brainstorming results as context. **Append this instruction to the arguments:**
  > "질문 개수를 3~5개로 제한하지 마세요. 모든 모호함과 불확실성이 해소될 때까지 질문을 계속하세요. 한 번에 한 질문씩, 답변을 받은 후 추가 불확실성이 있으면 다시 질문하세요."
- The skill will ask clarifying questions and generate `tasks/prd-[feature-name].md`
- This produces structured user stories with **verifiable acceptance criteria**

### After the skills complete:

- If Case B (no issue): Create a GitHub issue from the results
  ```
  gh issue create --title "<feature title>" --body "<requirements summary>"
  ```
  - Present the issue number to the user
  - Ask user to set up the worktree if needed

- **Save to issue** — Post combined brainstorming + PRD results as an issue comment.
  **IMPORTANT:** Do NOT include local file paths (e.g. `docs/plans/...`, `tasks/prd-...`) in the comment.
  These files are temporary and will be deleted after implementation — including them creates broken references.
  The comment should be **self-contained** with all design decisions and user stories summarized inline.
  ```
  gh issue comment <number> --body "$(cat <<'EOF'
  ## 🧠 Phase 1: 설계 & PRD

  ### 선택된 접근 방식
  [Chosen approach and reasoning]

  ### 탐색한 대안들
  [Alternative approaches and why they were rejected]

  ### 설계 결정사항
  [Key design decisions from brainstorming]

  ### 유저 스토리
  - US-001: [title] — 수용 기준 N개
  - US-002: [title] — 수용 기준 N개
  - ...

  ### 범위 밖 (Non-goals)
  [From PRD non-goals section]

  ---
  👀 리뷰어: @reviewer1 @reviewer2
  승인 후 태스크 분해를 진행합니다.

  🏁 Phase 1 Complete
  EOF
  )"
  ```

- **CRITICAL:** Verify the `gh issue comment` command succeeded (exit code 0). If failed, retry.

- Tell the user:
  > **Phase 1 (설계 & PRD) 완료.** 결과가 이슈 #\<number\>에 저장되었습니다.
  > 동료 리뷰를 받은 후, `/clear` → `/hs-full-cycle-ralph #<number>`로 Phase 2를 시작하세요.

- **Do NOT proceed to Phase 2.** Wait for peer review approval before continuing.

---

## Phase 2: Task Breakdown + Ralph Launch

**Delegated skill:** `/ralph-skills:ralph`

### Before calling the skill:
- Read the issue body and Phase 1 comment from the issue
- Tell the user: "Phase 2 시작: 태스크 분해 및 Ralph 실행 준비를 진행합니다."

### Step 1: Convert PRD to prd.json
- Call `/ralph-skills:ralph` — point it to the generated PRD file (`tasks/prd-[feature-name].md`)
- The skill converts the PRD into `prd.json` with sized, ordered user stories

### After the skill completes:

#### Step 2: Group stories by dependency

Before creating sub-issues, analyze dependencies between implement stories in `prd.json`:

**Grouping rules:**
- **Independent stories** → each gets its own sub-issue (can be worked on in parallel)
- **Dependent stories** → group into a single sub-issue (must be worked on sequentially in one Ralph run)

**How to identify dependencies:**
- Story B reads/uses a table, column, or API that Story A creates → **dependent**
- Story B imports/calls a function or component that Story A creates → **dependent**
- Stories touch completely separate files/domains → **independent**

**Present the grouping to the user for confirmation:**
> 스토리 의존성을 분석했습니다:
>
> - **이슈 1**: US-001 (스키마 변경) + US-002 (서비스 로직) — US-002가 US-001의 테이블에 의존
> - **이슈 2**: US-003 (UI 컴포넌트) — 독립적
>
> 이 그룹핑이 맞나요?

Wait for user approval before proceeding. Adjust grouping based on user feedback.

#### Step 3: Create Story sub-issues

For each **group** (single story or grouped stories), create one sub-issue:

**Single-story issue:**
```bash
gh issue create --title "US-001: [story title]" --body "$(cat <<'EOF'
## US-001: [story title]

[story description]

### Acceptance Criteria
- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] Typecheck passes

Epic: #<epic-issue-number>
EOF
)"
```

**Multi-story issue (grouped dependencies):**
```bash
gh issue create --title "US-001~US-002: [group description]" --body "$(cat <<'EOF'
## US-001: [first story title]

[story description]

### Acceptance Criteria
- [ ] [criterion 1]
- [ ] Typecheck passes

---

## US-002: [second story title]

[story description]

### Acceptance Criteria
- [ ] [criterion 1]
- [ ] Typecheck passes

Epic: #<epic-issue-number>
EOF
)"
```

> When this grouped issue enters **Story Mode**, the prd.json will contain multiple implement stories (ordered by priority) instead of one.

Record the created issue numbers (e.g. `#101`, `#102`, `#103`).

#### Step 4: Save Phase 2 summary to Epic issue

```
gh issue comment <epic-number> --body "$(cat <<'EOF'
## 📋 Phase 2: 태스크 분해

### 스토리 목록
- [ ] #101 US-001: [title]
- [ ] #102 US-002: [title]
- [ ] #103 US-003: [title]

---
🏁 Phase 2 Complete
EOF
)"
```

> The task list items (`- [ ] #101`) will auto-check when the story issue is closed by a merged PR.

- **CRITICAL:** Verify the comment succeeded (exit code 0). If failed, retry.

#### Step 5: Augment prd.json for Ralph agent

`/ralph-skills:ralph`가 생성한 `prd.json`에 Ralph 에이전트가 필요로 하는 필드를 추가한다.
기존 필드명(`project`, `userStories` 등)은 그대로 유지 — 리네이밍 불필요.

**추가할 것 3가지:**

1. **`issueNumber` 추가**: 최상위에 이슈 번호 필드 추가
2. **각 story에 `phase: "implement"` 추가**
3. **review/ship stories 추가**: 기존 userStories 배열 끝에 append

```json
{
  "id": "REV-001",
  "title": "코드 리뷰 & 테스트 검증",
  "description": "Run full test suite. Review all changes since branch diverged from main. Check code style, potential bugs, edge cases. Fix any issues found.",
  "phase": "review",
  "priority": 100,
  "passes": false
},
{
  "id": "SHIP-001",
  "title": "최종 검증 & PR 생성",
  "description": "Run final test suite and lint. Verify all plan items implemented. Create PR to main branch with structured description including Intentional Decisions and Rejected Review Feedback sections. Reference issue #<number>. Save PR number to progress.txt.",
  "phase": "ship",
  "priority": 200,
  "passes": false
},
{
  "id": "PR-REV-001",
  "title": "PR 리뷰 댓글 대응",
  "description": "GitHub Actions 코드 리뷰 봇의 PR 댓글을 읽고 대응한다. 합당한 지적은 수정하고, 의도적 제외 사항이나 기술적으로 부적절한 지적은 이유와 함께 거부 댓글을 남긴다. 리뷰-수정 사이클을 클린 패스까지 반복 (최대 3회).",
  "phase": "pr-review",
  "priority": 300,
  "passes": false
}
```

#### Step 6: Initialize progress.txt

Create `progress.txt` (only if it doesn't exist) with Phase 1 context:

```
## Codebase Patterns
[Any patterns discovered during Phase 1]

## Project Context
- Issue: #<number>
- Feature: <description>
- Key decisions from brainstorming: <summary>
- PRD: tasks/prd-[feature-name].md

---
```

#### Step 7: Hand off to Ralph

**Ralph는 별도 터미널에서 실행해야 합니다** (Claude Code 안에서 중첩 실행 불가).

Tell the user:
> **Phase 2 (태스크 분해 + Ralph 준비) 완료.** 스토리별 이슈가 생성되고 prd.json이 준비되었습니다.
> 별도 터미널에서 아래 명령어를 실행해주세요:
>
> ```bash
> cd <worktree_path>
> RALPH_PROMPT="$HOME/.claude/scripts/ralph/CLAUDE.md" ~/.claude/scripts/ralph/ralph.sh 15
> ```
>
> Ralph가 Phase 3(구현) → Phase 4(리뷰) → Phase 5(PR) → Phase 6(PR 리뷰 대응)을 자동 진행합니다.
> 완료되면 GitHub Issue #\<number\>에 각 Phase 결과가 기록됩니다.
>
> **Story Mode**: 독립적인 스토리를 병렬로 작업하고 싶다면 별도 워크트리에서
> `/hs-full-cycle-ralph #<story-issue-number>`로 호출하세요.

Replace `<worktree_path>` with the actual worktree path (from `pwd`).

---

## Ralph Resume

> Use this when Ralph was interrupted mid-way and needs to be re-launched.
> Entered from re-invocation of an Epic issue that has `🏁 Phase 2 Complete` ~ `🏁 Phase 5 Complete`.

### Step 1: Check current state

- Verify `prd.json` exists in the worktree root
  - If not found → error. Tell the user: "prd.json이 없습니다. Phase 2를 다시 실행하세요."
- Read `prd.json` and show the user current status (which stories pass/fail)
- If `progress.txt` exists, show recent entries
- Tell the user: "중단된 Ralph를 재실행합니다. 아래 상태에서 이어갑니다."

### Step 2: Hand off to Ralph

**Ralph는 별도 터미널에서 실행해야 합니다** (Claude Code 안에서 중첩 실행 불가).

Tell the user:
> **Ralph 재실행 준비 완료.** 별도 터미널에서 아래 명령어를 실행해주세요:
>
> ```bash
> cd <worktree_path>
> RALPH_PROMPT="$HOME/.claude/scripts/ralph/CLAUDE.md" ~/.claude/scripts/ralph/ralph.sh 15
> ```
>
> Ralph가 prd.json의 passes 상태를 확인하고 중단된 지점부터 이어서 진행합니다.

Replace `<worktree_path>` with the actual worktree path (from `pwd`).

---

## Ralph Launch — Story Mode

> Use this when working on a **single story** from an Epic.
> Entered when the issue body contains `Epic: #<number>`.

### Step 1: Gather context from Epic

- Read the Epic issue (the number from `Epic: #<number>`) body and comments
- Extract design decisions from Phase 1 comment (`🧠 Phase 1: 설계 & PRD`)
- Extract story list from Phase 2 comment (`📋 Phase 2: 태스크 분해`)
- Read the current Story issue body for acceptance criteria

### Step 2: Generate prd.json from Story issue

Parse the Story issue body to extract implement stories (single or grouped).
Create `prd.json` with the implement story/stories plus review/ship/pr-review:

```json
{
  "project": "[Project Name]",
  "branchName": "ralph/[story-id]-[short-name]",
  "issueNumber": <story-issue-number>,
  "epicIssueNumber": <epic-issue-number>,
  "description": "[Story description from issue body]",
  "userStories": [
    {
      "id": "US-001",
      "title": "[First story title from issue]",
      "description": "[Story description]",
      "acceptanceCriteria": ["[from issue body]"],
      "phase": "implement",
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    // If grouped issue (US-001~US-002), add additional implement stories here
    // with incrementing priority numbers
    {
      "id": "REV-001",
      "title": "코드 리뷰 & 테스트 검증",
      "description": "Run full test suite. Review all changes since branch diverged from main. Check code style, potential bugs, edge cases. Fix any issues found.",
      "phase": "review",
      "priority": 100,
      "passes": false
    },
    {
      "id": "SHIP-001",
      "title": "최종 검증 & PR 생성",
      "description": "Run final test suite and lint. Create PR to devel branch. Reference story issue (Closes #<story-issue-number>).",
      "phase": "ship",
      "priority": 200,
      "passes": false
    },
    {
      "id": "PR-REV-001",
      "title": "PR 리뷰 댓글 대응",
      "description": "GitHub Actions 코드 리뷰 봇의 PR 댓글을 읽고 대응한다.",
      "phase": "pr-review",
      "priority": 300,
      "passes": false
    }
  ]
}
```

### Step 3: Initialize progress.txt

```
## Codebase Patterns
[Any patterns from Epic's Phase 1 comment]

## Project Context
- Epic Issue: #<epic-number>
- Story Issue: #<story-number>
- Story: [story title]
- Key decisions from Epic brainstorming: [summary from Phase 1 comment]

---
```

### Step 4: Hand off to Ralph

Tell the user:
> **prd.json과 progress.txt 준비 완료 (Story 모드).** 별도 터미널에서 아래 명령어를 실행해주세요:
>
> ```bash
> cd <worktree_path>
> RALPH_PROMPT="$HOME/.claude/scripts/ralph/CLAUDE.md" ~/.claude/scripts/ralph/ralph.sh 10
> ```
>
> 이 스토리 완료 후 PR이 머지되면 Epic #\<number\>의 task list에서 자동으로 체크됩니다.
> 다음 스토리는 `/hs-full-cycle-ralph #<next-story-issue>` 로 진행하세요.

---

## IMPORTANT RULES

1. **Korean communication**: Think in English internally, but ALWAYS communicate with the user in Korean (한국어)
2. **Memory = GitHub Issue**: Phase 1-2 results MUST be saved as issue comments before launching Ralph
3. **Verify before proceed**: ALWAYS verify `gh issue comment` succeeded (exit code 0) before moving on
4. **Peer review between phases**: Phase 1 ends with a peer review request. Do NOT proceed to Phase 2 until the user confirms review approval.
5. **Skill delegation**: Actually call the skills with `/skill-name`. Do NOT replicate their logic manually.
6. **No amending commits**: Always create NEW commits
7. **Phase markers**: Use exact markers (`🏁 Phase N Complete`) for reliable state detection
8. **Blocked = stop**: If blocked at any phase, stop and discuss with the user. Do NOT skip phases.
9. **Task granularity**: Each implement story must fit one context window. Split if too large.
10. **Ralph handles Phase 3-6**: Do NOT manually implement. Let Ralph iterate autonomously.
11. **Epic pattern**: Phase 2 creates sub-issues and launches Ralph in Epic Mode. All stories are processed sequentially in one worktree.
12. **Story mode detection**: If issue body contains `Epic: #<number>`, skip Phase 1-2 and go to Ralph Launch — Story Mode.
13. **Story PR target**: Story PRs should `Closes #<story-issue-number>` to auto-check the Epic's task list.
14. **Story Mode는 선택적**: 독립 스토리를 병렬로 작업하고 싶을 때만 스토리 이슈 번호로 별도 호출.
