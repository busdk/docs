---
title: Double-entry ledger accounting
description: Double-entry ledger accounting is a core requirement for BusDK.
---

## Double-entry ledger accounting

Double-entry ledger accounting is a core requirement for BusDK. In the Finnish context, double-entry bookkeeping is the statutory baseline for essentially all incorporated/legal entities and most other bookkeeping obligors, with limited exceptions for small sole traders under thresholds, as defined in [Kirjanpitolaki (KPL) 1336/1997 (Finlex)](https://finlex.fi/fi/laki/ajantasa/1997/19971336). In practice, this makes a balanced, auditable double-entry ledger the canonical dataset that other modules produce, validate, and report from.

In double-entry bookkeeping, every business transaction is recorded as postings that affect at least two accounts, with equal debit and credit totals. This “always balanced” constraint acts as a built-in checksum: if entries don’t balance, the ledger is not valid. The same structure supports accrual accounting (receivables, payables, allocations, period-end adjustments) rather than only cash-in/cash-out views.

### What Finnish bookkeeping expects from the ledger

Finnish bookkeeping requirements are not only “debits equal credits”. They also require that the bookkeeping is structured so it can be reviewed and verified through an audit chain (kirjausketju / audit trail) from source evidence to postings and onward into financial statements — and, importantly, back again. This expectation is set in [Kirjanpitolaki (KPL) 1336/1997 (Finlex)](https://finlex.fi/fi/laki/ajantasa/1997/19971336) and reinforced by Kirjanpitolautakunta’s guidance in [Yleisohje kirjanpidon menetelmistä ja aineistoista (20.4.2021)](https://kirjanpitolautakunta.fi/documents/8208007/11087193/final%2B2021-04-20%2BKILA-menetelmaohje%2B%281%29.pdf).

In BusDK terms, this expectation means that postings are voucher-based, that the ledger can be reviewed both chronologically and by account when needed, and that traceability works in both directions from evidence into postings and from reported figures back to the postings and vouchers that justify them. It also means that once outputs have been prepared for external use, corrections are represented as additional bookkeeping rather than silent edits to history, consistent with [Auditability through append-only changes](./append-only-auditability) and the storage-level mechanics described in [Append-only updates and soft deletion](../data/append-only-and-soft-deletion).

### Implications for BusDK

BusDK treats the ledger as the core dataset that other modules feed into. Modules may originate economic events (sales, purchases, bank movements, payroll, depreciation, inventory changes), but they must not weaken the ledger’s invariants or the audit chain.

In BusDK terms, a business event is posted as a balanced set. A single event may contain many lines (splits), but it must be balanced overall. Postings remain traceable to a voucher and to the originating record that explains why the posting exists (invoice, bank record, payroll run, depreciation event), so the audit chain holds end-to-end. Reporting remains reproducible: the ledger can produce the chronological and account-based views expected in Finnish practice when needed, without manual “fix-ups” to restore ordering or traceability. Corrections preserve history by being represented as additional postings that reference what they correct (reversal/adjustment), rather than editing away earlier records.

The compliance requirements for Finnish audit trail, vouchers, and retention live in [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit). The storage-level rules for append-only correction workflows live in [Append-only updates and soft deletion](../data/append-only-and-soft-deletion).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./cli-first">CLI-first and human-friendly interfaces</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./extensibility">Extensibility as a first-class goal</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Kirjanpitolaki (KPL) 1336/1997 (Finlex)](https://finlex.fi/fi/laki/ajantasa/1997/19971336)
- [Kirjanpitoasetus (KPA) 1339/1997 (Finlex)](https://finlex.fi/fi/laki/ajantasa/1997/19971339)
- [KILA: Yleisohje kirjanpidon menetelmistä ja aineistoista (20.4.2021)](https://kirjanpitolautakunta.fi/documents/8208007/11087193/final%2B2021-04-20%2BKILA-menetelmaohje%2B%281%29.pdf)
- [KILA: Kirjanpitoaineiston säilyttämisestä (summary)](https://kirjanpitolautakunta.fi/sv/-/kirjanpitoaineiston-sailyttamises-1)
- [KILA: Päivä- ja pääkirjan tulostaminen](https://kirjanpitolautakunta.fi/-/paiva-ja-paakirjan-tulostamin-1)
