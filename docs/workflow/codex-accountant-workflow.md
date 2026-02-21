---
title: Codex-assisted accountant workflow
description: Practical monthly accounting workflow where Codex drives BusDK command preparation while the accountant remains the approval boundary.
---

## Codex-assisted accountant workflow

This workflow shows how an accountant can use Codex as an execution assistant while BusDK remains the deterministic accounting engine. The accountant owns approval decisions, period controls, and final sign-off. Codex prepares and runs explicit `bus` commands against repository data, and every accepted change remains reviewable in workspace datasets before a revision is recorded.

1. Start from a clean repository boundary and confirm current status:

```bash
bus status readiness --year 2026 --compliance fi --format tsv
bus period list --year 2026
```

At this point the accountant defines the objective for Codex as a concrete period task, for example: import February bank rows, clear obvious invoice matches, and prepare VAT review outputs without closing the period.

2. Ask Codex to produce an explicit command plan before mutation:

```text
Review the current repository datasets and propose the exact BusDK commands for February 2026 bank import, reconcile proposal, and VAT pre-check. Do not apply writes yet.
```

This keeps the first pass audit-friendly because the expected command sequence is visible before writes happen. The plan can be compared directly with [Accounting workflow overview](./accounting-workflow-overview), [Import bank transactions and apply payments](./import-bank-transactions-and-apply-payment), and [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply).

3. Execute approved commands through Codex in controlled batches:

```bash
bus bank import --file imports/2026-02-bank.csv
bus reconcile propose --period 2026-02 --format json
bus reconcile apply --proposal proposals/reconcile-2026-02.json
bus validate
```

The accountant reviews each batch outcome from command output plus dataset diffs, then asks Codex to continue or correct. This keeps Codex in an assistant role while preserving explicit user authority over postings and matching decisions.

4. Use Codex for deterministic exception handling instead of ad-hoc shell work:

```text
List unmatched bank rows for 2026-02 and prepare only the missing journal commands, each with attachment references when available.
```

Codex can derive candidate command sets quickly, but the accountant decides whether each proposal is accepted, deferred, or replaced by manual postings. The accepted commands are then run with BusDK modules such as [bus-journal](../modules/bus-journal), [bus-bank](../modules/bus-bank), and [bus-reconcile](../modules/bus-reconcile).

5. Finish with close-ready outputs and an explicit revision boundary:

```bash
bus validate
bus vat report --period 2026-02
bus reports trial-balance --as-of 2026-02-29
```

When outputs are accepted, the accountant records a revision with external version-control tooling. Codex can help draft commit messages and checklist summaries, but it should not bypass the accountant’s approval boundary for legal and audit accountability.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-assisted-classification-review">AI-assisted classification (review before recording a revision)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./workflow-takeaways">Workflow takeaways (transparency, control, automation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](./accounting-workflow-overview)
- [Import bank transactions and apply payments](./import-bank-transactions-and-apply-payment)
- [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply)
- [AI-assisted classification (review before recording a revision)](./ai-assisted-classification-review)
- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-journal module CLI reference](../modules/bus-journal)
- [bus-reconcile module CLI reference](../modules/bus-reconcile)
- [bus-status module CLI reference](../modules/bus-status)
