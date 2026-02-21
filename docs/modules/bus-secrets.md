---
title: bus-secrets
description: "How to store and resolve repository-local secret references for BusDK workflows, and how to use them from bus dev and bus run."
---

## `bus-secrets` - manage secret references for BusDK workflows

### Synopsis

`bus secrets [global flags] set <name> <value> [--scope auto|repo|user]`  
`bus secrets [global flags] get <name> [--scope auto|repo|user]`  
`bus secrets [global flags] list [--scope auto|repo|user]`  
`bus secrets [global flags] resolve <value> [--scope auto|repo|user]`  
`bus secrets [global flags] init [--print-env sh|powershell] [--secure-enclave]`  
`bus secrets [global flags] uninit`  
`bus secrets [global flags] doctor`

### Description

`bus-secrets` stores and resolves secret values by name. Secrets are persisted in repository-local files under `.bus/secrets`, and secret references use the form `secret:<name>`.

### Commands

`bus secrets set <name> <value> [--scope auto|repo|user]` writes a secret value as a SOPS-encrypted envelope.

`bus secrets get <name> [--scope auto|repo|user]` reads one secret value and prints the decrypted value to stdout.

`bus secrets list [--scope auto|repo|user]` prints known secret names in sorted order.

`bus secrets resolve <value> [--scope auto|repo|user]` resolves plain values and `secret:<name>` references. Plain values are returned unchanged.

`bus secrets init [--print-env sh|powershell] [--secure-enclave]` initializes SOPS age configuration for `bus secrets` and creates a no-space key path by default. By default it prints only a completion message; use `--print-env` only when you want optional session override exports.

`bus secrets uninit` reverts init state by clearing repository recipients and local key-source preferences.

`bus secrets doctor` validates SOPS/key setup with an encrypt/decrypt self-test.

Recipient precedence for encryption is:

1. `.bus/secrets/recipients.txt` written by `bus secrets init`
2. `SOPS_AGE_RECIPIENTS` environment variable (fallback)

Key source precedence for decrypt/encrypt is:

1. Repository profile from `.bus/secrets/config.json` selects user preferences `bus-secrets.profiles.<profile>.age_key_file` and optional `.age_key_cmd`
2. Legacy user preferences `bus-secrets.age_key_file` / `bus-secrets.age_key_cmd`
3. `SOPS_AGE_KEY_FILE` / `SOPS_AGE_KEY_CMD` / `SOPS_AGE_KEY` environment variables (fallback)

### Secret name format

Secret names must be lowercase and may contain lowercase letters, digits, `.`, `-`, and `_`.

### Storage and precedence

Secret blobs are stored at `.bus/secrets/<name>.sops.json` and public recipients are stored at `.bus/secrets/recipients.txt`.
Repository key profile is stored at `.bus/secrets/config.json`.

Private keys are not stored in the repository by `bus-secrets`. Key source configuration is local through preferences or environment variables, and can use hardware-backed providers.

### Typical workflow

Set a secret value, then use a reference in step-level env configuration:

```bash
bus secrets set openai_api_key 'sk-...'
bus dev set env-for @work OPENAI_API_KEY secret:openai_api_key
bus run set env-for summarize OPENAI_API_KEY secret:openai_api_key
```

Check what is stored and how resolution works:

```bash
bus secrets list
bus secrets get openai_api_key
bus secrets resolve secret:openai_api_key
```

### Security guidance

The module enforces encrypted-at-rest behavior. Plaintext secret values in storage are treated as invalid and commands fail until values are re-written through `bus secrets set`.

### Global flags

Standard global flags are supported: `-h`, `-V`, `-C`, `-o`, and `-q`.

`sops` must be available in `PATH`, and SOPS key configuration must be available for encrypt/decrypt operations.

If `sops` is not installed, `bus secrets` fails with an explicit diagnostic that tells you to install `sops` and retry. Install instructions: <https://getsops.io/>.

### SOPS setup

`bus secrets` requires `sops` plus a configured key backend. For most teams, `age` is the simplest backend.

### Setup guide

```bash
brew install sops age-plugin-se
bus secrets init
```

On macOS, if you want Secure Enclave-backed keys, run:

```bash
bus secrets init --secure-enclave
```

`bus secrets init` already writes persistent local key-source preferences and repository recipients.

### Verify setup

```bash
sops --version
bus secrets init
bus secrets set smoke.test value
bus secrets get smoke.test
bus secrets doctor
```

SOPS supports additional key-source variables such as `SOPS_AGE_KEY`, `SOPS_AGE_KEY_CMD`, and `SOPS_AGE_KEY_FILE` for password manager or external key-command integrations.

Keep at least one recovery-capable backup recipient in your SOPS policy so secrets remain decryptable if a device-bound key becomes unavailable.

### Use with bus dev and bus run envs

`bus secrets` is most useful when you reference secrets from per-step environment settings instead of writing raw keys into command definitions.

Set your secret once:

```bash
bus secrets set openai_api_key "sk-..."
```

Bind it to a `bus dev` step env:

```bash
bus dev set env-for @work OPENAI_API_KEY secret:openai_api_key
```

Bind it to a `bus run` step env:

```bash
bus run set env-for summarize OPENAI_API_KEY secret:openai_api_key
```

When the `work` or `summarize` step runs, `bus dev` or `bus run` resolves `secret:openai_api_key` through `bus secrets` and injects the decrypted value into the step process environment.

### Files

`bus-secrets` reads and writes repository-local secrets in `.bus/secrets`. It uses [bus-preferences](./bus-preferences) for local key-source preferences (`bus-secrets.age_key_file` and `bus-secrets.age_key_cmd`).

### Exit status and errors

Exit code `0` means success. Exit code `1` means execution failure, such as not found in `get`/`resolve` or an unreadable workspace path. Exit code `2` means invalid usage, such as unknown command, missing required arguments, invalid scope, or invalid secret name.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus secrets set openai_api_key 'sk-...'
secrets set openai_api_key 'sk-...'

# same as: bus secrets resolve secret:openai_api_key
secrets resolve secret:openai_api_key
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-shell">bus-shell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-secrets README](https://github.com/busdk/bus-secrets)
- [bus-dev CLI reference](./bus-dev)
- [bus-run CLI reference](./bus-run)
- [bus-preferences CLI reference](./bus-preferences)
- [bus-config CLI reference](./bus-config)
- [Workspace configuration](../data/workspace-configuration)
