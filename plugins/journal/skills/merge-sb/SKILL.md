---
name: merge-sb
description: Use when user wants to merge work journals into personal Obsidian daily notes. Triggers on 'sb 병합', '저널 병합', '노트 병합', '데일리 노트 병합', 'merge sb'.
aliases:
  - 병합
  - sync-sb
---

# 저널 → sb 데일리 노트 병합

warmble-jumble 업무 저널을 개인 Obsidian(sb) 데일리 노트로 병합한다.
방향은 **단방향**: warmble-jumble → sb. sb 고유 내용은 보존하고, WJ 내용만 추가한다.

## 시간대

모든 날짜는 KST 기준.

```bash
TZ='Asia/Seoul' date '+%Y-%m-%d %H:%M %a'
```

## 설정

`.claude/journal.local.md` frontmatter에서 경로를 읽는다:

```yaml
---
journal_root: ./personal/hyunseok/01.journals
sb_daily_root: /Users/smartbosslee/obsidian/sb/데일리 노트
sb_template: /Users/smartbosslee/obsidian/sb/템플릿/데일리 노트 템플릿.md
---
```

`sb_daily_root`가 없으면 AskUserQuestion으로 경로를 물어보고 저장한다.

## 파일명 매핑

| 소스 (WJ) | 대상 (sb) |
|-----------|-----------|
| `{journal_root}/2026/02/09 월.md` | `{sb_daily_root}/2026-02-09 월요일.md` |

변환 규칙:
- WJ: `DD 요일.md` (월, 화, 수, 목, 금, 토, 일)
- sb: `YYYY-MM-DD 요일요일.md` (월요일, 화요일, ...)

## 사용법

- `/merge-sb` → 오늘 저널 병합
- `/merge-sb 어제` → 어제 저널 병합
- `/merge-sb 이번주` → 이번 주(월~오늘) 저널 일괄 병합
- `/merge-sb 2/9` → 특정 날짜 병합

여러 날짜인 경우, 각 날짜에 대해 아래 프로세스를 반복한다.

## 병합 프로세스

### 1단계: 소스 파일 읽기

WJ 저널 파일을 Read로 읽는다. 파일이 없으면 해당 날짜는 건너뛴다.

### 2단계: 대상 파일 확인

sb 데일리 노트가 존재하면 Read로 읽는다.
없으면 `sb_template` 경로의 템플릿 파일을 복사하여 생성한다.

### 3단계: 내용 추출 (WJ)

WJ 저널에서 세 영역을 추출:

1. **업무 목표**: `### 주간 목표` ~ 첫 번째 `---` 사이 (주간 목표 + 오늘 목표)
2. **타임블록 내용**: `### HH:MM ~ HH:MM` 블록 중 내용이 있는 것들
3. **Daily Reflection**: `## Daily Reflection` 이하 전체 (있을 때만)

### 4단계: 병합

sb 파일에 다음을 삽입/추가:

**업무 목표** → `# 일상 기록` 바로 다음, 첫 타임블록 이전에 삽입:

```markdown
# 일상 기록

## 업무
### 주간 목표
(WJ 내용)
### 오늘 목표
(WJ 내용)

---

### 05:00 ~ 05:30
```

**타임블록** → 같은 시간대 블록에 내용 추가:
- sb 블록이 비어있으면: WJ 내용을 그대로 삽입
- sb 블록에 기존 내용이 있으면: 기존 내용 유지, WJ 내용을 아래에 추가

**Daily Reflection** → `# 감사` 섹션 바로 위에 삽입:

```markdown
---
## Daily Reflection
(WJ 내용)

# 감사
```

### 5단계: 결과 보고

병합 결과를 간단히 요약:
- 추가된 타임블록 수
- 충돌(양쪽 모두 내용 있음) 블록 수
- Daily Reflection 포함 여부

## 충돌 처리

같은 타임블록에 양쪽 모두 내용이 있는 경우:
1. sb 내용을 먼저 배치 (개인 기록 우선)
2. WJ 내용을 그 아래에 추가
3. 별도 구분자 없이 자연스럽게 이어붙임

## 중복 방지

`## 업무` 섹션이 이미 존재하면 병합 완료된 파일로 간주하고, 사용자에게 덮어쓸지 확인한다.

## 주의사항

- sb frontmatter(습관 트래커)는 절대 수정하지 않는다
- sb의 `# 감사`, `# 재미` 섹션은 보존한다
