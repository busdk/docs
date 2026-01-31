# Double-entry ledger accounting

Double-entry ledger accounting is a core requirement for BusDK. In the Finnish context, double-entry bookkeeping is the statutory baseline for essentially all incorporated/legal entities and most other bookkeeping obligors, with limited exceptions for small sole traders under thresholds. In practice, this makes a balanced, auditable double-entry ledger the canonical dataset that other modules produce, validate, and report from. ([KPL][1])

In double-entry bookkeeping, every business transaction is recorded as postings that affect at least two accounts, with equal debit and credit totals. This “always balanced” constraint acts as a built-in checksum: if entries don’t balance, the ledger is not valid. The same structure supports accrual accounting (receivables, payables, allocations, period-end adjustments) rather than only cash-in/cash-out views.

## What Finnish bookkeeping expects from the ledger

Finnish bookkeeping requirements are not only “debits equal credits”. They also require that the bookkeeping is structured so it can be reviewed and verified through an audit chain (kirjausketju / audit trail) from source evidence to postings and onward into financial statements—and, importantly, back again. ([KPL][1], [KILA methods guide][3])

At design-goal level, the core expectations that shape BusDK’s ledger model are:

**Voucher basis (tosite).** Every posting must be based on a dated voucher that is systematically numbered or otherwise uniquely identifiable, and the relationship between the voucher and the postings must be easy to establish. ([KPL][1], [KILA methods guide][3])

**Both chronological and systematic review.** Bookkeeping must support review in time order and in account order (the traditional journal/daybook and general-ledger views), even when the underlying storage is not literal printed books. ([KPL][1], [KPA][2], [KILA daybook/ledger guidance][5])

**Bidirectional audit trail.** The bookkeeping must be organized so that traceability from voucher → postings → ledger → reports is easy to verify, and the same traceability also works in reverse from a reported figure back to the postings and vouchers that justify it. ([KPL][1], [KILA methods guide][3])

**No “silent edits” after closing or reporting.** Once accounting outputs have been prepared and given to external parties (for example, financial statements or periodic reports produced from the books), corrections must be represented as additional bookkeeping—reversals and adjusting entries—rather than altering history in place. ([KPL][1], [KILA methods guide][3])

**Inspectable over the retention period.** Accounting material must remain available and producible in readable form for the statutory retention periods. BusDK treats this as a ledger design constraint (data must stay interpretable), while the detailed retention rules live in the compliance spec. ([KPL][1], [KILA retention summary][4])

## Implications for BusDK

BusDK treats the ledger as the core dataset that other modules feed into. Modules may originate economic events (sales, purchases, bank movements, payroll, depreciation, inventory changes), but they must not weaken the ledger’s invariants or the audit chain.

Concretely, “double-entry ledger accounting” as a design goal means:

**A business event is posted as a balanced set.** A single event may contain many lines (splits), but it must be balanced overall.

**Every posting is traceable.** Postings must be linkable to a voucher and to the originating record that explains why the posting exists (invoice, bank record, payroll run, depreciation event, etc.), so the audit chain holds end-to-end.

**Reporting is reproducible.** The ledger must be able to produce the chronological and account-based views expected in Finnish practice when needed, without manual “fix-ups” to restore ordering or traceability. ([KILA methods guide][3])

**Corrections preserve history.** Corrections are represented as additional postings that reference what they correct (reversal/adjustment), preserving the original record rather than editing it away. The storage-level “append-only” rule and post-closing immutability constraints are defined elsewhere. ([Append-only updates and soft deletion][6])

## Where the detailed rules live

This page states the design goal. The compliance-facing “what must be true” requirements for audit trail, vouchers, retention, and Finnish tax-audit readiness live in [Finnish bookkeeping and tax-audit compliance][7]. The design rationale and mechanics for append-only correction workflows live in [Append-only updates and soft deletion][6].

---

<!-- busdk-docs-nav start -->
**Prev:** [CLI-first and human-friendly interfaces](./cli-first) · **Index:** [BusDK Design Document](../../index) · **Next:** [Extensibility as a first-class goal](./extensibility)
<!-- busdk-docs-nav end -->

## Sources

[1]: https://finlex.fi/fi/laki/ajantasa/1997/19971336 "Kirjanpitolaki (KPL) 1336/1997 (Finlex)"
[2]: https://finlex.fi/fi/laki/ajantasa/1997/19971339 "Kirjanpitoasetus (KPA) 1339/1997 (Finlex)"
[3]: https://kirjanpitolautakunta.fi/documents/8208007/11087193/final%2B2021-04-20%2BKILA-menetelmaohje%2B%281%29.pdf "KILA: Yleisohje kirjanpidon menetelmistä ja aineistoista (20.4.2021)"
[4]: https://kirjanpitolautakunta.fi/sv/-/kirjanpitoaineiston-sailyttamises-1 "KILA: Kirjanpitoaineiston säilyttämisestä (summary)"
[5]: https://kirjanpitolautakunta.fi/-/paiva-ja-paakirjan-tulostamin-1 "KILA: Päivä- ja pääkirjan tulostaminen"
[6]: ../data/append-only-and-soft-deletion "Append-only updates and soft deletion"
[7]: ../compliance/fi-bookkeeping-and-tax-audit "Finnish bookkeeping and tax-audit compliance"
