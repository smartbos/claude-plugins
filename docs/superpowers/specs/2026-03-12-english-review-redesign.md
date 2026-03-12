# English Review Skill Redesign

Date: 2026-03-12

## Problem

현재 english-review 스킬은 하루치 프롬프트를 단일 파일에 분석 결과와 함께 작성한다. 이로 인해:
- 파일이 40-50KB로 비대해져 스크롤이 불편
- 개별 학습 포인트를 복습하기 어려움
- 장기적 실력 변화를 추적할 수 없음
- 같은 피드백이 반복되어도 코칭 방식이 바뀌지 않음

## Scope

이 스펙은 기존 `~/.claude/commands/english-review.md` 글로벌 커맨드의 출력 형식과 기능을 재설계한다.
- **입력 소스**: `~/obsidian/sb/PARA-2.Area/영어/prompt-review/YYYY-MM-DD.md`의 `## Logged Prompts` 섹션 (기존과 동일, 외부 훅이 자동 수집)
- **스킬 위치**: `~/.claude/commands/english-review.md` (기존 유지)
- **시간대**: KST (Asia/Seoul) — 파일명, 날짜 기준 모두 KST
- **마이그레이션**: 기존 파일은 변경하지 않음. 새 형식은 다음 실행부터 적용.

## Design

### 1. 플래시카드 노트 구조

각 프롬프트가 `cards/` 디렉토리의 개별 노트가 된다. Obsidian Spaced Repetition 플러그인 호환.

**파일명**: `cards/YYYY-MM-DD-HHmm.md` (같은 분에 복수 프롬프트가 있으면 `-a`, `-b` 접미사 추가: `2026-03-10-1214-a.md`)

**구조**:
```markdown
---
tags:
  - flashcard
  - english-learning
# sr-due, sr-interval, sr-ease: SR 플러그인이 복습 시 자동 추가하므로 생성 시 포함하지 않음
date: YYYY-MM-DD
project: <project-name>
error-types:
  - article
  - preposition
english-score: 3
original-lang: en|kr|mix
---

# 영작 연습

(한국어 문장 — 원래 영어였어도 한국어로 변환)
?
(모범 영어 답안)

---

## Original Prompt
> (원래 영어였던 경우만 포함)

## Key Learnings
- (2-3개 학습 포인트)

## Expression Score: N/5
(간단한 평가)

## Context
> [[YYYY-MM-DD|일일 로그로 돌아가기]]
```

**핵심 결정사항**:
- 카드 앞면은 **항상 한국어** — 영어 프롬프트도 한국어로 변환하여 영작 연습용으로 활용
- `original-lang` frontmatter로 원어 구분 — 추후 "어떤 원어에서 더 많이 배우는가" 분석 가능
- 영어 원문은 `## Original Prompt`에 보존 — "내가 쓴 것 vs 교정본" 비교 학습
- 기술 명령어(`git rebase`, 코드 스니펫 등)가 포함된 경우: 명령어 부분은 그대로 유지하고 자연어 부분만 한국어로 변환
- 100% 한국어 프롬프트(`original-lang: kr`)도 카드를 생성하되, `english-score`는 부여하지 않음 (영작 연습 전용)

### 2. 인덱스 파일 구조

기존 일일 파일이 가벼운 인덱스 + 요약으로 변경된다.

**구조**:
```markdown
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
---

# YYYY-MM-DD Prompt Review

## Today's Summary
- 가장 빈번한 실수
- 오늘 기억할 표현
- 영어 사용률
- 평균 표현 점수

## Analysis Overview
| 시간 | 프로젝트 | 원어 | 점수 | 핵심 포인트 |
|------|----------|------|------|-------------|
| ... | ... | ... | ... | ... |

## Analysis

![[YYYY-MM-DD-HHmm]]
![[YYYY-MM-DD-HHmm]]
...

## Logged Prompts
(기존 로그 — 맨 아래)
```

**핵심 결정사항**:
- frontmatter에 일일 지표 포함 — Dataview 쿼리로 추세 분석 가능
- Analysis Overview 테이블 — 카드 목차 역할
- `![[]]` 트랜스클루전으로 카드 내용을 인라인 표시 — 스크롤만으로 전체 리뷰 확인
- Logged Prompts는 맨 아래 — 관심 컨텐츠(Analysis)가 먼저

### 3. 메트릭스 시스템

3가지 지표를 주간 단위로 추적.

**파일**: `metrics/weekly-report-YYYY-MM-DD.md`

**지표**:
1. **실수 반복률** — 오류 유형별 빈도 추이 (article, preposition, capitalization 등)
2. **영어 사용률** — 전체 프롬프트 중 영어 비율
3. **영어 표현 점수** — 문법/자연스러움/어휘 수준 평가 (1-5)

**코칭 자기개선**:
- 주간 리포트에 "코칭 효과 평가" 섹션 포함
- **정체 감지 기준**: 같은 오류 유형(error-type 단위)이 해당 주 7일 중 5일 이상 발생하면 "비효과적" 판단
- 정체 감지 → 대안 코칭 전략 제시 (체크리스트, 고유명사 목록 등)
- 첫 주간 리포트 생성 시 이전 데이터가 없으면 비교 섹션은 "첫 측정 주" 표시

**주간 리포트 기준**:
- 파일명의 날짜는 해당 주 월요일 (e.g., `weekly-report-2026-03-10.md`)
- 집계 범위: 월요일~일요일 (KST)

### 4. 디렉토리 구조

```
~/obsidian/sb/PARA-2.Area/영어/prompt-review/
├── YYYY-MM-DD.md                    ← 인덱스
├── cards/
│   ├── YYYY-MM-DD-HHmm.md          ← 플래시카드
│   └── ...
└── metrics/
    ├── weekly-report-YYYY-MM-DD.md  ← 주간 리포트
    └── ...
```

### 5. 워크플로우

**매일 (자동/수동)**:
1. `/english-review` 실행
2. 새 프롬프트마다 `cards/` 에 플래시카드 노트 생성
3. 인덱스 파일 업데이트 (Summary + Overview + 임베딩 + frontmatter)

**매주 (자동/수동)**:
1. `/english-review --weekly` 또는 cron
2. 지난 7일 인덱스 frontmatter 집계
3. 지난 주 리포트와 비교
4. 주간 리포트 생성 (지표 + 코칭 효과 평가 + 전략 조정)

**Obsidian (사용자)**:
- SR 플러그인으로 카드 복습 (한국어 → 영작 → 확인)

### 6. Idempotency

- 카드 파일명이 `날짜-시간`이므로 이미 존재하면 건너뜀
- 인덱스의 임베딩 목록도 기존 카드 확인 후 새 것만 추가
- 주간 리포트도 날짜 기반 파일명으로 중복 방지

### 7. 스킬 변경 요약

| 항목 | 현재 | 변경 후 |
|------|------|---------|
| Analysis 출력 | 인덱스 파일에 직접 작성 | cards/ 개별 노트 + 인덱스에 임베딩 |
| 카드 형식 | 없음 | SR 호환 ? 구분자 + frontmatter |
| 카드 앞면 | 없음 | 항상 한국어 (영어도 변환) |
| 인덱스 구조 | Summary → Analysis → Logs | Summary → Overview → 임베딩 → Logs |
| 점수 체계 | 프롬프팅 점수만 | 프롬프팅 + 영어 표현 점수 |
| frontmatter | date, tags만 | + 일일 지표 |
| 주간 리포트 | 없음 | --weekly 플래그로 생성 |
| 코칭 자기개선 | 없음 | 주간 리포트에서 정체 감지 → 전략 조정 |
