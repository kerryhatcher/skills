# Worktree-per-part workflow: commands

Run these as the controller. Paths are examples; derive them from the repo
you're in.

## Layout

```sh
repo=$(git rev-parse --show-toplevel)
root="$(dirname "$repo")/$(basename "$repo").worktrees"   # outside the repo: no .gitignore needed
feature=login                                             # short slug, a-z 0-9 -
mkdir -p "$root/plans"
```

| Thing | Name / path |
| --- | --- |
| Integration branch | `sheepdog/<feature>` (created from the base branch the user chose, else current `HEAD`) |
| Part branch | `sheepdog/<feature>-<part>` (a sibling name, not `sheepdog/<feature>/<part>`: git can't have both `a` and `a/b` as branches) |
| Part worktree | `$root/<feature>-<part>` |
| Part plan | `$root/plans/<feature>-<part>.md` (outside git, so plans never land in commits) |
| Agent names | `plan-<part>`, `dev-<part>`, `review-<part>`, `quick-<part>`, `integ-<feature>`, plus `-2`, `-3` for duplicates |

## Start a feature

```sh
base=$(git -C "$repo" branch --show-current)    # or the base the user named
git -C "$repo" branch "sheepdog/$feature" "$base"
date +%s > "${XDG_STATE_HOME:-$HOME/.local/state}/sheepdog/$run.start"   # for the /tmp sweep later
```

Write the high-level plan: list each part, the files and interfaces it owns,
and what it depends on. Get it cross-model reviewed (SKILL.md Step 2b)
before creating worktrees.

## Start a part

Only start a part when every part it depends on is merged into
`sheepdog/<feature>`, because its worktree branches from there.

```sh
part=api
git -C "$repo" worktree add -b "sheepdog/$feature-$part" "$root/$feature-$part" "sheepdog/$feature"
```

Then, in that worktree (`--cwd "$root/$feature-$part"`), in order:

1. `plan-<part>`: "Write a detailed plan for <part> to `$root/plans/<feature>-<part>.md`. Stay within <files>. Don't edit code."
2. A reviewer for the plan, using a different model (Step 2b). Loop until it passes.
3. `dev-<part>` (and `quick-<part>` for chores): "Implement the plan at <path>. Commit on this branch. Don't touch files outside <scope>."
4. `review-<part>`: "Review the commits on this branch against <plan path>. Read-only."
5. Repeat fix → review until it passes. Then hand the part to the integrator.

Kill each agent as soon as its step is accepted (cleanup.md). Plans and
branch history carry the context forward, so don't keep agents alive for it.

## Integrate a part

Start `integ-<feature>` only when there is something to merge:

**Local mode (default):**

```sh
# in the main checkout, or a dedicated worktree: git -C "$repo" worktree add "$root/$feature-integ" "sheepdog/$feature"
git switch "sheepdog/$feature"
git merge --no-ff "sheepdog/$feature-$part"
# run the project's full test + lint suite; resolve conflicts; commit
```

Conflict resolutions and test fixes made by the integrator are changes:
review them with a model other than the integrator's.

**PR mode (only if the user asked for PRs this session):**

```sh
git -C "$root/$feature-$part" push -u origin "sheepdog/$feature-$part"
gh pr create --base "sheepdog/$feature" --head "sheepdog/$feature-$part" --title "<feature>: <part>" --body "<plan summary, review pairs>"
hc run --bg --rm --no-notify --name "ci-$part" -- gh pr checks <number> --watch
```

Never merge a PR unless the user asked for merges. When the whole feature is
integrated, the final step (a local merge into the base branch, or a PR from
`sheepdog/<feature>` to it) is the user's call.

## Disk-heavy projects

Each worktree has its own build outputs. Rust `target/` and `node_modules/`
can run to several GB per worktree.

- Keep few parts alive at once. Remove each part's worktree as soon as it is
  merged.
- Prefer package managers with a shared content-addressed store (pnpm) over
  per-worktree copies where the project already supports it. Don't switch a
  project's tooling just for this.
- Don't share one `CARGO_TARGET_DIR` across parallel worktrees. Concurrent
  builds then block on its lock. Separate targets that are deleted promptly
  work better.
