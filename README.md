# Agent Skills

Universal AI agent skills, installable with [skills.sh](https://www.skills.sh) into Claude Code, Cursor, Codex, Copilot, Gemini CLI, and [many other agents](https://github.com/vercel-labs/skills).

## Install

```sh
# list the skills in this repo
npx skills add <owner>/skills --list

# install one
npx skills add <owner>/skills --skill sops-age

# target a specific agent
npx skills add <owner>/skills --skill sops-age -a claude-code
```

Replace `<owner>` with the GitHub account hosting this repo.

## Skills

| Skill | Description |
| --- | --- |
| [sops-age](skills/sops-age/SKILL.md) | Encrypt and use secrets with SOPS and age, including a convention for finding `~/secrets/secrets.env` |

## Adding a skill

1. `cp -r template skills/<name>` and edit `SKILL.md`.
2. Keep `name` equal to the directory name; start `description` with "Use when...".
3. Run `scripts/validate.sh`.

This repo is public: no usernames, absolute home paths, or secrets.

## License

MIT
