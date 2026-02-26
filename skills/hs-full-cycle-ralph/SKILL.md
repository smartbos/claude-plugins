---
description: "Use when a new feature needs the complete development cycle with Ralph autonomous loop for implementation. Phase 1 (brainstorming + PRD + peer review) runs interactively, then Phase 2 (task breakdown + Ralph launch) prepares prd.json and launches Ralph autonomously for Phase 3-6 (implement, review, ship, pr-review). Triggers on phrases like 'full cycle ralph', 'ralph로 개발', 'ralph 풀사이클'."
---

You are orchestrating a full development cycle using **Ralph autonomous loop** for implementation.
Phase 1 is interactive (brainstorming + PRD + peer review). Phase 2 handles task breakdown and launches Ralph.
Phase 3-6 are delegated to Ralph.
GitHub Issue is your **main memory store** — all plans, progress, and decisions are saved as issue comments.
Mermaid 다이어그램을 활용하여 설계와 구현 결과를 시각적으로 전달한다. 유형 선택과 작성법은 [references/mermaid-guide.md](references/mermaid-guide.md) 참조.

Task: $ARGUMENTS

---

## Phase 0: State Detection & Environment Setup

### Step 1: Determine the issue

**Case A — Issue number provided (e.g. `#42`):**
- Run `gh issue view <number>` and `gh issue view <number> --comments`
- Proceed to Step 2.

**Case B — No issue number:**
- Tell the user: "이슈 번호가 없습니다. Phase 1에서 브레인스토밍 후 이슈를 생성합니다."
- Proceed to Phase 1

### Step 2: Route to the correct phase

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

- **Mermaid 다이어그램 생성**: Read [references/mermaid-guide.md](references/mermaid-guide.md)의 "Phase 1" 섹션을 참고하여 설계에 적합한 다이어그램 1-3개를 생성한다.
  - 핵심 요청/데이터 흐름 → Sequence Diagram 또는 Flowchart (필수)
  - 데이터 모델 변경 → ER Diagram (해당 시)
  - 상태 전이 존재 → State Diagram (해당 시)

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

  ### 아키텍처 다이어그램
  [Mermaid diagram(s) — 설계에서 도출된 핵심 흐름, 데이터 모델, 상태 전이 등을 시각화]

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

#### Step 2: Augment prd.json for Ralph agent

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
  "description": "Run final test suite and lint. Verify all plan items implemented. Create PR with structured description including: (1) Mermaid diagrams showing key implementation flows — use sequence diagram for service/API interactions, flowchart for routing/decision logic, data transformation diagram as applicable (1-3 diagrams, Korean labels, max 10 nodes each), (2) Intentional Decisions and Rejected Review Feedback sections. Reference issue #<issueNumber> with Closes. Save PR number to progress.txt.",
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

#### Step 3: Save Phase 2 summary to issue

```
gh issue comment <number> --body "$(cat <<'EOF'
## 📋 Phase 2: 태스크 분해

### 스토리 목록
- US-001: [title]
- US-002: [title]
- US-003: [title]

### 스토리 의존성
[Mermaid flowchart — 스토리 간 실행 순서와 의존 관계. 병렬 가능한 스토리는 같은 레벨에 배치]

### prd.json 준비 완료
Ralph 실행 준비가 완료되었습니다.

---
🏁 Phase 2 Complete
EOF
)"
```

- **CRITICAL:** Verify the comment succeeded (exit code 0). If failed, retry.

#### Step 4: Initialize progress.txt

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

#### Step 5: Hand off to Ralph

**Ralph는 별도 터미널에서 실행해야 합니다** (Claude Code 안에서 중첩 실행 불가).

Tell the user:
> **Phase 2 (태스크 분해 + Ralph 준비) 완료.** prd.json이 준비되었습니다.
> 별도 터미널에서 아래 명령어를 실행해주세요:
>
> ```bash
> cd <worktree_path>
> RALPH_PROMPT="$HOME/.claude/scripts/ralph/CLAUDE.md" ~/.claude/scripts/ralph/ralph.sh 15
> ```
>
> Ralph가 Phase 3(구현) → Phase 4(리뷰) → Phase 5(PR) → Phase 6(PR 리뷰 대응)을 자동 진행합니다.
> 완료되면 GitHub Issue #\<number\>에 각 Phase 결과가 기록됩니다.

Replace `<worktree_path>` with the actual worktree path (from `pwd`).

---

## Ralph Resume

> Use this when Ralph was interrupted mid-way and needs to be re-launched.
> Entered from re-invocation of an issue that has `🏁 Phase 2 Complete` ~ `🏁 Phase 5 Complete`.

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
