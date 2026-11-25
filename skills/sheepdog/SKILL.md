---
name: sheepdog
description: Use when you want sub-agents, to delegate or coordinate work across other agents, to split a feature into parallel parts in git worktrees, or to run background tasks, servers or long-running commands through herdr-core (hc). Load this instead of herdr-core directly; it adds which harnesses and models to use for each role, cross-model review, agent naming, worktree-per-part workflow, integration, and resource cleanup, and tells you to load herdr-core as well.
---

# Sheepdog

Sheepdog is a policy layer on top of the **herdr-core** skill. herdr-core
explains *how* to run and coordinate agents with `hc`. Sheepdog decides
*which* harness and model each kind of work gets, how agents are named, how
work is split across git worktrees, and how resources are freed afterwards.

You, the agent that loaded this skill, are the **controller**. You plan at a
high level, start and stop role agents, and own cleanup. You don't do the
roles' work yourself when a role agent is available.

## Step 1: load herdr-core first

Before doing anything else, load the `herdr-core` skill and follow it,
including running `hc --skill` as it instructs. If the herdr-core skill is
not installed, stop and tell the user; do not guess at `hc` usage.

Where herdr-core and sheepdog conflict, sheepdog wins on harness and model
choice, naming, worktrees and cleanup. On everything else, follow herdr-core.

At the start of a session, pick a short run ID and label every terminal you
start with it, so you can find and clean up only your own work:

```sh
run="sd-$(date +%m%d%H%M)"   # e.g. sd-11251430
```

## Step 2: pick a role, then its harness and model

Classify each delegated task into one role below. Use an `hc templates`
entry only if it pins the same harness and model as this table.

| Role | Name prefix | Use for | Harness and model | Fallback (in order) |
| --- | --- | --- | --- | --- |
| planner | `plan` | Breaking down a part, design, specs | `claude --model opus` (latest Opus) | `claude --model sonnet`, then pi round robin |
| implementer | `dev` | Writing and editing code | `codex --model <latest Terra>` | pi round robin |
| quick | `quick` | Small lookups, trivial edits, summaries | pi round robin | `claude --model sonnet` |
| reviewer | `review` | Read-only review of plans and changes | chosen per artifact; see **Step 2b** | see Step 2b |
| integrator | `integ` | Merging part branches, resolving conflicts, running the full test suite, PRs | `claude --model sonnet` | `codex --model <latest Sol>`, then Claude Opus |

"Fallback" means the primary harness isn't installed, failed the quota gate
(Step 3), or failed twice on the same task. Say once in your report which
fallback you used and why.

### Resolving "latest" model names

- **Claude:** `--model opus` and `--model sonnet` are aliases that always
  resolve to the newest Opus or Sonnet. Don't pin a version.
- **Codex Terra / Sol:** use the highest-numbered `gpt-<version>-terra` (or
  `-sol`) that Codex lists, from Codex's `/model` picker or the `slug`
  fields in `$HOME/.codex/models_cache.json`. As of 2026-11-25 these are
  `gpt-6.1-terra` and `gpt-6.2-sol`. Terra and Sol versions move
  independently, so check each one.

### pi round robin

pi may only be launched on **OpenRouter** with one of these two models:

- `~deepseek/deepseek-flash-latest`
- `~z-ai/glm-flash-latest`

Every pi launch, for any role, **alternates** between them: each launch uses
the model the previous pi launch did not. Keep the turn in a state file so
it carries across waves and sessions:

```sh
state="${XDG_STATE_HOME:-$HOME/.local/state}/sheepdog/pi-next"
mkdir -p "$(dirname "$state")"
next=$(cat "$state" 2>/dev/null || echo '~deepseek/deepseek-flash-latest')
case "$next" in
  '~deepseek/deepseek-flash-latest') after='~z-ai/glm-flash-latest' ;;
  *) next='~z-ai/glm-flash-latest'; after='~deepseek/deepseek-flash-latest' ;;
esac
printf '%s\n' "$after" > "$state"
# launch pi with --model "$next"
```

- Never start pi with another provider or model, even when an `hc
  templates` entry or pi's saved default says otherwise. If the user names a
  different pi model, ask before launching it.
- Always pass `--provider openrouter` and the model explicitly. pi can
  silently fall back to another model when a saved default isn't in its
  catalog.
