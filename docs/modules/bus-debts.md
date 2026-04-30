---
title: bus-debts — maintain debt-support receipt, topic, and line data
description: Use bus-debts to record PEKU-style debt-support receipts, their topics, and topic detail lines for bookkeeping support workflows.
---

## `bus-debts` — maintain debt-support receipt, topic, and line data

`bus-debts` is a bookkeeping support register for debt, enforcement, and collection receipts where one document can contain multiple topics and each topic can contain multiple detail lines. The module is intended to preserve structured support data from receipts and PDF attachments so later accounting work can rely on deterministic register data instead of ad hoc notes.

The module owns three datasets in the workspace root. `debt-receipts.csv` stores the document-level facts such as sent date, payment date, paid amount, accrual method, and PDF path. `debt-topics.csv` stores one topic or case under each receipt, including receipt number, case number, claimant, and the monetary fields used for reconciliation. Topics also support two optional ownership fields: `funding_source_owner` for whose money was used to pay the enforced amount, and `debt_owner` for whose debt the topic represents. `debt-lines.csv` stores free-form event lines under a topic.

`bus-debts init` creates the datasets. `receipt add`, `topic add`, and `line add` append new rows after validating the whole hierarchy. `validate` checks the workspace again later. The main arithmetic rule in the first version is that one receipt document's paid amount must equal the sum of its child topic totals.

Each subcommand has command-local help. Use forms like `bus-debts --help receipt add`, `bus-debts --help topic add`, `bus-debts --help line add`, and `bus-debts --help list` when you need the full accepted flag set.

```bash
bus-debts init

bus-debts receipt add \
  --receipt-id PEKU-2023-04-06 \
  --year 2023 \
  --sent-date 06.04.2023 \
  --payment-date 04.04.2023 \
  --paid-amount '1 567,65' \
  --accrual-method 'Määrittelemätön' \
  --pdf-path original/suomiFi/jhh/2023/example.pdf

bus-debts topic add \
  --topic-id TOPIC-2331217162 \
  --receipt-id PEKU-2023-04-06 \
  --receipt-number A600206781123 \
  --case-number 2331217162 \
  --case-name 'Arvonlisävero' \
  --claimant Verohallinto \
  --funding-source-owner 'Toiminimi Example' \
  --debt-owner 'Yrittäjä Example' \
  --allocated-amount 1483.65 \
  --enforcement-fee 84.00 \
  --partial-payment-total 1567.65

bus-debts line add \
  --line-id LINE-1 \
  --topic-id TOPIC-2331217162 \
  --line-date 2023-04-04 \
  --event-type allocation \
  --description 'Asialle käytetty osuus' \
  --amount 1483.65
```

`bus-debts list` prints a three-level listing by default. Use `--level receipts`, `--level topics`, `--level lines`, or `--level all` to constrain the output, and `-f text|tsv|csv|json` when a machine-readable export is needed.

Accepted date formats are `YYYY-MM-DD` and `DD.MM.YYYY`. Accepted amount formats include both canonical decimals such as `14137.80` and Finnish operator input such as `14 137,80`. Stored values are normalized to canonical date and decimal forms.

### Sources

- [Module implementation SDD](../../../sdd/docs/modules/bus-debts.md)
- [Module README](../../../bus-debts/README.md)
