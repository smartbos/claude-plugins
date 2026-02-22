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

  OUTPUT=$(claude --dangerously-skip-permissions --print -p "$(cat "$PROMPT_FILE")" 2>&1) || true

  echo "$OUTPUT"

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "=== Ralph Loop Complete at iteration $i ==="
    exit 0
  fi

  echo ""
  sleep 2
done

echo "=== Ralph Loop: max iterations ($MAX_ITERATIONS) reached ==="
exit 1