- **Quote the model ID** (`--model "$next"` or `'~z-ai/glm-flash-latest'`).
  An unquoted leading `~` can be expanded by the shell.
- Both are reasoning-by-default aliases (GLM Flash defaults to `max`
  effort). Launch with an explicit thinking level (`--thinking high` for
  implementer work, `low` for quick tasks; confirm the flag with
  `pi --help`) to keep output-token spend down.
- `~` IDs are OpenRouter aliases that move to the newest model in each
  family, so behaviour and price can change without notice.
- When a pi task is retried after a failure, the round robin naturally hands
  it to the other model. That is intended.

### Step 2b: cross-model review (required)

**Every plan and every change must be reviewed by a different model from
the one that produced it.** "Different model" means a different model ID:
another family (Claude vs. Codex vs. pi), or another model in the same
family (Opus vs. Sonnet, Terra vs. Sol, DeepSeek Flash vs. GLM Flash). The
same model at a different reasoning effort does **not** count.

Track the author of every artifact with the `model=` label (Step 4) and in
its report. Then pick the reviewer from this table, taking the first option
that is installed, passes the quota gate, and is not the author's model:

| Artifact produced by | Reviewer, in order of preference |
| --- | --- |
| Plan from Claude Opus | Codex latest Sol → `claude --model sonnet` → pi (round robin) |
| Plan from a fallback planner | Claude Opus → Codex latest Sol → the other pi model |
| Change from Codex Terra | Codex latest Sol → Claude Opus → pi (round robin) |
| Change from a pi model | Codex latest Sol → the other pi model → `claude --model sonnet` |
| Change from a quick task (pi) | the other pi model → Codex latest Sol → `claude --model sonnet` |
| Integration change (merge fixes, conflict resolution) | Codex latest Sol → Claude Opus → pi (round robin); never the integrator's own model |

- Lookups and summaries that change no files and produce no plan don't need
  review.
- Reviewers are read-only: they report findings and do not edit.
- When a review leads to fixes, the fixer is the author of those fixes.
  Review the fixes again with a model other than the fixer's.
- Report every author → reviewer pair in your final report, for example
  `dev-auth: codex gpt-6.1-terra; review-auth: codex gpt-6.2-sol`.
- If no eligible reviewer passes the quota gate, **do not self-review and
  do not treat the work as done.** Stop and ask the user.

## Step 3: gates before every launch (quota and resources)

### Quota (Claude Code, Codex, pi)

Before delegating to `claude`, `codex` or `pi`, check that harness's quota with hc
as described in [references/quota.md](references/quota.md). Check once per
session before the first launch, and again before each new wave of agents.

- Claude Code: open `/usage`; each block reads `NN% used`.
- Codex: open `/status`; each limit line reads `NN% left`.
- pi on OpenRouter: pay-per-token, so check the dollar balance through the
  OpenRouter credits API with `hc exec`.

**If any single quota on a harness (session, 5-hour, weekly, or per-model)
has less than 20% remaining, do not launch that harness.** **For pi on
OpenRouter, do not launch it when less than $10 of credit remains.** Route the role
to its fallback and say which quota was low and when it resets. If every
candidate harness fails the gate, stop and ask the user before launching
anything. If a quota can't be read, treat it as unknown: say so, and ask
before spending on that harness.

Agents already running are not killed by the quota gate; it decides new launches.

### Resources (RAM, disk, /tmp)

Idle agents, leftover worktrees and temp files have exhausted this machine's
RAM, disk and `/tmp` quota before. Before every launch, check:

| Resource | Check | Don't launch if |
| --- | --- | --- |
| Live agents | `hc ls --label sheepdog=$run` | 4 or more of your agents are already live (excluding you) |
| RAM | `awk '/MemAvailable/{print int($2/1048576)}' /proc/meminfo` (GiB) | under 4 GiB available |
| Disk | `df -P <repo> \| awk 'NR==2{print $5}'` | the repo's filesystem is 85% full or more |
| /tmp | `df -P /tmp \| awk 'NR==2{print $5}'` | `/tmp` is 80% full or more |

If a check fails, run the cleanup in Step 6 first: finished and idle agents,
merged worktrees, temp dirs. Then check again. If it still fails, wait for a
running agent to finish, or ask the user. These limits are defaults; use the
user's numbers if they give any.

