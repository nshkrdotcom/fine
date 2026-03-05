#!/usr/bin/env bash
set -euo pipefail

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep (rg) is required" >&2
  exit 1
fi

status=0

while IFS=: read -r file line content; do
  uses_value="${content#*uses:}"
  uses_value="$(echo "$uses_value" | xargs)"

  # Local actions and docker references are outside SHA pinning scope.
  if [[ "$uses_value" == ./* ]] || [[ "$uses_value" == docker://* ]]; then
    continue
  fi

  if [[ "$uses_value" != *@* ]]; then
    echo "${file}:${line}: action reference must include @<sha>: ${uses_value}" >&2
    status=1
    continue
  fi

  ref="${uses_value##*@}"
  if [[ ! "$ref" =~ ^[0-9a-f]{40}$ ]]; then
    echo "${file}:${line}: action reference must be pinned to a full commit SHA: ${uses_value}" >&2
    status=1
  fi
done < <(rg -n '^[[:space:]]*uses:[[:space:]]+' .github/workflows/*.yml)

exit "$status"
