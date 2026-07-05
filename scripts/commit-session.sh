#!/usr/bin/env bash
# Commit and push today's session so the GitHub activity graph reflects
# each day's practice.
# Usage: ./scripts/commit-session.sh [extra commit message detail]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DATE="$(date +%Y-%m-%d)"
DETAIL="${*:-}"

TODAY_FILE=$(find sessions -maxdepth 1 -name "${DATE}-*.md" | sort | tail -n 1)

if [ -z "$TODAY_FILE" ]; then
  echo "No session file found for ${DATE} in sessions/. Run new-session.sh first."
  exit 1
fi

git add "$TODAY_FILE"

MSG="Practice session: $(basename "$TODAY_FILE" .md)"
if [ -n "$DETAIL" ]; then
  MSG="$MSG — $DETAIL"
fi

git commit -m "$MSG"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"

echo "Committed and pushed: $TODAY_FILE"
