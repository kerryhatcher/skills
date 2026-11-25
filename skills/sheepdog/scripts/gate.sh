#!/usr/bin/env bash
# Sheepdog resource gate: free RAM, repo filesystem usage, /tmp usage.
# Kept in a script (not in SKILL.md) because slash-command argument
# substitution rewrites `$N` in SKILL.md, which corrupts awk programs.
#
# Usage: <skill-dir>/scripts/gate.sh [repo-path]
#        (default: the git top level of the current directory, else $PWD)
# Env:   RAM_MIN_GIB=4  DISK_MAX_PCT=85  TMP_MAX_PCT=80  (whole numbers)
# Exit:  0 all clear, 1 at least one gate failed, 2 a value could not be
#        read (and nothing failed) or bad arguments.
set -euo pipefail

case "${1:-}" in
  -h | --help)
    cat <<'EOF'
usage: <skill-dir>/scripts/gate.sh [repo-path]

Check free RAM, repo filesystem usage and /tmp usage before launching an agent.
repo-path defaults to the git top level of the current directory.
Exit 0 when all clear, 1 when a gate fails, 2 when a value can't be read
(and no gate failed) or the arguments are invalid.

env overrides (whole numbers): RAM_MIN_GIB=4  DISK_MAX_PCT=85  TMP_MAX_PCT=80
EOF
    exit 0
    ;;
esac

if [[ -n ${1:-} ]]; then
  repo=$1
else
  repo=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
fi
if [[ ! -d $repo ]]; then
  echo "gate: not a directory: $repo" >&2
  exit 2
fi
repo=$(cd "$repo" && pwd -P)

ram_min=${RAM_MIN_GIB:-4}
disk_max=${DISK_MAX_PCT:-85}
tmp_max=${TMP_MAX_PCT:-80}

for var in RAM_MIN_GIB:"$ram_min" DISK_MAX_PCT:"$disk_max" TMP_MAX_PCT:"$tmp_max"; do
  if [[ ! ${var#*:} =~ ^[0-9]+$ ]]; then
    echo "gate: ${var%%:*} must be a whole number, got '${var#*:}'" >&2
    exit 2
  fi
done

# Bash treats leading-zero integer literals as octal in arithmetic contexts.
# Normalize accepted overrides before comparing them.
ram_min=$((10#$ram_min))
disk_max=$((10#$disk_max))
tmp_max=$((10#$tmp_max))

fail=0
unknown=0

# awk field references below are literal script text, never substituted.
# Available RAM in GiB (MemAvailable is in kB).
ram=$(awk '/^MemAvailable:/{printf "%d", $2 / 1048576}' /proc/meminfo 2>/dev/null || true)
if [[ -z $ram ]]; then
  echo "ram   UNKNOWN: cannot read MemAvailable from /proc/meminfo"
  unknown=1
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
    echo "${label} UNKNOWN: cannot read df for ${path}"
    unknown=1
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

if ((unknown)); then
  echo "gate: some values could not be read; treat them as unknown and ask the user" >&2
  exit 2
fi

echo "gate: all checks passed"
