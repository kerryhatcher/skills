#!/usr/bin/env bash
# Validate every skills/*/SKILL.md: frontmatter present, name matches dir, description set,
# and no personal absolute paths (this repo is public).
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
for f in skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  fm=$(awk 'NR==1&&$0!="---"{exit 1} NR>1&&$0=="---"{exit} NR>1{print}' "$f") || { echo "FAIL $f: no frontmatter"; fail=1; continue; }
  name=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p')
  desc=$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p')
  [[ "$name" == "$dir" ]] || { echo "FAIL $f: name '$name' != directory '$dir'"; fail=1; }
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "FAIL $f: name must be lowercase-hyphenated"; fail=1; }
  [[ -n "$desc" ]] || { echo "FAIL $f: missing description"; fail=1; }
done
if grep -rnE '/(home|Users)/[A-Za-z0-9_.-]+' skills template README.md AGENTS.md; then
  echo "FAIL: hardcoded home path found (use \$HOME)"; fail=1
fi
[[ $fail -eq 0 ]] && echo "OK: all skills valid"
exit $fail
