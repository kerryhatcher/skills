# Checking Claude Code, Codex and pi (OpenRouter) quota with hc

Neither `hc` nor the harnesses expose a quota command you can pipe. The
reliable method is to open the harness's own usage screen in a throwaway hc
terminal and read it. Verified against Claude Code 2.1.x and codex-cli 0.17x;
screen wording may change, so read the screen rather than trusting exact
patterns.

## Rule: type slash commands with `hc keys`, not `hc send`

`hc send` wraps text in an `<hc from=...>` tag, so `/usage` arrives as a
normal prompt (it spends a model turn and the command never runs). Type it
one key at a time instead:

```sh
hc keys <t> / u s a g e
hc keys <t> enter
```

## Claude Code: `/usage`

```sh
hc run --bg --name quota-claude --cwd "$HOME" claude
hc wait quota-claude --timeout 30
hc keys quota-claude / u s a g e
hc keys quota-claude enter
hc wait quota-claude --output 'used' --timeout 20
hc read quota-claude --lines 0
hc kill quota-claude; hc rm quota-claude
```

The Usage tab shows one block per quota, each reporting percent **used**:

```text
Current session
███████▌                       15% used
Resets 2:49pm (America/New_York)
Current week (all models)
███████████████████████        54% used
Resets Nov 26, 3:59am (America/New_York)
```

Some plans also show a per-model weekly block (for example a separate Opus or
Sonnet week). Treat every `NN% used` block as its own quota.
Remaining = `100 - used`.

Opening `/usage` does not spend a model turn.

## Codex: `/status`

```sh
hc run --bg --name quota-codex --cwd "$HOME" codex
hc wait quota-codex --timeout 30
hc keys quota-codex / s t a t u s
hc keys quota-codex enter
hc wait quota-codex --output 'left' --timeout 20
hc read quota-codex --lines 0
hc kill quota-codex; hc rm quota-codex
```

The status card reports percent **left** (a Pro plan showed only the weekly
line; other plans may add a 5-hour line in the same format):

```text
Weekly limit:        [██░░░░░░░░░░░░░░░░░░] 10% left (resets 9:32 PM on 26 Nov)
```

Which lines appear depends on the plan; treat every `limit: ... NN% left`
line as its own quota. Codex also prints a banner such as
`you have less than 10% of your weekly limit left` on startup when it is low.

### Codex offline fallback (no terminal needed)

Each Codex session log records the last rate-limit snapshot the server sent:

```sh
f=$(ls -t "$HOME"/.codex/sessions/*/*/*/*.jsonl | head -1)
grep -o '"rate_limits":{[^}]*}[^}]*}' "$f" | tail -1
```

```json
"rate_limits":{"limit_id":"codex","primary":{"used_percent":90.0,"window_minutes":10080,"resets_at":1795746759},"secondary":null, ...}
```

`used_percent` is percent used; `window_minutes` 300 is the 5-hour window,
10080 the weekly one; `resets_at` is a Unix time. This is only as fresh as the
most recent Codex turn on this machine, so prefer `/status` and use the log
only when it is recent (check the file's mtime) or `/status` fails.

## pi on OpenRouter: dollars, not percent

pi on OpenRouter is pay-per-token, so there is no percentage quota; the limit
is credit balance in US dollars. There is no screen to read: ask the
OpenRouter API directly, using the credential pi already holds. Run it
through `hc exec` (add `--on <machine>` for another machine):

```sh
hc exec -- sh -c '
  tok=$(pi auth print-bearer-token --provider openrouter 2>/dev/null \
        || pi auth print-api-key --provider openrouter) || exit 1
  c=$(curl -fsS -H "Authorization: Bearer $tok" https://openrouter.ai/api/v1/credits) || exit 1
  k=$(curl -fsS -H "Authorization: Bearer $tok" https://openrouter.ai/api/v1/key) || exit 1
  printf "%s\n%s\n" "$c" "$k" | jq -s "{
    account_remaining: (.[0].data.total_credits - .[0].data.total_usage),
    key_limit_remaining: .[1].data.limit_remaining }"'
```

```json
{ "account_remaining": 29.82, "key_limit_remaining": null }
```

- `account_remaining` = credits bought minus credits used, account-wide.
- `key_limit_remaining` is non-null only when the key has its own spend cap.
  Effective balance = the smaller of the two non-null values.
- `pi auth print-bearer-token` is for OAuth logins (`pi auth check --provider
  openrouter --json` shows `authType`); `print-api-key` covers API-key logins
  and `OPENROUTER_API_KEY`.
- The token stays inside the `sh -c`; never echo it, and don't print the full
  `/key` response into reports (it contains account and workspace IDs).
- These calls are free and don't spend credits.
- Sheepdog only launches pi on OpenRouter (see the pi model allowlist in
  SKILL.md), so this dollar check is the only pi gate. If the user has
  confirmed an exception and pi runs on another `--provider` (for example
  `openai-codex`), apply that provider's quota rule instead.

## Gotchas

- **Trust dialogs.** Launching a harness in a folder it hasn't seen shows a
  trust prompt and the slash command goes nowhere. Launch quota checks with
  `--cwd "$HOME"` (or another already-trusted folder), and `hc read` before
  typing if the screen looks wrong. Don't accept trust for a project just to
  check quota.
- **Read, don't assume.** If the screen doesn't show a percentage (login
  expired, different plan, layout changed), report the quota as unknown.
- **Clean up.** Always `hc kill` and `hc rm` the check terminal.
- **Per machine/account.** Quota belongs to the account logged in on that
  machine. For `--on <machine>` work, check on that machine.
- **Never copy account details** (email, workspace IDs) from these screens into
  reports, commits or files.
