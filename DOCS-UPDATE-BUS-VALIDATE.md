# Documentation update instructions — bus-validate

Status of [docs.busdk.com](https://docs.busdk.com) bus-validate content relative to this repository. Last checked against live docs: 2026-02-18.

---

## Current state

The **module CLI reference** ([modules/bus-validate](https://docs.busdk.com/modules/bus-validate)) and **module SDD** ([sdd/bus-validate](https://docs.busdk.com/sdd/bus-validate)) match the current implementation:

- Stdout empty on success; `--format text` / `tsv`; `--output` no-op for `bus validate`.
- Parity and journal-gap described as first-class subcommands with thresholds and CI exit behavior.
- Development state: completeness and use case readiness "high"; planned next: audit/closed-period and class-aware gap.
- SDD: parity and gap implemented as subcommands (IF-VAL-002); Suggested capabilities include class-aware gap and per-bucket thresholds.

**No pending doc edits** for the module page or SDD from this repo. Future doc updates here when implementation or the live site changes.

---

## Suggestion 14b: Class-aware gap validation thresholds (future)

**Target:** [bus-validate](https://docs.busdk.com/modules/bus-validate).

**Status:** Not implemented. No per-bucket gap thresholds in code. **Documented** in [SDD Suggested capabilities](https://docs.busdk.com/sdd/bus-validate#suggested-capabilities-out-of-current-scope) (class-aware gap reporting and per-bucket thresholds).

**Problem:** Teams may want to enforce that "operational" gap is below a threshold while allowing higher "financing" or "transfer" backlog; today this is custom logic.

**Suggested capability:** Optional validation that compares gap (e.g. unposted bank vs journal) per account bucket against configurable thresholds; CI-friendly exit when a bucket exceeds its threshold.

**Expected value:** CI can fail on operational backlog while tolerating financing/transfer backlog.

When implementing, add per-bucket threshold semantics to the CLI (e.g. `--max-abs-delta-operational` or config per bucket) and reference the existing SDD Suggested capabilities text.
