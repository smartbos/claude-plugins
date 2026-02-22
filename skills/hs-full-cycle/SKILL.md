---
description: "Use when a new feature needs the complete development cycle from brainstorming through PR. Covers all phases: requirements clarification, planning, implementation, review, and shipping. Triggers on phrases like 'new feature end to end', 'full development cycle', 'brainstorm and implement', 'feature from scratch'."
---

You are executing a full development cycle for the following task:

$ARGUMENTS

This skill uses **parallel exploration agents (team) for ideation/planning** and **subagents for execution**.
It operates in **two sessions** to maximize context window efficiency.
Follow these phases strictly in order. Do NOT skip phases or jump ahead.

---

## Phase 0: Issue & Environment Setup

**Case A — Issue number provided (e.g. #42):**
- Read the issue with `gh issue view <number>` and its comments with `gh issue view <number> --comments`
- Check the **latest comments** on the issue to determine the current state:
  - **"Phase 4 (Review) Complete"** exist? → Resume at **Phase 5 (Verify & Ship)**.
  - **"Phase 3 (Implem) Complete"** exist? → Resume at **Phase 4 (Review)**.
  - **"구현 계획"** (Plan) exist? → Resume at **Phase 3 (Implement)**.
  - **None of above** → This is Session 1. Proceed to **Phase 1**.
- Confirm the current directory is the correct worktree for this issue
- If not in the worktree, ask the user for the worktree path

**Case B — No issue number provided:**
- Proceed to Phase 1 first. After brainstorming, create the GitHub issue.
- Present the created issue number to the user
- **Ask the user to run their worktree setup script** with the issue number
- Wait for user confirmation that the worktree is ready
- `cd` to the new worktree directory

All subsequent commits and the PR must reference the issue number.

---

## SESSION 1: Planning (Team Exploration Approach)

### Phase 1: Brainstorm & Clarify

#### Step 1: Parallel Codebase Exploration (Agent Team)

Spawn **3 Task agents in parallel** (subagent_type=Explore) to gather context simultaneously:

| Agent name | Mission | What to return |
|------------|---------|----------------|
| `architecture-explorer` | Explore overall architecture and patterns relevant to this feature | Project structure, design patterns, conventions, relevant abstractions |
| `related-code-explorer` | Find existing code most related to this feature | Similar implementations, APIs, data models, key file paths |
| `test-pattern-explorer` | Understand the testing approach for this area | Test structure, fixtures, helper patterns, coverage conventions |

**IMPORTANT:** Each agent prompt must include the feature description and specific questions to answer. Each agent should return a **concise summary** (not raw code).

#### Step 2: Synthesize & Discuss with User

- Combine all 3 exploration summaries into a unified context picture
- Identify **2-3 possible approaches** with trade-offs, informed by what the agents found
- Present to the user for discussion
- Ask clarifying questions if anything is ambiguous
- Get user approval on the chosen approach
- If Case B: create the issue now, then ask user to run worktree setup and wait

### Phase 2: Plan & Handoff

#### Step 1: Parallel Planning Analysis (Agent Team)

Spawn **2 Task agents in parallel** (subagent_type=Explore):

| Agent name | Mission |
|------------|---------|
| `dependency-analyzer` | Trace dependencies of files to be changed. Identify ripple effects and potential breaking changes. |
| `test-strategy-planner` | Based on the chosen approach, outline what tests are needed, which test files to modify/create, and verification steps. |

#### Step 2: Create Structured Plan

Combine all analysis results into a structured plan:
- Summary of the chosen approach
- Step-by-step implementation tasks (small, testable increments of 5-15 lines)
- For each step: files to modify, what to change, dependencies on other steps
- Mark which steps are **independent** (can be parallelized) vs **sequential**
- Verification strategy (incorporating test-strategy-planner findings)
- Dependency/ripple-effect notes (incorporating dependency-analyzer findings)

#### Step 3: Approve & Post to Issue

- Get user approval on the plan
- **Post the plan as a GitHub issue comment:**

```
gh issue comment <number> --body "$(cat <<'PLAN_EOF'
## 구현 계획

### 요약
[Chosen approach summary]

### 구현 단계
1. **Step 1**: [description]
   - 파일: `path/to/file`
   - 변경: [what to change]
   - 의존: 없음 | Step N
2. **Step 2**: [description]
   ...

### 병렬 실행 가능 그룹
- Group A (독립): Step 1, Step 3
- Group B (Step 1 이후): Step 2, Step 4
- ...

### 검증 방법
- [verification steps]

### 참고 사항
- [key findings, edge cases, architecture notes from exploration]

---
🤖 Session 1 완료. 자동으로 세션을 클리어하고 구현(Session 2)을 시작합니다.
PLAN_EOF
)"
```

- After posting, tell the user:
  > **Session 1 (Planning) 완료.** 구현 계획이 이슈 #<number>에 게시되었습니다.
  > 자동으로 세션을 클리어하고(`/clear`) 구현을 시작합니다.

**CRITICAL: Verify the `gh issue comment` command succeeded (exit code 0) before proceeding.**
If the comment failed, DO NOT clear. You will lose the plan. Retry posting.

**Only if the comment exists:** Execute `/clear` to reset the session context, then trigger `/hs-full-cycle #<number>` to start Session 2.

---

## SESSION 2: Implementation (Subagent-Driven)

_Entered when Phase 0 detects a plan or progress comment on the issue._

### Phase 3: Implement (Subagent Execution)

- Read the issue body for requirements and the plan comment for implementation steps
- Read CLAUDE.md for git workflow rules
- The worktree branch is the feature branch — do NOT create another branch

**Execution strategy:**

1. **Group plan steps** by the parallel execution groups identified in the plan
2. For each group:
   - **Independent steps** → Dispatch multiple Task subagents in parallel (subagent_type=general-purpose), one per step
   - **Sequential steps** → Dispatch one subagent at a time, wait for completion before next
3. Each subagent receives:
   - The specific step(s) to implement
   - Relevant file paths and context from the plan
   - Instruction to create NEW commits only (never amend)
   - Instruction not to modify .env files
4. After each subagent completes:
   - Verify the changes (read modified files, run relevant checks)
   - If issues found, dispatch a fix subagent before moving on
5. After all steps complete, run a quick sanity check (build + core tests)

**IMPORTANT:**
- Do not modify .env files
- Stop and ask before deleting any environment variables or changing infrastructure type declarations
- If a subagent reports being blocked, stop and discuss with the user

**CHECKPOINT (End of Phase 3):**
1. Post a comment: `🤖 Phase 3 (Implem) Complete. Starting Review.`
2. **Verify comment success (exit code 0).** If failed, retry.
3. If success: `/clear` the session, then run `/hs-full-cycle #<number>` to resume at Phase 4.

### Phase 4: Review (Parallel Subagents)

Spawn **2 Task subagents in parallel:**

| Subagent | subagent_type | Task |
|----------|---------------|------|
| Code reviewer | general-purpose | Review all changes against project style guidelines. Report issues with file:line references. |
| Test runner | general-purpose | Run the full test suite. Report any failures with details. |

After both complete:
- Fix any issues found by review or tests
- Re-run tests if fixes were made

**CHECKPOINT (End of Phase 4):**
1. Post a comment: `🤖 Phase 4 (Review) Complete. Starting Verification.`
2. **Verify comment success (exit code 0).** If failed, retry.
3. If success: `/clear` the session, then run `/hs-full-cycle #<number>` to resume at Phase 5.

### Phase 5: Verify & Ship

- Run the full test suite one final time and confirm ALL tests pass
- Show evidence of passing tests before proceeding
- Create a PR to devel with a structured description referencing the issue
- Include: Summary, Changes Made, Test Plan in the PR description

---

IMPORTANT RULES:
- Think and reason in English internally, but ALWAYS communicate with the user in Korean (한국어)
- Present results and get approval at the end of each phase before moving to the next
- Do not amend commits — always create new ones
- Do not commit design docs or plans unless explicitly asked
- If blocked at any phase, stop and discuss with the user
- Session 1 MUST end after Phase 2 (plan posted to issue). Then, allow the session to clear and restart Phase 0/3 via the command immediately.
- **Team approach for exploration**: Always spawn exploration agents in parallel. Do NOT explore sequentially when parallel exploration is possible.
- **Subagent approach for execution**: Dispatch implementation work to subagents. Main agent orchestrates and verifies.
