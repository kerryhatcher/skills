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
```

## Skills

| Skill | Description |
| --- | --- |
| [sops-age](skills/sops-age/SKILL.md) | Encrypt and use secrets with SOPS and age, including a convention for finding `~/secrets/secrets.env` |
| [sheepdog](skills/sheepdog/SKILL.md) | Harness and model policy layered on herdr-core (`hc`); loads herdr-core and picks which agent and model runs each role |

## Adding a skill

1. `cp -r template skills/<name>` and edit `SKILL.md`.
2. Keep `name` equal to the directory name; start `description` with "Use when...".
3. Run `scripts/validate.sh`.

This repo is public: no usernames, absolute home paths, or secrets.

## License

MIT
