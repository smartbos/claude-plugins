---
description: "Use when a new feature needs the complete development cycle with Ralph autonomous loop for implementation. Phase 1 (product discovery + peer review) and Phase 2 (brainstorming + PRD + peer review) run interactively, then Phase 3 (task breakdown + Ralph launch) prepares prd.json and launches Ralph autonomously for Phase 4-7 (implement, review, ship, pr-review). Triggers on phrases like 'full cycle ralph', 'ralph로 개발', 'ralph 풀사이클'."
---

You are orchestrating a full development cycle using **Ralph autonomous loop** for implementation.
Phase 1-2 are interactive (product discovery + brainstorming + PRD + peer review). Phase 3 handles task breakdown and launches Ralph.
Phase 4-7 are delegated to Ralph.
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
- Tell the user: "이슈 번호가 없습니다. Phase 1에서 Product Discovery 후 이슈를 생성합니다."
- Proceed to Phase 1

### Step 2: Route to the correct phase

Check the **latest comments** on the issue for these markers:

| Marker in comments | Resume at |
|-|-|
| `🏁 Phase 7 Complete` | **Done** — 완료 상태. 사용자에게 알림 |
| `🏁 Phase 3 Complete` ~ `🏁 Phase 6 Complete` | **Ralph Resume** (중단된 Ralph 재실행) |
| `🏁 Phase 2 Complete` | **Phase 3** (Task Breakdown) |
| `🏁 Phase 1 Complete` | **Phase 2** (Brainstorm & PRD) |
| None of the above | **Phase 1** (Product Discovery) |

> Note: Phase 4, 5, 6, 7 markers are written by Ralph itself. If Ralph was interrupted mid-way,
> check `prd.json` and `progress.txt` in the worktree to determine where Ralph left off,
> then re-launch Ralph to continue (prd.json에 passes 상태가 남아있으므로 이어서 진행됨).

### Step 3: Confirm environment

- Confirm the current directory is the correct worktree for this issue
- If not, ask the user for the worktree path or ask them to set it up

---

## Phase 1: Product Discovery

**Delegated skill:** `/product-designer` (Step 2)

**목표:** 기술 설계 전에 "무엇을 만들 것인가"를 정의하고 팀 합의를 도출한다.

### Step 1: 레포 정보 확인 & 태스크 유형 판별

#### 1-1. 레포 정보 확인

```bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
```

결과를 `{owner}/{repo}`로 저장한다 (이슈 생성 등에 사용).

#### 1-2. 태스크 유형 판별

태스크 설명을 분석하여 `ui` 또는 `non-ui` 유형을 판별한다.

| 유형 | 키워드/특징 | 예시 |
|------|-------------|------|
| `ui` | 화면, 폼, 대시보드, 프론트엔드, UI, 컴포넌트, 페이지 | 사용자 프로필 페이지 추가, 대시보드 개선 |
| `non-ui` | API, 백엔드, 인프라, 리팩토링, CLI, 마이그레이션, 파이프라인, 배치 | REST API 추가, DB 마이그레이션, CI/CD 파이프라인 |

1. 태스크 설명에서 유형을 추론한다
2. 사용자에게 결과를 제시하고 확인을 요청한다:
   > "이 태스크를 **[ui/non-ui]** 유형으로 판별했습니다. [판별 근거 1-2줄]. 맞습니까?"
3. 사용자 확인 후 유형을 `{task_type}`으로 저장한다 (이후 Phase 1 단계에서 참조)

### Step 2: Product Discovery 인터뷰

**Delegated skill:** `/product-designer`

- Tell the user: "Product Discovery 인터뷰를 시작합니다. UX 프레임워크를 활용하여 체계적으로 진행합니다."
- Call `/product-designer` with the task description. **유형에 따라 아래 지시문을 선택하여 arguments에 추가:**

