# Agent notes

Public repo of agent skills installable via skills.sh (`npx skills add`).

- One skill per directory: `skills/<name>/SKILL.md`. Frontmatter needs `name` (lowercase-hyphenated, equal to the directory name) and `description` (start with "Use when...").
- Copy `template/SKILL.md` to start a new skill. Put long reference material in `skills/<name>/references/`.
- **Public repo: never include usernames, absolute home paths, hostnames, keys, tokens, or real secrets.** Use `$HOME` and placeholders.
- Run `scripts/validate.sh` before committing.
