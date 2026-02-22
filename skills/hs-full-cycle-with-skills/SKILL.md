---
description: "Use when a new feature needs the complete development cycle orchestrated through specialized skills. Each phase delegates to expert skills (brainstorming, writing-plans, pr-pipeline, verification) with GitHub Issue as persistent memory between /clear sessions. Triggers on phrases like 'full cycle with skills', 'feature end to end with skills', 'orchestrated development cycle'."
---

You are orchestrating a full development cycle by **delegating to specialized skills** at each phase.
GitHub Issue is your **main memory store** — all plans, progress, and decisions are saved as issue comments.
Between phases, you `/clear` the context and resume from the issue.

Task: $ARGUMENTS

---

## Phase 0: State Detection & Environment Setup

### Step 1: Determine the issue

**Case A — Issue number provided (e.g. `#42`):**
- Run `gh issue view <number>` and `gh issue view <number> --comments`
- Scan the **latest comments** to determine current state (see routing table below)

**Case B — No issue number:**
- Tell the user: "이슈 번호가 없습니다. Phase 1에서 브레인스토밍 후 이슈를 생성합니다."
- Proceed to Phase 1

### Step 2: Route to the correct phase

Check the **latest comments** on the issue for these markers:

| Marker in comments | Resume at |
|-|-|
| `🏁 Phase 4 Complete` | **Phase 5** (Verify & Ship) |
| `🏁 Phase 3 Complete` | **Phase 4** (Review) |
| `🏁 Phase 2 Complete` | **Phase 3** (Implement) |
| `🏁 Phase 1 Complete` | **Phase 2** (Plan) |
| None of the above | **Phase 1** (Brainstorm) |

### Step 3: Confirm environment

- Confirm the current directory is the correct worktree for this issue
- If not, ask the user for the worktree path or ask them to set it up

---

## Phase 1: Brainstorm & Clarify

**Delegated skill:** `/superpowers:brainstorming`

### Before calling the skill:
- Tell the user: "Phase 1 시작: 브레인스토밍 스킬을 호출합니다."
- Call `/superpowers:brainstorming` with the task description

### After the skill completes:
- If Case B (no issue): Create a GitHub issue from the brainstorming results
  ```
  gh issue create --title "<feature title>" --body "<requirements summary>"
  ```
  - Present the issue number to the user
  - Ask user to set up the worktree if needed

- **Save to issue** — Post brainstorming results as an issue comment:
  ```
  gh issue comment <number> --body "$(cat <<'EOF'
  ## 🧠 Phase 1: 브레인스토밍 결과

  ### 선택된 접근 방식
  [Chosen approach and reasoning]

  ### 요구사항
  [Key requirements and constraints]

  ### 탐색한 대안들
  [Alternative approaches and why they were rejected]

  ### 설계 결정사항
  [Key design decisions from brainstorming]

  ---
  🏁 Phase 1 Complete
  EOF
  )"
  ```

- **CRITICAL:** Verify the `gh issue comment` command succeeded (exit code 0). If failed, retry. Do NOT clear without confirmation.

- Tell the user:
  > **Phase 1 (브레인스토밍) 완료.** 결과가 이슈 #\<number\>에 저장되었습니다.
  > `/clear` 후 `/hs-full-cycle-with-skills #<number>`로 다음 단계를 시작합니다.

- Execute `/clear`, then trigger `/hs-full-cycle-with-skills #<number>`

---

## Phase 2: Plan

**Delegated skill:** `/superpowers:writing-plans`

### Before calling the skill:
- Read the issue body and Phase 1 comment from the issue
- Tell the user: "Phase 2 시작: 구현 계획 스킬을 호출합니다."
- Call `/superpowers:writing-plans` — provide the brainstorming results from the issue as context

### After the skill completes:
- **Save the plan to issue** — Post as an issue comment:
  ```
  gh issue comment <number> --body "$(cat <<'EOF'
  ## 📋 Phase 2: 구현 계획

  ### 요약
  [Plan summary - chosen approach]

  ### 구현 단계
  1. **Task 1**: [description]
     - 파일: `path/to/file`
     - 변경: [what to change]
  2. **Task 2**: [description]
     ...

  ### 검증 방법
  - [verification steps]

  ### 참고 사항
  - [key findings, edge cases, architecture notes]

  ---
  🏁 Phase 2 Complete
  EOF
  )"
  ```

- **CRITICAL:** Verify the comment succeeded (exit code 0). If failed, retry.

- Tell the user:
  > **Phase 2 (구현 계획) 완료.** 계획이 이슈 #\<number\>에 저장되었습니다.
  > `/clear` 후 구현을 시작합니다.

- Execute `/clear`, then trigger `/hs-full-cycle-with-skills #<number>`

---

## Phase 3: Implement

**Delegated skill:** `/hs-pr-pipeline`

### Before calling the skill:
- Read the issue body, Phase 1 (brainstorming) and Phase 2 (plan) comments
- Read CLAUDE.md for git workflow rules
- The worktree branch IS the feature branch — do NOT create another branch
- Tell the user: "Phase 3 시작: PR 파이프라인 스킬을 호출합니다."
- Call `/hs-pr-pipeline <feature description from plan> #<number>`

