# Cleanup: commands and safety checks

Idle agents have run this machine out of RAM, and leftover worktrees and temp
files have filled its disk and `/tmp` quota. Clean up **as each piece of
work is accepted**, and sweep before every new wave and at the end.

**Scope rule:** only remove what this run created:

- terminals labelled `sheepdog=$run`,
- worktrees under `$root` (see worktrees.md) on `sheepdog/*` branches,
- `TMPDIR` folders under `${XDG_CACHE_HOME:-$HOME/.cache}/sheepdog/tmp/`.

`hc ls` also shows the user's other work. Never kill, remove or delete
anything outside that scope, and never run `hc server stop` or restart.

## One agent, once its result is accepted

```sh
hc kill "$name"; hc rm "$name"
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/sheepdog/tmp/$name"
```

If it started servers or watchers, check they're gone. Detached processes
can survive `hc kill`:

```sh
ss -ltnp | grep -E ':(3000|5173|8080)\b'   # the ports that part used
```

Stop only processes you can tie to this run: the agent's cwd is in its
worktree, or it is listening on a port the part's plan named.

## Sweep before each wave

```sh
hc ls --all --json --label "sheepdog=$run" | jq -r '.terminals[] | "\(.name // .address)\t\(.state)"'
```

- `finished`: `hc rm` it, and delete its `TMPDIR`.
- Live but idle or done, with its result already collected: kill and remove it.
- Live and idle **without** a collected result: `hc read` it, collect what
  it produced, then kill and remove it. Don't leave it waiting.
- `working` or `blocked`: leave it; handle `blocked` the way herdr-core says.

Then re-check the resource gates (SKILL.md Step 3).

## A part is merged (or abandoned with the user's OK)

```sh
wt="$root/$feature-$part"; br="sheepdog/$feature-$part"
git -C "$repo" merge-base --is-ancestor "$br" "sheepdog/$feature" && echo merged
git -C "$repo" worktree remove "$wt"      # no --force: it refuses if there are uncommitted changes
git -C "$repo" branch -d "$br"            # -d, not -D: refuses if unmerged
git -C "$repo" worktree prune
rm -f "$root/plans/$feature-$part.md"
```

- If `worktree remove` refuses, don't force it. Look at what's uncommitted,
  and either have it committed and integrated, or ask the user before
  discarding it.
- For an abandoned part, `-D` and `--force` need the user's explicit OK.
- Remote branches (PR mode): delete with `git push origin --delete "$br"`
  only after the PR is merged or closed, and only if the user asked for PR
  mode.

## End of the feature

1. Sweep every terminal labelled `sheepdog=$run`: kill and remove all of them.
2. Remove every remaining part worktree as above, then
   `git -C "$repo" worktree list` to confirm only the user's own worktrees remain.
3. Delete the integration branch only if it was merged into the base and the
   user agrees. Otherwise leave it and say so.
4. Remove empty folders: `rmdir "$root/plans" "$root" 2>/dev/null`.
5. Delete this run's temp root:
   `rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/sheepdog/tmp"`, but only the
   folders of this run's agents if another sheepdog run is live (check
   `hc ls --json` for other `sheepdog=` labels).
6. Look for `/tmp` files left by agents that ran without a private
   `TMPDIR`:

   ```sh
   start="${XDG_STATE_HOME:-$HOME/.local/state}/sheepdog/$run.start"
   find /tmp -maxdepth 1 -user "$(id -u)" -newermt "@$(cat "$start")" -printf '%TY-%Tm-%Td %TH:%TM %s\t%p\n' 2>/dev/null
   ```

   Delete entries that clearly belong to this run's agents and builds (for
   example `cargo-install*`, `tmp.*` created by a build you ran, or harness
   scratch folders). Ask the user about anything you can't attribute. Then
   `rm -f "$start"`.
7. Report what you freed: agents removed, worktrees and branches deleted,
   disk reclaimed (`df -h <repo> /tmp` before and after), and anything you
   deliberately left in place.

## Not yours to delete

- Harness session histories and caches (`~/.codex/sessions`, Claude Code
  and pi transcripts, `~/.codex/worktrees` made by Codex itself). These are
  the user's history. Mention them if they look large, but don't delete them.
- Package-manager caches (`~/.cargo/registry`, `~/.npm`, pnpm store).
  They're shared across projects.
- Other terminals, worktrees and branches that aren't in this run's scope.