**`ui` 유형:**
  > "Double Diamond의 Discover 단계로 제품 발견 인터뷰를 진행하세요. 아래 5개 영역을 순서대로, 한 번에 한 질문씩 물어보세요. 각 답변이 불충분하면 후속 질문으로 구체화하세요.
  > 1. **페르소나 정의**: User Journey Mapping 프레임워크를 활용하여 주 사용자의 역할, 기술 수준, 핵심 동기, 페인 포인트를 파악하세요.
  > 2. **핵심 유저 시나리오**: 사용자가 달성하려는 주요 목표 1-3개를 User Journey 단계(Awareness → Consideration → Action → Retention)로 구조화하세요.
  > 3. **화면 인벤토리**: Information Architecture (Site Map)를 참고하여 시나리오 기반 화면 구조 초안을 제안하고, 사용자에게 수정/확정을 받으세요.
  > 4. **핵심 비즈니스 룰**: 권한, 제한, 유효성 검사 등 정책을 파악하세요.
  > 5. **엣지 케이스**: 빈 상태, 동시성, 에러, 대량 데이터 시나리오를 파악하세요.
  > 최종 결과물로 파일을 생성하지 마세요. 대화로만 진행하세요."

**`non-ui` 유형:**
  > "Double Diamond의 Discover 단계로 제품 발견 인터뷰를 진행하세요. 이 태스크는 UI가 없는 백엔드/인프라/API 작업입니다. 아래 5개 영역을 순서대로, 한 번에 한 질문씩 물어보세요. 각 답변이 불충분하면 후속 질문으로 구체화하세요.
  > 1. **API 소비자/클라이언트 정의**: 이 시스템을 호출하는 주체(프론트엔드, 다른 서비스, CLI 사용자, 크론잡 등)의 역할과 요구사항을 파악하세요.
  > 2. **시스템 인터랙션 시나리오**: 주요 요청-응답 흐름 1-3개를 단계별로 구조화하세요 (입력 → 처리 → 출력 → 에러).
  > 3. **API/모듈 인벤토리**: 시나리오 기반으로 필요한 엔드포인트, 모듈, 서비스의 구조 초안을 제안하고, 사용자에게 수정/확정을 받으세요.
  > 4. **핵심 비즈니스 룰**: 권한, 제한, 유효성 검사, rate limiting 등 정책을 파악하세요.
  > 5. **엣지 케이스**: 타임아웃, 동시성, 에러 전파, 대량 데이터, 장애 복구 시나리오를 파악하세요.
  > 최종 결과물로 파일을 생성하지 마세요. 대화로만 진행하세요."

### Step 3: Mermaid 다이어그램 생성

[references/mermaid-guide.md](references/mermaid-guide.md)의 "Phase 1" 섹션을 참고하여 유형별 다이어그램을 생성한다.

**`ui` 유형:**
- **User Journey Diagram**: 핵심 시나리오별 사용자 경험 흐름 (필수)
- **Screen Flow Flowchart**: 화면 간 이동과 분기 (필수)

**`non-ui` 유형:**
- **Sequence Diagram**: 핵심 시스템 인터랙션 흐름 (필수)
- **Flowchart / Architecture Diagram**: 분기 로직 또는 시스템 구조 (해당 시)

생성한 다이어그램을 사용자에게 보여주고 피드백을 반영한다.

### Step 4: 정책/비즈니스 룰 테이블 정리

인터뷰 결과를 아래 형식으로 정리한다:

**비즈니스 룰:**
```
| # | 카테고리 | 규칙 | 세부사항 |
|---|----------|------|----------|
```

**엣지 케이스:**
```
| # | 시나리오 | 예상 동작 |
|---|----------|-----------|
```

사용자에게 보여주고 확인받는다.

### Step 5: HTML 와이어프레임 생성 & Playwright 스크린샷

> 이 단계는 `ui` 유형에서만 실행한다. `non-ui` 유형이면 Step 6으로 건너뛴다.

#### 5-1. 와이어프레임 HTML 작성

- `wireframes/` 디렉토리 생성
- 각 화면별 lo-fi HTML 파일 작성 (인라인 CSS, 외부 의존성 없음)
  - **Lo-fi 스타일**: 배경 `#f5f5f5`, 카드 `#fff`, 테두리 `#ddd`, 버튼 `#666`+`#fff`, font-family sans-serif 14px, max-width 800px
  - **한국어 텍스트**, 실제 데이터와 유사한 더미 데이터

