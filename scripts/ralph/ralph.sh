#!/bin/bash
# Ralph Loop - spawns fresh Claude instances per iteration
# Based on snarktank/ralph, customized for hs-full-cycle-ralph workflow

set -euo pipefail

MAX_ITERATIONS=${1:-15}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPT_FILE="${RALPH_PROMPT:-$SCRIPT_DIR/CLAUDE.md}"
WORK_DIR="${RALPH_WORK_DIR:-.}"

cd "$WORK_DIR"

# Validate required files
if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERROR: Prompt file not found: $PROMPT_FILE"
  exit 1
fi

if [ ! -f "prd.json" ]; then
  echo "ERROR: prd.json not found in $WORK_DIR"
  exit 1
fi

# Check jq availability for story validation
if command -v jq &>/dev/null; then
  JQ_AVAILABLE=true
else
  echo "WARNING: jq not found. Story count validation disabled."
  JQ_AVAILABLE=false
fi

# Recover from interrupted run (future-proofing for prd.json isolation)
if [ -f "prd.json.full" ]; then
  echo "WARNING: Found leftover prd.json.full from interrupted run. Restoring."
  mv prd.json.full prd.json
fi

# Initialize progress.txt if not exists
if [ ! -f "progress.txt" ]; then
  echo "## Codebase Patterns" > progress.txt
  echo "" >> progress.txt
fi

# Archive previous run if branch changed
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
if [ -f ".last-branch" ]; then
  LAST_BRANCH=$(cat .last-branch)
  if [ "$BRANCH" != "$LAST_BRANCH" ]; then
    ARCHIVE_DIR="archive/$(date +%Y%m%d)-${LAST_BRANCH}"
    mkdir -p "$ARCHIVE_DIR"
    [ -f "progress.txt" ] && cp progress.txt "$ARCHIVE_DIR/"
    [ -f "prd.json" ] && cp prd.json "$ARCHIVE_DIR/"
    echo "Archived previous run to $ARCHIVE_DIR"
  fi
fi
echo "$BRANCH" > .last-branch

echo "=== Ralph Loop Start ==="
echo "Branch: $BRANCH"
echo "Max iterations: $MAX_ITERATIONS"
echo "Prompt: $PROMPT_FILE"
echo ""

for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo "--- Iteration $i/$MAX_ITERATIONS ---"
  echo "$(TZ=Asia/Seoul date '+%Y-%m-%d %H:%M KST') - Starting iteration $i" >> progress.txt

  # Pre-iteration: snapshot story count + determine next story
  INJECT=""
  PRE_DONE=-1
  if $JQ_AVAILABLE; then
    PRE_DONE=$(jq '[.userStories[] | select(.passes == true)] | length' prd.json 2>/dev/null || echo "-1")

    NEXT_STORY=$(jq -r '
      [.userStories[] | select(.passes == false)] |
      sort_by(
        (if .phase == "implement" then 0
         elif .phase == "review" then 1
         elif .phase == "ship" then 2
         elif .phase == "pr-review" then 3
         else 0 end),
        .priority
      ) | first | .id // empty
    ' prd.json 2>/dev/null)

    if [ -n "$NEXT_STORY" ]; then
      PHASE=$(jq -r --arg id "$NEXT_STORY" '.userStories[] | select(.id == $id) | .phase // "implement"' prd.json 2>/dev/null)
      INJECT="

## Current Iteration Target
Story: $NEXT_STORY | Phase: $PHASE
This is your ONLY task for this iteration."
      echo "  Target: $NEXT_STORY ($PHASE)"
    else
      echo "=== All stories already complete ==="
      exit 0
    fi
  fi

  OUTPUT=$(claude --dangerously-skip-permissions --print -p "$(cat "$PROMPT_FILE")${INJECT}" 2>&1) || true

  echo "$OUTPUT"

  # Post-iteration: validate story count
  if $JQ_AVAILABLE && [ "$PRE_DONE" != "-1" ]; then
    POST_DONE=$(jq '[.userStories[] | select(.passes == true)] | length' prd.json 2>/dev/null || echo "-1")
    if [ "$POST_DONE" != "-1" ]; then
      DELTA=$((POST_DONE - PRE_DONE))
      if [ "$DELTA" -gt 1 ]; then
        echo "⚠️  VIOLATION: $DELTA stories completed in iteration $i (expected ≤1)"
      elif [ "$DELTA" -eq 1 ]; then
        echo "✅ 1 story completed in iteration $i"
      elif [ "$DELTA" -eq 0 ]; then
        echo "⏸️  No story completed in iteration $i"
      fi
    fi
  fi

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "=== Ralph Loop Complete at iteration $i ==="
    exit 0
  fi

  # Also check if all stories are done (external validation)
  if $JQ_AVAILABLE; then
    REMAINING=$(jq '[.userStories[] | select(.passes == false)] | length' prd.json 2>/dev/null || echo "1")
    if [ "$REMAINING" -eq 0 ]; then
      echo ""
      echo "=== All stories complete at iteration $i (external check) ==="
      exit 0
    fi
  fi

  echo ""
  sleep 2
done

echo "=== Ralph Loop: max iterations ($MAX_ITERATIONS) reached ==="
exit 1
