# Double-entry ledger accounting

Double-entry ledger accounting is a core requirement. In the Finnish context, double-entry is the baseline expectation for bookkeeping, and the ledger must support an audit chain from source evidence through postings into financial statements. The ledger follows double-entry bookkeeping principles: each financial transaction is recorded with equal and opposite debit and credit entries affecting two or more accounts. This provides a built-in checksum, supports accrual-based accounting concepts (including receivables and payables, not only cash), and enforces the accounting equation that underpins reliable statements. BusDK treats the ledger as the core dataset that other modules feed into, while still enabling the traditional chronological and account-based views expected in Finnish practice when those reports are needed.

---

<!-- busdk-docs-nav start -->
**Prev:** [CLI-first and human-friendly interfaces](./cli-first) · **Index:** [BusDK Design Document](../../index) · **Next:** [Extensibility as a first-class goal](./extensibility)
<!-- busdk-docs-nav end -->

## Sources

This page references Kirjanpitolaki (KPL) at https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/1997/1336, Kirjanpitoasetus (KPA) at https://www.finlex.fi/fi/lainsaadanto/1997/1339, Kirjanpitolautakunta’s “Yleisohje kirjanpidon menetelmistä ja aineistoista” (20.4.2021) at https://kirjanpitolautakunta.fi/documents/8208007/11087193/final%2B2021-04-20%2BKILA-menetelmaohje%2B%281%29.pdf, Verohallinto’s “Kirjanpito, tilikausi, verokausi” at https://www.vero.fi/yritykset-ja-yhteisot/yritystoiminta/uusi-yritys/kirjanpito-tilikausi-verokausi/, and Suomi.fi’s “Kirjanpidon järjestäminen” at https://www.suomi.fi/yritykselle/talouden-hallinta-ja-verotus/yrityksen-taloushallinto/opas/kirjanpito-ja-taloushallinto/kirjanpidon-jarjestaminen.
