# English Review Skill Redesign Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** english-review 스킬을 플래시카드 기반 구조로 재설계하여 SR 복습, 메트릭스 추적, 코칭 자기개선을 지원한다.

**Architecture:** 단일 커맨드 파일(`~/.claude/commands/english-review.md`)을 재작성. 이 파일은 Claude에게 주어지는 프롬프트이므로 코드가 아닌 자연어 지시문이다. 출력이 단일 파일 → 카드 파일 + 인덱스 파일로 분리되는 것이 핵심 변경.

**Tech Stack:** Obsidian Markdown, YAML frontmatter, Obsidian Spaced Repetition plugin, Dataview plugin

**Spec:** `docs/superpowers/specs/2026-03-12-english-review-redesign.md`

---

## Chunk 1: 핵심 스킬 재작성

### Task 1: 카드 생성 로직이 포함된 english-review.md 재작성

**Files:**
- Modify: `~/.claude/commands/english-review.md` (전면 재작성)

- [ ] **Step 1: 현재 스킬 파일 백업**

```bash
cp ~/.claude/commands/english-review.md ~/.claude/commands/english-review.md.bak
```

- [ ] **Step 2: 스킬 파일 재작성 — 헤더 + 모드 분기**

`~/.claude/commands/english-review.md`의 frontmatter와 모드 분기 섹션:

```markdown
---
description: Review logged English prompts and provide improvement feedback
---

Read prompt log files from `~/obsidian/sb/PARA-2.Area/영어/prompt-review/`.

**모드 분기**:
- 인자 없음 또는 날짜 지정: **일일 분석 모드** (아래 프로세스)
- `--weekly`: **주간 리포트 모드** (별도 섹션 참조)

## 일일 분석 모드

- 날짜 미지정 시: 오늘 포함 최근 3일의 파일을 순서대로 처리 (이미 분석 완료된 날은 자동 건너뜀)
- 날짜 지정 시 (e.g. "2026-02-28"): 해당 날짜 파일만 처리

각 날짜 파일에 대해 아래 프로세스를 반복한다.

**시간대**: 모든 날짜와 시간은 KST (Asia/Seoul) 기준. 파일명의 HHmm도 KST.

**마이그레이션**: 기존 형식(구 `## Analysis` 섹션이 포함된 파일)은 변경하지 않는다. `cards/` 디렉토리에 해당 날짜 카드가 없는 파일만 새 형식으로 처리.
```

- [ ] **Step 3: Idempotency 섹션 재작성**

기존 Analysis 섹션 기반 → 카드 파일 존재 여부 기반으로 변경:

```markdown
### Idempotency — Safe to run multiple times

1. **카드 디렉토리 확인**: `~/obsidian/sb/PARA-2.Area/영어/prompt-review/cards/` 디렉토리가 없으면 생성.

2. **이미 분석된 프롬프트 식별**: `cards/` 디렉토리에서 해당 날짜의 카드 파일 목록을 확인 (e.g. `2026-03-10-*.md`). 이미 카드가 존재하는 타임스탬프는 건너뜀.

3. **새 프롬프트만 분석**: Logged Prompts의 타임스탬프 vs 기존 카드 타임스탬프를 비교. 새로운 것만 카드 생성.

4. **같은 분(minute)에 복수 프롬프트**: 파일명에 `-a`, `-b` 접미사 추가 (e.g. `2026-03-10-1214-a.md`, `2026-03-10-1214-b.md`).

5. **인덱스 업데이트**: Today's Summary와 Analysis Overview는 전체 카드 기준으로 매번 재생성. 임베딩 목록은 기존 + 새 카드로 갱신.

6. **새 프롬프트 없으면**: "새로 분석할 프롬프트가 없습니다." 안내.
```

- [ ] **Step 4: 분석 관점 섹션 재작성**

기존 2개 축 + 새로운 english-score 추가:

```markdown
### 분석 관점

각 프롬프트를 세 가지 관점에서 분석한다:

#### 1. English Expression Review
- Grammar and spelling corrections
- More natural/native-sounding alternatives
- Vocabulary upgrades (casual → professional, awkward → natural)
- **Expression Score** (1-5): 문법 정확성, 자연스러움, 어휘 수준 종합 평가
  - 1: 의미 전달 어려움
  - 2: 의미는 통하나 문법 오류 다수
  - 3: 의미 전달 충분하나 자연스럽지 않음
  - 4: 사소한 오류만 있음, 자연스러움
  - 5: 원어민 수준
- **Error Types 태깅**: 발견된 오류를 다음 카테고리로 분류
  - `article`: 관사 (a/the) 누락 또는 오용
  - `preposition`: 전치사 오류
  - `capitalization`: 대소문자 오류 (고유명사 등)
  - `word-order`: 어순 오류 (한국어 어순 영향)
  - `verb-form`: 동사 형태 오류 (시제, 수동태 등)
  - `vocabulary`: 어휘 선택 오류
  - `spelling`: 철자 오류
  - `other`: 기타

