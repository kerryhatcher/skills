#!/usr/bin/env bash
# Sheepdog resource gate: free RAM, repo filesystem usage, /tmp usage.
# Kept in a script (not in SKILL.md) because slash-command argument
# substitution rewrites `$N` in SKILL.md, which corrupts awk programs.
#
# Usage: scripts/gate.sh [repo-path]     (default: current directory)
# Env:   RAM_MIN_GIB=4  DISK_MAX_PCT=85  TMP_MAX_PCT=80
# Exit:  0 all clear, 1 at least one gate failed, 2 could not inspect.
set -euo pipefail

case "${1:-}" in
  -h | --help)
    cat <<'EOF'
usage: scripts/gate.sh [repo-path]

Check free RAM, repo filesystem usage and /tmp usage before launching an agent.
Exit 0 when all clear, 1 when a gate fails, 2 when a value can't be read.

env overrides: RAM_MIN_GIB=4  DISK_MAX_PCT=85  TMP_MAX_PCT=80
EOF
    exit 0
    ;;
esac

repo=${1:-$PWD}
if [[ ! -d $repo ]]; then
  echo "gate: not a directory: $repo" >&2
  exit 2
fi

ram_min=${RAM_MIN_GIB:-4}
disk_max=${DISK_MAX_PCT:-85}
tmp_max=${TMP_MAX_PCT:-80}

fail=0

# awk field references below are literal script text, never substituted.
# Available RAM in GiB (MemAvailable is in kB).
ram=$(awk '/^MemAvailable:/{printf "%d", $2 / 1048576}' /proc/meminfo 2>/dev/null || true)
if [[ -z $ram ]]; then
  echo "ram   FAIL: cannot read MemAvailable from /proc/meminfo"
  fail=1
elif ((ram < ram_min)); then
  echo "ram   FAIL: ${ram} GiB available, need ${ram_min} GiB"
  fail=1
else
  echo "ram   ok: ${ram} GiB available (min ${ram_min})"
fi

# Percent used on the filesystem holding $1.
pct_used() {
  df -P "$1" 2>/dev/null | awk 'NR == 2 {gsub(/%/, "", $5); print $5}'
}

check_pct() {
  local label=$1 path=$2 max=$3 pct
  pct=$(pct_used "$path" || true)
  if [[ -z $pct ]]; then
    echo "${label} FAIL: cannot read df for ${path}"
    fail=1
  elif ((pct >= max)); then
    echo "${label} FAIL: ${path} is ${pct}% full, limit ${max}%"
    fail=1
  else
    echo "${label} ok: ${path} is ${pct}% full (limit ${max}%)"
  fi
}

check_pct disk "$repo" "$disk_max"
check_pct tmp /tmp "$tmp_max"

if ((fail)); then
  echo "gate: cleanup needed (see Step 6 of SKILL.md), then re-run" >&2
  exit 1
fi

echo "gate: all checks passed"