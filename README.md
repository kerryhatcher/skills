# Agent Skills

Universal AI agent skills, installable with [skills.sh](https://www.skills.sh) into Claude Code, Cursor, Codex, Copilot, Gemini CLI, and [many other agents](https://github.com/vercel-labs/skills).

## Install

```sh
# list the skills in this repo
npx skills add kerryhatcher/skills --list

# install one
npx skills add kerryhatcher/skills --skill sops-age

# target a specific agent
npx skills add kerryhatcher/skills --skill sops-age -a claude-code

# update installed skills later (-g for user-level installs)
npx skills update -g
```

### sheepdog needs herdr-core

skills.sh has no way to declare dependencies between skills, so install
[herdr-core](https://github.com/herdrdev/herdr-core) alongside sheepdog:

```sh
npx skills add herdrdev/herdr-core -g
npx skills add kerryhatcher/skills --skill sheepdog -g
```

sheepdog also needs the `hc` CLI from Herdr, plus whichever of `claude`, `codex`
and `pi` you want it to delegate to.

## Skills

| Skill | Description |
| --- | --- |
| [sops-age](skills/sops-age/SKILL.md) | Encrypt and use secrets with SOPS and age, including a convention for finding `~/secrets/secrets.env` |
| [sheepdog](skills/sheepdog/SKILL.md) | Multi-agent policy layered on herdr-core (`hc`): which harness and model runs each role, cross-model review, worktree-per-part workflow, and resource cleanup. **Requires herdr-core** (see above) |

## Adding a skill

1. `cp -r template skills/<name>` and edit `SKILL.md`.
2. Keep `name` equal to the directory name; start `description` with "Use when...".
3. Run `scripts/validate.sh`. It checks frontmatter, rejects hardcoded home paths, and fails on literal `$<digit>` placeholders in `SKILL.md` (slash-command arguments are substituted into it; put shell snippets in `skills/<name>/scripts/` instead).

## Secret scanning

Every commit and push is scanned with [TruffleHog](https://github.com/trufflesecurity/trufflehog) and [Trivy](https://github.com/aquasecurity/trivy):

- **Locally:** a pre-commit hook in `.githooks/` runs `scripts/validate.sh`, then scans the staged files. Install `trufflehog` and `trivy`, then enable it once per clone:

  ```sh
  git config core.hooksPath .githooks
  ```

- **CI:** `.github/workflows/security.yml` runs both on push, pull request, and weekly.

This repo is public: no usernames, absolute home paths, or secrets.

## License

MIT
