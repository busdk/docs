# Automated Git commits per operation

A distinctive behavior of BuSDK is integrating Git into the default workflow. After a command successfully updates data, the CLI stages and commits changes with templated, descriptive messages so the user does not need to manually perform `git add` and `git commit` for routine bookkeeping. For example:

```bash
busdk accounts add --code 3000 --name "Consulting Income" --type Income
```

is expected to append a new account row to `accounts.csv` and commit with a message such as “Add account 3000 Consulting Income.”

The default model is “one commit per high-level operation” to maximize audit clarity and align with append-only discipline. BuSDK may also support batching operations into a single commit either through explicit batch modes or by allowing auto-commit to be disabled so the user can commit manually after a series of commands.