#### 2. Prompting Technique Review
- Clarity, Specificity, Structure, Context
- Score each prompt 1-5 with a brief reason

#### 3. 한국어 변환 (카드 앞면용)
- 모든 프롬프트(영어, 한국어, 혼합)의 한국어 버전을 작성
- 기술 명령어(`git rebase`, 코드 스니펫 등)는 그대로 유지, 자연어 부분만 한국어로
- 원래 한국어 프롬프트는 원문 그대로 사용
```

- [ ] **Step 5: 카드 출력 형식 섹션 작성**

```markdown
### 카드 출력 형식

각 프롬프트에 대해 `cards/YYYY-MM-DD-HHmm.md` 파일을 생성한다.

파일 내용:
~~~markdown
---
tags:
  - flashcard
  - english-learning
date: YYYY-MM-DD
project: <project-name>
error-types:
  - <detected error types>
english-score: N
original-lang: en|kr|mix
# sr-due, sr-interval, sr-ease 필드는 포함하지 않음 — SR 플러그인이 복습 시 자동 추가
---

# 영작 연습

(한국어 문장)
?
(모범 영어 답안 — 교정된 자연스러운 영어)

---

## Original Prompt
> (원문 인용 — 영어 또는 혼합인 경우만)

## Key Learnings
- (2-3개 핵심 학습 포인트, 한국어 설명)

## Expression Score: N/5
(간단한 평가 — 한국어)

## Prompting Score: N/5
(간단한 평가 — 한국어, 본문에만 기재, frontmatter에는 포함하지 않음)

## Context
> [[YYYY-MM-DD|일일 로그로 돌아가기]]
~~~

**규칙**:
- 100% 한국어 프롬프트(`original-lang: kr`): `english-score` frontmatter를 포함하지 않음. `## Original Prompt` 섹션도 생략.
- 영어가 이미 자연스럽고 정확한 경우: "Good" 표시 후 간단히 넘어감 (불필요한 교정 강요 금지)
- 설명은 한국어, 영어 교정은 영어로
- 프롬프트를 시간순으로 읽어 대화 맥락을 이해 — 앞 프롬프트가 뒤 프롬프트를 설명
- 여러 프롬프트에서 반복되는 패턴에 집중
- 격려하되 실수에 대해 솔직할 것
```

- [ ] **Step 6: 인덱스 출력 형식 섹션 작성**

```markdown
### 인덱스 출력 형식

카드 생성이 완료되면, 해당 날짜의 인덱스 파일(`YYYY-MM-DD.md`)을 다음 구조로 업데이트한다.

**frontmatter 갱신** (기존 frontmatter를 대체):
~~~yaml
---
date: YYYY-MM-DD
tags:
  - english-learning
  - prompt-review
total-prompts: N
english-prompts: N
english-ratio: 0.XX
avg-english-score: N.N
error-summary:
  article: N
  preposition: N
  capitalization: N
  (발견된 오류 유형만 포함)
---
~~~

**본문 구조** (이 순서를 반드시 유지):

~~~markdown
# YYYY-MM-DD Prompt Review

## Today's Summary
- **가장 빈번한 실수**: (오류 유형 + 횟수)
- **오늘 기억할 표현**: (하나의 핵심 표현 + 예시)
- **영어 사용률**: N% (영어 프롬프트 수/전체 프롬프트 수) — 전일 대비 변화
- **평균 표현 점수**: N.N/5

## Analysis Overview

| 시간 | 프로젝트 | 원어 | 표현 점수 | 핵심 포인트 |
|------|----------|------|-----------|-------------|
| HH:MM | project | EN/KR/MIX | N/5 또는 - | 한 줄 요약 |

## Analysis

![[YYYY-MM-DD-HHmm]]

![[YYYY-MM-DD-HHmm]]

(모든 카드를 시간순으로 임베딩)

## Logged Prompts

(기존 로그 내용 — 변경하지 않음)
~~~
```

- [ ] **Step 7: 전체 파일 조합 및 저장**

Step 2-6의 내용을 하나의 파일로 조합하여 `~/.claude/commands/english-review.md`에 저장.

- [ ] **Step 8: 수동 테스트 — 일일 분석 실행**

```
/english-review 2026-03-10
```

확인 사항:
- `cards/` 디렉토리 생성 여부
- 개별 카드 파일이 올바른 형식으로 생성되었는지
- 인덱스 파일이 새 구조로 업데이트되었는지
- 기존 `## Logged Prompts`가 보존되었는지
- 임베딩(`![[]]`)이 올바르게 렌더링되는지 (Obsidian에서 확인)

- [ ] **Step 9: 수동 테스트 — Idempotency 확인**