#### 5-2. Playwright 스크린샷 촬영

ToolSearch로 Playwright 도구를 로드한 후:

1. 로컬 HTTP 서버 시작:
   ```bash
   python3 -m http.server 8090 --directory wireframes/ &
   ```
2. 각 HTML 파일에 대해:
   - `browser_navigate` → `http://localhost:8090/{filename}.html`
   - `browser_take_screenshot` → 스크린샷 저장 (파일명: `wireframes/{화면명}.png`)
3. 서버 종료

#### 5-3. 로컬 프리뷰 & 사용자 확인

> **IMPORTANT:** 와이어프레임 파일(HTML, PNG)은 커밋하지 않는다. 로컬 프리뷰용으로만 사용.

```bash
open wireframes/*.png  # macOS에서 스크린샷을 미리보기로 열기
```

사용자에게 와이어프레임을 보여주고 피드백을 반영한다. 수정이 필요하면 5-1 ~ 5-2를 반복한다.

### Step 6: GitHub Issue에 Phase 1 결과 포스팅

**Case B (이슈 없음):** 먼저 이슈를 생성한다.
```bash
gh issue create --title "<feature title>" --body "<brief description>"
```

Phase 1 결과를 이슈 코멘트로 포스팅한다. **유형에 따라 아래 템플릿을 선택:**

**`ui` 유형 템플릿:**

```
gh issue comment <number> --body "$(cat <<'EOF'
## 🔍 Phase 1: Product Discovery

> 태스크 유형: **ui**

### 페르소나
[페르소나 정의 — 역할, 기술 수준, 동기]

### User Journey
[Mermaid User Journey Diagram(s)]

### 화면 흐름
[Mermaid Screen Flow Flowchart]

### 와이어프레임

<details>
<summary>화면 스크린샷 (클릭하여 펼치기)</summary>

> ⚠️ 아래 플레이스홀더를 이미지로 교체해주세요. 이 코멘트 편집 → 각 플레이스홀더 선택 → 이미지 드래그앤드롭.

#### [화면명 1]
`[📎 이미지를 여기에 드롭: 화면명 1]`

#### [화면명 2]
`[📎 이미지를 여기에 드롭: 화면명 2]`

</details>

### 비즈니스 룰
| # | 카테고리 | 규칙 | 세부사항 |
|---|----------|------|----------|
[테이블 내용]

### 엣지 케이스
| # | 시나리오 | 예상 동작 |
|---|----------|-----------|
[테이블 내용]

---
👀 리뷰어: @reviewer1 @reviewer2
승인 후 설계 & PRD를 진행합니다.

🏁 Phase 1 Complete
EOF
)"
```

**`non-ui` 유형 템플릿:**

```
gh issue comment <number> --body "$(cat <<'EOF'
## 🔍 Phase 1: Product Discovery

> 태스크 유형: **non-ui**

### API 소비자 / 클라이언트
[시스템을 호출하는 주체 — 역할, 요구사항]

### 시스템 인터랙션 흐름
[Mermaid Sequence Diagram(s)]

### 아키텍처 / 분기 흐름
[Mermaid Flowchart / Architecture Diagram (해당 시)]

### 비즈니스 룰
| # | 카테고리 | 규칙 | 세부사항 |
|---|----------|------|----------|
[테이블 내용]

### 엣지 케이스
| # | 시나리오 | 예상 동작 |
|---|----------|-----------|
[테이블 내용]

---
👀 리뷰어: @reviewer1 @reviewer2
승인 후 설계 & PRD를 진행합니다.

🏁 Phase 1 Complete
EOF
)"
```

- **CRITICAL:** `gh issue comment` 명령의 exit code가 0인지 검증한다. 실패 시 재시도.

#### 코멘트 편집 URL 제공

코멘트 작성 후, 마지막 코멘트 URL을 가져와서 사용자에게 안내한다:

