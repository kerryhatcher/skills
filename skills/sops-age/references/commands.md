# SOPS command reference (age)

Verified against https://getsops.io/docs/ usage pages.

## Encrypt
- `sops encrypt --age <r1>,<r2> file.yaml > file.enc.yaml`
- In place: `sops encrypt -i file`
- From stdin: `... | sops encrypt --filename-override path/name.sops.yaml --input-type dotenv > out`
- Recipients may also come from `SOPS_AGE_RECIPIENTS`.

## Decrypt
- `sops decrypt file` (older form: `sops -d file`)
- In place: `sops decrypt -i file`
- Stdin: `cat x.enc.env | sops decrypt --input-type dotenv --output-type dotenv`
- One value: `sops decrypt --extract '["key"]' file.yaml`

## Modify
- `sops edit file`
- `sops set file '["key"]' '"json-value"'` (value must be JSON; also `--value-file`, `--value-stdin`)
- `sops unset file '["key"]'`

## Run with secrets
- `sops exec-env file 'cmd'` puts decrypted values in the child environment.
- `sops exec-file file 'cmd {}'` substitutes a FIFO path for `{}`. Add `--no-fifo` for a regular temp file, `--filename name` to set the name.
- Both accept `--user <name>` to drop privileges.

## Keys
- `sops updatekeys file` syncs recipients with `.sops.yaml` (`-y` skips the prompt).
- `sops rotate -i file` generates a new data key.
- `SOPS_DECRYPTION_ORDER` sets method order (default `age,pgp`).
- SSH decryption fallbacks: `SOPS_AGE_SSH_PRIVATE_KEY_FILE`, `SOPS_AGE_SSH_PRIVATE_KEY_CMD`, `~/.ssh/id_ed25519`, `~/.ssh/id_rsa`.