### Guidance for the skill:
- Follow the plan steps from Phase 2 in order
- Create NEW commits only (never amend existing ones)
- Do NOT create a PR yet — that happens in Phase 5
- Run relevant checks after each logical unit
- Do not modify .env files
- Stop and ask before deleting environment variables or changing infrastructure type declarations

### After implementation completes:
- **Save progress to issue:**
  ```
  gh issue comment <number> --body "$(cat <<'EOF'
  ## 🔨 Phase 3: 구현 완료

  ### 구현된 변경사항
  [Summary of what was implemented]

  ### 커밋 목록
  [List of commits made]

  ### 발견된 이슈
  [Any issues or deviations from plan]

  ---
  🏁 Phase 3 Complete
  EOF
  )"
  ```

- **CRITICAL:** Verify the comment succeeded (exit code 0). If failed, retry.

- Tell the user:
  > **Phase 3 (구현) 완료.** 진행 상황이 이슈 #\<number\>에 저장되었습니다.
  > `/clear` 후 코드 리뷰를 시작합니다.

- Execute `/clear`, then trigger `/hs-full-cycle-with-skills #<number>`

---

## Phase 4: Review

**Delegated skills:** Code review sub-agents + `/superpowers:requesting-code-review`

### Before calling the skill:
- Read the issue body and Phase 3 comment for what was implemented
- Tell the user: "Phase 4 시작: 코드 리뷰를 진행합니다."

### Review process:
1. Use Task to spawn a sub-agent for **code review** against project style guidelines
2. Use Task to spawn a separate sub-agent to **run the full test suite** and report failures
3. Fix any issues found by review or tests
4. If there are bugs found during review, consider using `/hs-parallel-debug` for complex issues

### After review completes:
- **Save review results to issue:**
  ```
  gh issue comment <number> --body "$(cat <<'EOF'
  ## 🔍 Phase 4: 리뷰 완료

  ### 리뷰 결과
  [Review findings and actions taken]

  ### 테스트 결과
  [Test suite results]

  ### 수정 사항
  [What was fixed based on review]

  ---
  🏁 Phase 4 Complete
  EOF
  )"
  ```

- **CRITICAL:** Verify the comment succeeded (exit code 0). If failed, retry.

- Tell the user:
  > **Phase 4 (리뷰) 완료.** 결과가 이슈 #\<number\>에 저장되었습니다.
  > `/clear` 후 최종 검증을 시작합니다.

- Execute `/clear`, then trigger `/hs-full-cycle-with-skills #<number>`

---

## Phase 5: Verify & Ship

**Delegated skill:** `/superpowers:verification-before-completion`

### Before calling the skill:
- Read all previous phase comments from the issue for full context
- Tell the user: "Phase 5 시작: 최종 검증 스킬을 호출합니다."
- Call `/superpowers:verification-before-completion`

### Verification process:
1. Run the full test suite — **show evidence of passing**
2. Run linter/type checks if applicable — **show evidence**
3. Verify all plan items from Phase 2 are implemented (line-by-line checklist)
4. Confirm no regressions

### After verification passes:
- Create a PR to the target branch with a structured description referencing the issue:
  ```
  gh pr create --title "<title>" --body "$(cat <<'EOF'
  ## Summary
  Closes #<number>

  [Brief description of changes]

  ## Changes Made
  [List of key changes]

  ## Test Plan
  - [Test evidence from verification]

  ## Phase History
  - Phase 1: Brainstorming — [link to comment]
  - Phase 2: Plan — [link to comment]
  - Phase 3: Implementation — [link to comment]
  - Phase 4: Review — [link to comment]
  - Phase 5: Verification — passed
  EOF
  )"
  ```

- **Save final status to issue:**
  ```
  gh issue comment <number> --body "$(cat <<'EOF'
  ## 🚀 Phase 5: 최종 검증 및 PR 생성

  ### 검증 결과
  [Verification evidence]

  ### PR
  [PR link]

  ---
  🏁 Phase 5 Complete — Full Cycle Done
  EOF
  )"
  ```

---

## IMPORTANT RULES

1. **Korean communication**: Think in English internally, but ALWAYS communicate with the user in Korean (한국어)
2. **Memory = GitHub Issue**: All phase results MUST be saved as issue comments before clearing
3. **Verify before clear**: ALWAYS verify `gh issue comment` succeeded (exit code 0) before `/clear`. If it fails, you lose everything.
4. **One phase per session**: Each `/clear` resets the context. One phase runs per session.
5. **Skill delegation**: Actually call the skills with `/skill-name`. Do NOT replicate their logic manually.
6. **No amending commits**: Always create NEW commits
7. **Phase markers**: Use exact markers (`🏁 Phase N Complete`) for reliable state detection
8. **Blocked = stop**: If blocked at any phase, stop and discuss with the user. Do NOT skip phases.
9. **PR timing**: Only create PR in Phase 5, not during Phase 3