```bash
COMMENT_URL=$(gh api repos/{owner}/{repo}/issues/<number>/comments --jq '.[-1].html_url')
echo "코멘트 URL: $COMMENT_URL"
```

### Step 7: 사용자 안내 (리뷰 게이트)

**`ui` 유형:**

Tell the user:
> **Phase 1 (Product Discovery) 완료.** 결과가 이슈 #\<number\>에 저장되었습니다.
>
> 📎 **와이어프레임 이미지 업로드가 필요합니다:**
> 1. 코멘트 링크를 열어주세요: \<COMMENT_URL\>
> 2. 코멘트 우측 상단 `···` → **Edit** 클릭
> 3. 각 `[📎 이미지를 여기에 드롭: ...]` 플레이스홀더를 선택 후 로컬 스크린샷(`wireframes/*.png`)을 드래그앤드롭
> 4. **Update comment** 클릭
>
> 동료 리뷰를 받은 후, `/clear` → `/hs-full-cycle-ralph #<number>`로 Phase 2를 시작하세요.

**`non-ui` 유형:**

Tell the user:
> **Phase 1 (Product Discovery) 완료.** 결과가 이슈 #\<number\>에 저장되었습니다.
>
> 코멘트 링크: \<COMMENT_URL\>
>
> 동료 리뷰를 받은 후, `/clear` → `/hs-full-cycle-ralph #<number>`로 Phase 2를 시작하세요.

- **Do NOT proceed to Phase 2.** Wait for peer review approval before continuing.

---

## Phase 2: Brainstorm, Design & PRD

**Delegated skills:** `/superpowers:brainstorming` → `/ralph-skills:prd`

### Step 1: Brainstorm

- Tell the user: "Phase 2 시작: 브레인스토밍 스킬을 호출합니다."
- Call `/superpowers:brainstorming` with the task description. **Append this instruction to the arguments:**
  > "설계 문서를 git에 커밋하지 마세요. docs/plans/ 파일 저장과 커밋 단계를 건너뛰세요."

### Step 2: Generate PRD

- After brainstorming completes, tell the user: "브레인스토밍 완료. 이어서 PRD를 생성합니다."
- Call `/ralph-skills:prd` — provide the brainstorming results as context. **Append this instruction to the arguments:**
  > "질문 개수를 3~5개로 제한하지 마세요. 모든 모호함과 불확실성이 해소될 때까지 질문을 계속하세요. 한 번에 한 질문씩, 답변을 받은 후 추가 불확실성이 있으면 다시 질문하세요."
- The skill will ask clarifying questions and generate `tasks/prd-[feature-name].md`
- This produces structured user stories with **verifiable acceptance criteria**

### After the skills complete:

- **Mermaid 다이어그램 생성**: Read [references/mermaid-guide.md](references/mermaid-guide.md)의 "Phase 2" 섹션을 참고하여 설계에 적합한 다이어그램 1-3개를 생성한다.
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
  The comment should be **self-contained** with all design decisions and user stories inline.
  **User stories must include full details** (description + acceptance criteria) inside collapsible `<details>` tags
  so that reviewers can expand each story to see the complete specification.
  This also serves as the **single source of truth** — if the worktree is lost or another person/instance
  takes over, the issue comment must contain enough detail to regenerate `prd.json`.
  **Do NOT use checkboxes (`- [ ]`)** for acceptance criteria — progress is tracked via `prd.json`, not issue comments.
  Use plain bullets (`- `) instead.
  ```
  gh issue comment <number> --body "$(cat <<'EOF'
  ## 🧠 Phase 2: 설계 & PRD

  ### 선택된 접근 방식
  [Chosen approach and reasoning]

  ### 탐색한 대안들
  [Alternative approaches and why they were rejected]

  ### 설계 결정사항
  [Key design decisions from brainstorming]

  ### 아키텍처 다이어그램
  [Mermaid diagram(s) — 설계에서 도출된 핵심 흐름, 데이터 모델, 상태 전이 등을 시각화]

  ### 스토리 의존 관계
  [Mermaid flowchart — 스토리 간 실행 순서와 의존 관계. 병렬 가능한 스토리는 같은 레벨에 배치]

  ### 유저 스토리

  <details>
  <summary><b>US-001: [title]</b> — [phase/tag]</summary>

  **Description:** As a [user], I want [feature] so that [benefit].

  **Acceptance Criteria:**
  - Criterion 1
  - Criterion 2
  - ...
  </details>

  <details>
  <summary><b>US-002: [title]</b> — [phase/tag]</summary>

  **Description:** ...

  **Acceptance Criteria:**
  - ...
  </details>

  [Repeat for all stories — each in its own <details> block]

  ### 범위 밖 (Non-goals)
  [From PRD non-goals section]

  ---
  👀 리뷰어: @reviewer1 @reviewer2
  승인 후 태스크 분해를 진행합니다.

  🏁 Phase 2 Complete
  EOF
  )"
  ```

