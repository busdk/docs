## Git commit conventions per operation (external Git)

BusDK runs on top of a Git-managed repository, but it does not implement or run Git itself. The spec defines commit conventions per operation and expects users or external automation to apply them using their existing Git tooling. For example:

```bash
busdk accounts add --code 3000 --name "Consulting Income" --type Income
```

is expected to append a new account row to `accounts.csv`, and the corresponding Git commit (made externally) would use a message such as “Add account 3000 Consulting Income.”

The default model is “one commit per high-level operation” to maximize audit clarity and align with append-only discipline. External workflows may also batch operations into a single commit when needed (for example, after a scripted import).

---

<!-- busdk-docs-nav start -->
**Prev:** [Extensible CLI surface and API parity](./api-parity) · **Index:** [BusDK Design Document](../../index) · **Next:** [Command structure and discoverability](./command-structure)
<!-- busdk-docs-nav end -->
