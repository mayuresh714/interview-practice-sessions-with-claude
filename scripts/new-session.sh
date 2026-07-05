#!/usr/bin/env bash
# Create today's session file from the template.
# Usage: ./scripts/new-session.sh <type> [company_archetype] [difficulty]
#   type: coding | system-design | ml-genai | behavioral | data-eng
set -euo pipefail

TYPE="${1:?Usage: new-session.sh <type> [company_archetype] [difficulty]}"
COMPANY="${2:-general}"
DIFFICULTY="${3:-medium}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SESSIONS_DIR="$REPO_ROOT/sessions"
TEMPLATE="$REPO_ROOT/prompts/session-template.md"

DATE="$(date +%Y-%m-%d)"

# Day number = count of existing session files + 1
EXISTING_COUNT=$(find "$SESSIONS_DIR" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
DAY_NUM=$(printf "%02d" $((EXISTING_COUNT + 1)))

SLUG="session"
OUT_FILE="$SESSIONS_DIR/${DATE}-day${DAY_NUM}-${TYPE}.md"

if [ -f "$OUT_FILE" ]; then
  echo "Session file already exists: $OUT_FILE"
  exit 1
fi

sed \
  -e "s/^date: YYYY-MM-DD/date: ${DATE}/" \
  -e "s/^day: NN/day: ${DAY_NUM}/" \
  -e "s/^type: coding | system-design | ml-genai | behavioral | data-eng/type: ${TYPE}/" \
  -e "s/^company_archetype: .*/company_archetype: ${COMPANY}/" \
  -e "s/^difficulty: easy | medium | hard/difficulty: ${DIFFICULTY}/" \
  -e "s/^# Day NN — TYPE — slug/# Day ${DAY_NUM} — ${TYPE} — ${SLUG}/" \
  "$TEMPLATE" > "$OUT_FILE"

echo "Created $OUT_FILE"
echo "Next: open Claude Code in this repo and say \"run today's session\"."