- **CRITICAL:** Verify the `gh issue comment` command succeeded (exit code 0). If failed, retry.

- Tell the user:
  > **Phase 2 (설계 & PRD) 완료.** 결과가 이슈 #\<number\>에 저장되었습니다.
  > 동료 리뷰를 받은 후, `/clear` → `/hs-full-cycle-ralph #<number>`로 Phase 3를 시작하세요.

- **Do NOT proceed to Phase 3.** Wait for peer review approval before continuing.

---

## Phase 3: Task Breakdown + Ralph Launch

**Delegated skill:** `/ralph-skills:ralph`

### Before calling the skill:
- Read the issue body and Phase 1 and Phase 2 comments from the issue
- Tell the user: "Phase 3 시작: 태스크 분해 및 Ralph 실행 준비를 진행합니다."

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
## 📋 Phase 3: 태스크 분해

### 스토리 목록
- US-001: [title]
- US-002: [title]
- US-003: [title]

### 스토리 의존성
[Mermaid flowchart — 스토리 간 실행 순서와 의존 관계. 병렬 가능한 스토리는 같은 레벨에 배치]

### prd.json 준비 완료
Ralph 실행 준비가 완료되었습니다.

---
🏁 Phase 3 Complete
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
> **Phase 3 (태스크 분해 + Ralph 준비) 완료.** prd.json이 준비되었습니다.
> 별도 터미널에서 아래 명령어를 실행해주세요:
>
> ```bash
> cd <worktree_path>
> RALPH_PROMPT="$HOME/.claude/scripts/ralph/CLAUDE.md" ~/.claude/scripts/ralph/ralph.sh 15
> ```
>
> Ralph가 Phase 4(구현) → Phase 5(리뷰) → Phase 6(PR) → Phase 7(PR 리뷰 대응)을 자동 진행합니다.
> 완료되면 GitHub Issue #\<number\>에 각 Phase 결과가 기록됩니다.

Replace `<worktree_path>` with the actual worktree path (from `pwd`).

---

## Ralph Resume

> Use this when Ralph was interrupted mid-way and needs to be re-launched.
> Entered from re-invocation of an issue that has `🏁 Phase 3 Complete` ~ `🏁 Phase 6 Complete`.

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
2. **Memory = GitHub Issue**: Phase 1-3 results MUST be saved as issue comments before launching Ralph
3. **Verify before proceed**: ALWAYS verify `gh issue comment` succeeded (exit code 0) before moving on
4. **Peer review between phases**: Phase 1 and Phase 2 each end with a peer review request. Do NOT proceed to the next phase until the user confirms review approval.
5. **Skill delegation**: Actually call the skills with `/skill-name`. Do NOT replicate their logic manually.
6. **No amending commits**: Always create NEW commits
7. **Phase markers**: Use exact markers (`🏁 Phase N Complete`) for reliable state detection
8. **Blocked = stop**: If blocked at any phase, stop and discuss with the user. Do NOT skip phases.
9. **Task granularity**: Each implement story must fit one context window. Split if too large.
10. **Ralph handles Phase 4-7**: Do NOT manually implement. Let Ralph iterate autonomously.
