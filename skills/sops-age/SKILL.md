---
name: sops-age
description: Use when working with SOPS (Mozilla/getsops) encryption using age keys, when a task needs secrets or API keys or env vars, or when a `secrets.env` file exists in a `secrets` folder in the user's home directory. Covers encrypting, editing, decrypting, and injecting secrets into commands without leaking them.
---

# SOPS + age

SOPS encrypts the *values* of structured files (dotenv, YAML, JSON, INI) and leaves keys readable, so files diff cleanly and are safe to keep in version control. age supplies the keys: small, no config, no keyservers.

## The user's secrets file convention

Many users keep sensitive environment variables in one SOPS-encrypted dotenv file:

```
$HOME/secrets/secrets.env
```

When a task needs a credential, API token, or other secret environment variable:

1. **Look for it.** Check whether `"$HOME/secrets/secrets.env"` exists. Resolve `$HOME` at runtime. Never hardcode a username or absolute home path into commands, scripts, or committed files.
2. **Confirm it is SOPS-encrypted.** An encrypted dotenv file contains `sops_*` metadata lines (for example `sops_age__list_0__map_recipient=...`) and values that start with `ENC[AES256_GCM,`. If values are plaintext, tell the user rather than silently using or "fixing" it.
3. **Use it without exposing values.** Prefer injecting into a child process:

   ```sh
   sops exec-env "$HOME/secrets/secrets.env" 'your-command --flag'
   ```

   Only the child process sees the variables. They are not written to disk or to your output.
4. **List key names, not values**, when you need to know what is available:

   ```sh
   sops decrypt --input-type dotenv --output-type dotenv "$HOME/secrets/secrets.env" | cut -d= -f1 | grep -v '^sops_'
   ```

If the file is missing, `sops` is not installed, or decryption fails, stop and report it. Do not hunt for secrets elsewhere (shell history, other dotfiles, other users' directories).

## Safety rules (always)

- **Never print, log, echo, or paste decrypted values** into chat, commit messages, PR text, issue comments, or tool output. Do not run bare `sops decrypt` on the secrets file where its output will be captured. Filter to key names as above.
- **Never write plaintext secrets to disk** (no `sops decrypt > file`, no `.env` copies). If a tool needs a file, use `sops exec-file` (a FIFO, no plaintext on disk).
- **Never read or print the age private key** (the `keys.txt` file or `SOPS_AGE_KEY`). The public recipient (`age1...`) is safe to show; the secret identity (`AGE-SECRET-KEY-1...`) is not.
- **Never commit** private keys or decrypted files. Encrypted files are fine to commit.
- **Do not modify the user's secrets file** (`sops set`, `sops edit`, `sops rotate`) unless asked. Say which key you will add or change, never the value. When the user gives a value for a new secret, pass it via stdin or `--value-file`, not on the command line, where it lands in shell history and process listings.

## Key setup

Generate an identity (once per person or machine):

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

`age-keygen` prints the public key (`age1...`). Back up `keys.txt` somewhere safe (password manager, offline). Losing it means losing the data.

SOPS finds the private key in this order of configuration:

| Source | Meaning |
| --- | --- |
| `SOPS_AGE_KEY_FILE` | Path to a key file |
| `SOPS_AGE_KEY` | Key material in the variable |
| `SOPS_AGE_KEY_CMD` | Command that prints the key |
| Default file | Linux: `$XDG_CONFIG_HOME/sops/age/keys.txt`, else `~/.config/sops/age/keys.txt`. macOS: `~/Library/Application Support/sops/age/keys.txt`. Windows: `%AppData%\sops\age\keys.txt` |

SSH keys also work: `ssh-ed25519` and `ssh-rsa` public keys are valid recipients, and `~/.ssh/id_ed25519` or `~/.ssh/id_rsa` are tried for decryption (unencrypted private keys only).

## Configure with `.sops.yaml`

Put a `.sops.yaml` (exact name) where you run `sops`; lookup starts from the **current working directory**. First matching rule wins.

```yaml
creation_rules:
  - path_regex: secrets\.env$
    age: >-
      age1exampleexampleexampleexampleexampleexampleexampleexample00,
      age1anotherrecipientpublickeygoeshere000000000000000000000000
```

List every person or machine that must be able to decrypt. `--age` or `SOPS_AGE_RECIPIENTS` on the command line overrides the config.

## Common operations

```sh
# Create an encrypted dotenv file (stdin needs explicit types)
printf 'API_TOKEN=changeme\n' | sops encrypt --age age1... \
  --input-type dotenv --output-type dotenv --filename-override secrets.env > secrets.env.enc && mv secrets.env.enc secrets.env

# Edit in $SOPS_EDITOR / $EDITOR; re-encrypts on save
sops edit "$HOME/secrets/secrets.env"

# Run a command with the variables in its environment
sops exec-env "$HOME/secrets/secrets.env" './deploy.sh'

# Hand a tool a file path without writing plaintext to disk
sops exec-file "$HOME/secrets/secrets.env" 'some-tool --env-file {}'

# Add a recipient: edit .sops.yaml, then
sops updatekeys secrets.env
# Rotate the data key (after removing a recipient or a suspected leak)
sops rotate -i secrets.env
```

If a key may have leaked: remove it from `.sops.yaml`, run `sops updatekeys`, run `sops rotate -i`, **and rotate the underlying secrets themselves** at their source. Re-encrypting does not undo past exposure.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `no matching creation rules found` | No `.sops.yaml` found from the cwd, or no rule matches the path |
| `Failed to get the data key required to decrypt` / `no identity matched` | Private key missing, wrong `SOPS_AGE_KEY_FILE`, or your public key was never a recipient |
| `MAC mismatch` | File was edited by hand outside SOPS; restore it from version control |
| Decrypts to wrong format | Pass `--input-type dotenv --output-type dotenv` explicitly |
| Editor closes instantly | `$EDITOR` does not block; use `code --wait` or similar |

See [references/commands.md](references/commands.md) for more command syntax.