```
/english-review 2026-03-10
```

같은 날짜로 재실행 후 확인:
- "새로 분석할 프롬프트가 없습니다." 메시지 출력
- 기존 카드 파일 변경 없음
- 인덱스 파일 변경 없음

- [ ] **Step 10: 커밋**

```bash
git add ~/.claude/commands/english-review.md
git commit -m "feat: english-review 스킬을 플래시카드 기반 구조로 재설계"
```

---

## Chunk 2: 주간 리포트 모드

### Task 2: `--weekly` 모드 추가

**Files:**
- Modify: `~/.claude/commands/english-review.md` (주간 리포트 섹션 추가)

- [ ] **Step 1: 주간 리포트 섹션 작성**

`english-review.md` 끝에 추가:

```markdown
## 주간 리포트 모드 (`--weekly`)

`/english-review --weekly` 실행 시 주간 메트릭스 리포트를 생성한다.

### 데이터 수집
1. `metrics/` 디렉토리가 없으면 생성
2. 현재 주(월요일~일요일, KST)에 해당하는 인덱스 파일들을 읽음
3. 각 인덱스 파일의 frontmatter에서 지표 추출:
   - `total-prompts`, `english-prompts`, `english-ratio`
   - `avg-english-score`
   - `error-summary`
4. 이전 주 리포트가 있으면 읽어서 비교 데이터로 활용

### 출력 파일
`metrics/weekly-report-YYYY-MM-DD.md` (날짜는 해당 주 월요일)

~~~markdown
---
date: YYYY-MM-DD
period: YYYY-MM-DD ~ YYYY-MM-DD
tags:
  - english-metrics
total-prompts: N
total-english-prompts: N
avg-english-ratio: 0.XX
avg-english-score: N.N
---

# Weekly English Review (MM-DD ~ MM-DD)

## 1. 실수 반복률

| 오류 유형 | 이번 주 | 지난 주 | 변화 |
|-----------|---------|---------|------|
| article | N회 | N회 | ↓/↑ N% |
| ... | | | |

## 2. 영어 사용률

| 날짜 | 전체 | 영어 | 비율 |
|------|------|------|------|
| MM-DD | N | N | N% |
| ... | | | |
| **주간 평균** | | | **N%** |
| 지난 주 평균 | | | N% |

## 3. 영어 표현 점수

| 날짜 | 평균 점수 | 최고 | 최저 |
|------|-----------|------|------|
| MM-DD | N.N | N | N |
| ... | | | |
| **주간 평균** | | | **N.N/5** |
| 지난 주 평균 | | | N.N/5 |

## 코칭 효과 평가

### 개선된 영역
- ✓ (지난 주 대비 감소한 오류 유형 — 감소율과 함께)

### 정체 중인 영역
- ⚠ (7일 중 5일 이상 발생한 오류 유형 — "현재 코칭 방식이 효과 없음" 명시)

### 코칭 방식 조정
- (정체 영역별 구체적 대안 전략 제시)
  - 예: 단순 지적 반복 → 규칙 체크리스트 카드 생성
  - 예: 자주 쓰는 고유명사/전치사 조합 목록 카드 생성

### 신규 발견 패턴
- (이번 주 새로 등장한 오류 유형이 있다면)
~~~

### Idempotency
- 해당 주의 리포트 파일이 이미 존재하면 **덮어쓰기** (주간 리포트는 최신 데이터로 갱신하는 것이 유용)

### 첫 주간 리포트
이전 주 리포트가 없으면:
- "지난 주" 열에 "첫 측정 주" 표시
- "변화" 열에 "-" 표시
- "코칭 효과 평가"의 비교 항목 생략
```

- [ ] **Step 2: 스킬 파일에 주간 리포트 섹션 추가 및 저장**

- [ ] **Step 3: 수동 테스트 — 주간 리포트 생성**

```
/english-review --weekly
```

확인 사항:
- `metrics/` 디렉토리 생성 여부
- 주간 리포트 파일이 올바른 형식으로 생성되었는지
- 인덱스 frontmatter에서 지표가 정확히 집계되었는지
- 코칭 효과 평가 섹션이 의미 있는 내용인지

- [ ] **Step 4: 커밋**

```bash
git add ~/.claude/commands/english-review.md
git commit -m "feat: english-review 주간 리포트 모드 추가"
```

---

## 검증 체크리스트

- [ ] 카드 파일이 Obsidian SR 플러그인에서 플래시카드로 인식되는지 확인
- [ ] `![[카드]]` 임베딩이 Obsidian에서 올바르게 렌더링되는지 확인
- [ ] Dataview 쿼리 `TABLE english-ratio, avg-english-score FROM #prompt-review SORT date DESC`가 작동하는지 확인
- [ ] 백업 파일(`english-review.md.bak`) 삭제
