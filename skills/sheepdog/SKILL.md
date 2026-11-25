---
name: sheepdog
description: Use when you want sub-agents, to delegate or coordinate work across other agents, or to run background tasks, servers or long-running commands through herdr-core (hc). Load this instead of herdr-core directly; it adds which harnesses and models to use for each role, and tells you to load herdr-core as well.
---

# Sheepdog

Sheepdog is a policy layer on top of the **herdr-core** skill. herdr-core
explains *how* to run and coordinate agents with `hc`; sheepdog decides
*which* harness and model to use for each kind of work.

Sheepdog does not repeat herdr-core. Everything about `hc` (launching,
`--bg`, naming, `hc wait`, `hc send`, reports, cleanup) comes from herdr-core.

## Step 1: load herdr-core first

Before doing anything else, load the `herdr-core` skill and follow it,
including running `hc --skill` as it instructs. If the herdr-core skill is
not installed, stop and tell the user; do not guess at `hc` usage.

Where herdr-core and sheepdog conflict, sheepdog wins only on **harness and
model choice**. On everything else, follow herdr-core.

## Step 2: pick a role, then its harness and model

Classify each delegated task into one role below and launch it with that
role's harness and model. If an `hc templates` entry exists for the role,
prefer the template (it already pins the command and model).

<!-- TODO: fill in harness and model per role. -->

| Role | Use for | Harness | Model |
| --- | --- | --- | --- |
| planner | Breaking down work, design, specs | `TODO` | `TODO` |
| implementer | Writing and editing code | `TODO` | `TODO` |
| reviewer | Read-only review, second opinions | `TODO` | `TODO` |
| quick | Small lookups, trivial edits, summaries | `TODO` | `TODO` |

Known harnesses and how to set a model at launch (confirm flags with
`<harness> --help`; they change between versions):

| Harness | Launch shape |
| --- | --- |
| `claude` | `claude --model <model> "<task>"` |
| `codex` | `codex --model <model> "<task>"` |
| `pi` | `pi --provider openrouter --model '<model>'` (allowlisted models only, see below) |
| `opencode` | `opencode --model <provider/model>` |

### pi model allowlist

pi may only be launched on **OpenRouter** with one of these two models.
Never start pi with another provider or model, including when a role's table
entry, an `hc templates` entry, or pi's own default says otherwise.

| Model | Prefer for |
| --- | --- |
| `~deepseek/deepseek-flash-latest` | Coding: implementer work, multi-step edits, test-fix loops |
| `~z-ai/glm-flash-latest` | Everything else on pi: planning, review, quick tasks; also the fallback when DeepSeek fails twice on a task |

- Always pass `--provider openrouter` and the model explicitly; don't rely on
  pi's saved default. pi can silently fall back to another model when a saved
  default isn't in its catalog.
- **Quote the model ID** (`--model '~z-ai/glm-flash-latest'`). An unquoted
  leading `~` can be expanded by the shell.
- Both are reasoning-by-default aliases (GLM Flash defaults to `max` effort).
  Launch with an explicit thinking level (`--thinking high`, or `low` for
  quick tasks; confirm the flag with `pi --help`) to keep output-token spend down.
- `~` IDs are OpenRouter aliases that move to the newest model in the family,
  so behaviour and price can change without notice.
- If the user names a different model for pi, ask before launching it; this
  allowlist is a cost and quality decision, not a default.

## Step 3: quota gate (Claude Code, Codex, pi)

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
to the other harness (or another installed one) and say which quota was low
and when it resets. If every candidate harness fails the gate, stop and ask the user before
launching anything. If a quota can't be read, treat it as unknown: say so,
and ask before spending on that harness.

Agents already running are not killed by the gate; it decides new launches.

## Step 4: launch through hc

Launch exactly as herdr-core describes, substituting the role's harness and
model. For example, a reviewer:

```sh
hc run --bg --name review --cwd "$PWD" <harness> --model <model> \
  "Review only src/x.rs. Read-only; no subagents. Report with hc send $HC_TERMINAL_ID when done or stuck."
```

## Rules

- If a role's harness or model is still `TODO`, that harness is not
  installed, or it failed the quota gate, fall back to the harness you are
  running in (if it passed the gate) with its default model, and say so once
  in your report.
- If the user names a harness or model for a task, use theirs, except that
  pi stays on its allowlist (above) unless the user confirms the exception.
- Don't let children start more agents unless you assign that explicitly
  (herdr-core rule; repeated here because it matters for cost).
