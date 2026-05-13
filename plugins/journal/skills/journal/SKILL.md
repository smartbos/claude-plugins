---
name: journal
description: Use when user wants to record a journal entry with /j or /journal. Quick capture to sb vault daily note's 🗄️ 아카이브 section. Three modes — direct entry, conversation summary, or clarification.
aliases:
  - j
---

# Journal Entry Skill

빠르게 sb 볼트 데일리 노트의 `🗄️ 아카이브` 섹션에 1줄 bullet을 추가하는 스킬.

> **위치**: 현석님 직접 타이핑하는 빠른 잡기록(인지·감정·직감·메모)용. transcript 자동 요약은 sgrade 1.5단계에서 처리됨 — `/j`는 사람의 손글씨에 해당.

## 사용법

1. **직접 기록**: `/j 내용` — 내용을 바로 아카이브에 추가
2. **대화 요약**: `/j` (내용 없이) — 최근 대화를 요약해서 추가
3. **명확화 후 기록**: 내용이 모호하면 질문으로 명확화

## 시간대

**중요**: 모든 날짜/시간은 KST(한국 표준시, UTC+9) 기준.

```bash
TZ='Asia/Seoul' date '+%Y-%m-%d %H:%M %a'
```

## 저널 파일 위치 (sb 볼트 전용, 고정)

- **저널 루트**: `~/obsidian/sb/데일리 노트`
- **파일명**: `YYYY-MM-DD 요일.md` (요일은 풀네임 — 월요일/화요일/수요일/목요일/금요일/토요일/일요일)
- **이번 달**: `~/obsidian/sb/데일리 노트/YYYY-MM-DD 요일.md` (루트 직접)
- **이전 달**: 재정리 진행 정도에 따라 `~/obsidian/sb/데일리 노트/YYYY/...` 또는 `YYYY/MM/...` 하위에 있을 수 있음

### 파일 탐색 순서

1. 루트: `~/obsidian/sb/데일리 노트/YYYY-MM-DD 요일.md`
2. 연 하위: `~/obsidian/sb/데일리 노트/YYYY/YYYY-MM-DD 요일.md`
3. 연/월 하위: `~/obsidian/sb/데일리 노트/YYYY/MM/YYYY-MM-DD 요일.md`
4. 마지막 fallback:
   ```bash
   find ~/obsidian/sb/"데일리 노트" -name "YYYY-MM-DD *.md" 2>/dev/null | head -1
   ```

### 파일 부재 시 (오늘 파일이 아예 없으면)

루트에 새로 생성. 기본 템플릿:

```markdown
---
hb_wakeup_5: false
habit_chickenrank: false
habit_vitamin: false
hb_exec: false
habit_english: false
hb_devstudy: false
habit_ai: false
hb_journal: false
---

# 주간 팀 업무
- [ ]

# 오늘 목표
- [ ]

# 🔭 헤드라인

# 📍 진행 중·미완

# 🗄️ 아카이브

# 감사
-

# 재미
-
```

### 요일 한글 변환

`date '+%a'`는 시스템 locale에 따라 다르게 나오니 영문 약어로 받아 case문 매핑:

```bash
WEEKDAY_EN=$(TZ='Asia/Seoul' date '+%a')
case "$WEEKDAY_EN" in
  Mon) WEEKDAY_KO="월요일";;
  Tue) WEEKDAY_KO="화요일";;
  Wed) WEEKDAY_KO="수요일";;
  Thu) WEEKDAY_KO="목요일";;
  Fri) WEEKDAY_KO="금요일";;
  Sat) WEEKDAY_KO="토요일";;
  Sun) WEEKDAY_KO="일요일";;
esac
```

## 동작 방식

### 모드 1: 직접 기록 (`/j 내용`)
사용자가 명확한 내용을 제공하면:
1. 내용 분석
2. 모호하면 → 모드 3으로 전환
3. 명확하면 → `🗄️ 아카이브` 섹션에 1줄 bullet 추가

### 모드 2: 대화 요약 (`/j`)
내용 없이 호출하면:
1. 이번 세션의 대화 내용 분석
2. 주요 작업/결정/배운 점을 **1~3줄**로 요약
3. 사용자에게 요약 내용 확인
4. 승인 시 `🗄️ 아카이브`에 추가

### 모드 3: 명확화 (`/j 모호한내용`)
내용이 불분명하면:
1. AskUserQuestion으로 구체화 질문
2. 답변으로 내용 보완
3. `🗄️ 아카이브`에 추가

## 모호함 판단 기준
- 주어/목적어 불분명
- "그거", "이거" 같은 지시어만 있음
- 맥락 없이 단어만 나열
- 무엇을 했는지/배웠는지/결정했는지 불명확

## 아카이브 항목 형식

**원칙**: `/j`는 **잡기록**이므로 풀 블록이 아닌 **1줄 bullet** 형식.

```markdown
- 내용 (KST HH:MM)
```

또는 프로젝트 태그 패턴을 따른다면:

```markdown
- **[프로젝트]** 내용 (KST HH:MM)
```

> 풀 블록(고민→시도→효과 아크)은 sgrade 회고 시점에 transcript 요약 단계에서 만들어진다. `/j`는 그 사이의 짧은 메모용.

### 섹션이 없는 구식 파일 처리

이전 파일이 30분 격자 포맷(`### HH:MM ~ HH:MM`)이면:
1. `# 🗄️ 아카이브` 섹션이 없으면 파일 끝에 새로 추가하고 거기에 bullet 기록
2. 30분 격자에 직접 끼워넣지 말 것 — 격자는 이미 폐기된 포맷이고, 새 입력은 새 구조로

## 구현 단계

1. **KST 시간 확인**: `TZ='Asia/Seoul' date '+%Y-%m-%d %H:%M %a'` 실행하여 현재 KST 날짜/시간 획득
2. **요일 한글 변환** (위 case문 참조)
3. **파일 경로 결정**: 위 "파일 탐색 순서" 따라 오늘 파일 찾기
4. **파일 없으면 생성**: 루트에 위 기본 템플릿으로 생성
5. **인자 확인**: 내용이 있는지 없는지 확인
6. **모드 결정**:
   - 내용 없음 → 대화 요약 모드 → 사용자 확인
   - 내용 있음 → 명확성 검사 → 명확하면 바로, 모호하면 AskUserQuestion
7. **`🗄️ 아카이브` 섹션 찾기**:
   - 있으면 그 섹션 안 마지막 줄에 bullet 추가 (Edit 사용)
   - 없으면 파일 끝에 `# 🗄️ 아카이브\n- 내용 (KST HH:MM)` 추가
8. **확인 메시지**: 기록 완료 알림 + 추가된 줄 echo

## 예시

```
/j PR 10개 머지 완료, 배포는 내일부터 매일 1-2개씩 진행 예정
```
→ 명확함. 바로 `🗄️ 아카이브`에 bullet 추가.

```
/j 그거 했음
```
→ 모호함. "무엇을 했나요?" 질문 후 추가.

```
/j
```
→ 대화 요약 모드. 이번 세션에서 한 일을 1~3줄로 정리, 확인 후 기록.
