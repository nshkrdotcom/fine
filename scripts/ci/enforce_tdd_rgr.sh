#!/usr/bin/env bash
set -euo pipefail

if [[ "${GITHUB_EVENT_NAME:-}" != "pull_request" ]]; then
  echo "Skipping TDD/RGR guard outside pull_request events"
  exit 0
fi

base_ref="${GITHUB_BASE_REF:-main}"

git fetch --no-tags --depth=1 origin "${base_ref}"
merge_base="$(git merge-base "origin/${base_ref}" HEAD)"

changed_files="$(git diff --name-only "${merge_base}"...HEAD)"

if [[ -z "${changed_files}" ]]; then
  echo "No changes detected"
  exit 0
fi

requires_tests=0
requires_docs=0
has_tests=0
has_docs=0

while IFS= read -r file; do
  [[ -z "${file}" ]] && continue

  case "${file}" in
    c_include/*|lib/*|mix.exs)
      requires_tests=1
      ;;
  esac

  case "${file}" in
    c_include/fine.hpp|c_include/fine/sync.hpp)
      requires_docs=1
      ;;
  esac

  case "${file}" in
    test/test/*|test/c_src/*|example/test/*)
      has_tests=1
      ;;
  esac

  case "${file}" in
    README.md|CHANGELOG.md|docs/*)
      has_docs=1
      ;;
  esac
done <<< "${changed_files}"

if (( requires_tests == 1 && has_tests == 0 )); then
  echo "TDD/RGR guard failed: code changes detected without test changes." >&2
  echo "Update tests under test/test/, test/c_src/, or example/test/." >&2
  exit 1
fi

if (( requires_docs == 1 && has_docs == 0 )); then
  echo "TDD/RGR guard failed: NIF interface/security headers changed without docs updates." >&2
  echo "Update README.md, CHANGELOG.md, or docs/." >&2
  exit 1
fi

echo "TDD/RGR guard passed"