## Step 4: name and label every agent

Every role agent gets **one name**, used identically in all three places:

1. the **hc terminal name** (`hc run --name <name>`),
2. the **harness session name** (the harness's own rename),
3. the **Herdr pane name**, when the agent is shown in a Herdr pane.

**Format:** `<prefix>-<part>`, using the role prefix from Step 2 and a short
slug for the part or worktree, for example `plan-auth`, `dev-auth`,
`review-auth`, `integ-login`. hc allows 1–32 characters of `a-z 0-9 - _`,
so keep part slugs short and never put model versions (which contain dots) in
names.

**Duplicates:** when a name is already taken, append `-2`, `-3` and so on,
for example `dev-auth`, `dev-auth-2`, `dev-auth-3`. Check against every
terminal hc knows about, finished ones included:

```sh
base=dev-auth; name=$base; n=2
while hc ls --all --json | jq -e --arg n "$name" '.terminals[] | select(.name == $n)' >/dev/null; do
  name="$base-$n"; n=$((n + 1))
done
```

**Labels:** add these to every launch so authorship and cleanup are
mechanical:
`--label sheepdog=$run --label role=<role> --label part=<part> --label model=<exact model id>`.
Model IDs that start with `~` are fine inside a label value, but quote them.

**Setting the harness session name:**

| Harness | How |
| --- | --- |
| `claude` | `claude --name <name> --model …` |
| `pi` | `pi --name <name> --provider openrouter --model …` |
| `codex` | **Not automatable yet.** Codex has no name flag. Its "rename the current thread" command exists, but text sent with `hc send` (`/rename <name>` or bare `/rename`, tested with codex-cli 0.172.0) is submitted as an ordinary prompt and spends a turn. Don't send it. Rely on the hc name, labels and Herdr pane name for Codex agents, and say in your report that their Codex thread names are unset. |

**Herdr pane name:** hidden workers have no pane, so there is nothing to
rename. If the agent is shown in Herdr (because the user asked to see it, or
it was started with `herdr-app do tab.new`), find its pane in
`herdr-app ls` (the entry whose `terminal` matches) and run
`herdr-app do pane.rename --pane <pane-id> --name <name>`. Name a tab you
create with `tab.new --name <name>`. Only create visible tabs when the user
asks; herdr-core's rule.

## Step 5: worktree-per-part workflow

Use this for any feature with parts that can proceed independently. Full
commands are in [references/worktrees.md](references/worktrees.md).

1. **High-level plan (controller).** Split the feature into parts with
   disjoint files and clear interfaces. Write down which parts depend on
   which. Only parts with no unmet dependencies run in parallel.
2. **One worktree per part.** Create an integration branch
   `sheepdog/<feature>` from the base branch. Give each part a branch
   `sheepdog/<feature>-<part>` from it and a worktree in the sibling folder
   `<repo>.worktrees/<feature>-<part>`, outside the repo so it needs no
   `.gitignore` entry. Don't use the harnesses' own worktree flags (`codex --worktree`,
   `claude --worktree`). Sheepdog owns worktrees so it can clean them up.
3. **Plan the part.** Launch `plan-<part>` with `--cwd` set to the
   worktree. It writes a detailed plan for that part only, to
   `<repo>.worktrees/plans/<feature>-<part>.md` (outside git, so plans
   never land in commits). Get it reviewed
   (Step 2b) before any implementation starts.
4. **Build the part.** Launch `dev-<part>` (and `quick-<part>` for small
   chores) in the same worktree, then `review-<part>` on the result. Loop
   fix → re-review until the reviewer passes it.
5. **Integrate.** When a part is reviewed and committed on its branch, hand
   it to the integrator (below).
6. **Clean up the part** as soon as it is merged or abandoned (Step 6).
   Don't wait for the whole feature to finish.

### The integrator

- One `integ-<feature>` agent per feature, started **only when a part is
  ready to merge** and killed when that merge is done. Don't keep it idle
  between parts.
- **Local mode (default):** in the main checkout (or a dedicated
  `integ` worktree), merge part branches into the feature branch one at a
  time, resolve conflicts, and run the full test and lint suite after each
  merge. Conflict fixes are changes: they go through cross-model review.
- **PR mode, only when the user asked for PRs in this session:** push
  `sheepdog/<feature>-<part>` and open a PR against the feature branch (or `main`)
  with `gh pr create`. Watch CI with
  `hc run --bg --rm --no-notify --name ci-<part> -- gh pr checks <n> --watch`,
  and fix failures through the normal dev → review loop. **Never merge a PR
  unless the user asked you to.**
- The integrator reports what it merged, the test results, and any
  conflicts back to the controller with `hc send`.

## Step 6: clean up continuously

Free resources **as soon as each piece of work is accepted**, not at the
end. Full commands and safety checks are in
[references/cleanup.md](references/cleanup.md).

- **Agents:** when an agent's result is accepted, `hc kill <name>; hc rm <name>`.
  Never leave an agent idle waiting for future work; start a new one later
  instead. Before each wave, list `hc ls --all --label sheepdog=$run` and
  kill or remove anything idle, done or finished. Use `--rm` for one-shot
  commands (builds, tests, CI watches).
- **Temp files:** start every agent with its own `TMPDIR` on the disk, not
  in `/tmp` (which is a quota-limited tmpfs):
  `env TMPDIR="${XDG_CACHE_HOME:-$HOME/.cache}/sheepdog/tmp/<name>" <harness> …`
  (create the folder first). Delete that folder when the agent is removed.
- **Worktrees:** when a part is merged (or abandoned with the user's OK),
  remove its worktree with `git worktree remove`, delete its branch with
  `git branch -d`, and run `git worktree prune`. Build outputs in the
  worktree (`target/`, `node_modules/`, `.venv/`, `dist/`) go with it.
- **Background servers:** kill any dev servers or watchers a part started,
  and check that their ports are free. Detached processes can survive
  `hc kill`.
- **End of feature:** run the full sweep in references/cleanup.md, then
  report what you freed (agents, worktrees, branches, disk) and anything
  you left in place on purpose.
- **Only clean up what this run created**: terminals labelled
  `sheepdog=$run`, worktrees under `<repo>.worktrees/` on `sheepdog/*`
  branches, and `TMPDIR` folders under `sheepdog/tmp/`. Never touch the
  user's other terminals, worktrees, branches or caches.

## Launch example

A Codex Terra implementer in the `auth` worktree, then its Sol reviewer:

```sh
wt=../myrepo.worktrees/login-auth; plan=../myrepo.worktrees/plans/login-auth.md
tmp="${XDG_CACHE_HOME:-$HOME/.cache}/sheepdog/tmp/dev-auth"; mkdir -p "$tmp"
hc run --bg --name dev-auth --cwd "$wt" \
  --label sheepdog=$run --label role=dev --label part=auth --label model=gpt-6.1-terra \
  env TMPDIR="$tmp" codex --model gpt-6.1-terra \
  "Implement the plan at $plan. No subagents. Commit on this branch. Report with hc send $HC_TERMINAL_ID when done or stuck."

tmp="${XDG_CACHE_HOME:-$HOME/.cache}/sheepdog/tmp/review-auth"; mkdir -p "$tmp"
hc run --bg --name review-auth --cwd "$wt" \
  --label sheepdog=$run --label role=review --label part=auth --label model=gpt-6.2-sol \
  env TMPDIR="$tmp" codex --model gpt-6.2-sol \
  "Review the commits on this branch made by gpt-6.1-terra against $plan. Read-only; no subagents. Report with hc send $HC_TERMINAL_ID when done or stuck."
```

Claude and pi also take their session name at launch:
`hc run --bg --name plan-auth … env TMPDIR="$tmp" claude --name plan-auth --model opus "<task>"`.

Launching through `env` is safe: hc still recognises the harness (tested:
`hc get` reports `app: codex`, state `idle`).

## Rules

- If a role's primary harness and all of its fallbacks are unavailable
  (not installed or failed the quota gate), stop and ask the user.
  Never skip the cross-model review to save quota.
- If the user names a harness or model for a task, use theirs, except that
  pi stays on its two allowlisted models unless the user confirms the
  exception. The cross-model review rule still applies.
- Don't let children start more agents unless you assign that explicitly
  (herdr-core rule; repeated here because it matters for cost and RAM).
- Don't push, open PRs, or merge unless the user asked for that in this
  session.
