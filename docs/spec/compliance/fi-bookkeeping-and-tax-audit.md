# Finnish Bookkeeping and Tax-Audit Compliance (BusDK)

Last verified: 2026-01-27

This page defines compliance-facing requirements that the BusDK toolchain (the `bus` dispatcher + `bus-*` modules) MUST implement to satisfy Finnish bookkeeping, retention, and tax-audit expectations. Requirements use RFC-style terms (MUST, MUST NOT, SHOULD, MAY).

## Scope

BusDK covers bookkeeping datasets and their schemas (journal/daybook, general ledger, subledgers, invoices, bank, attachments), audit-trail preservation from source evidence to postings to financial statements, retention and accessibility of accounting material and methods documentation, and reporting outputs such as financial statements, VAT returns, and audit exports.

BusDK does not cover legal representation, statutory filing, or regulatory communications on the user’s behalf. It does not make discretionary accounting judgments (classification, valuation, materiality), and it does not implement industry-specific special regulation beyond the general rules unless explicitly scoped.

## Requirements

### A) Audit trail (kirjausketju / audit trail)

BusDK MUST preserve bidirectional traceability from financial statements and reports to general ledger postings, to journal/daybook entries, to vouchers, to original source documents and system-generated records, and back in the reverse direction. Each posting MUST reference a stable voucher identifier, and each voucher MUST link to its supporting evidence (attachments or external documents); these links MUST be represented in CSV data with explicit foreign keys and MUST be usable without proprietary tooling. Audit-trail references MUST remain resolvable across schema evolution, so if a dataset or field is renamed or split, a migration record MUST preserve the mapping so prior references remain traceable. BusDK MUST make the audit trail demonstrable from electronic material, including in tax audit contexts where the Tax Administration expects a “katkeamaton kirjausketju” to be shown. (KPL 2:5 §; KPL 2:6 §; KILA 2.1; KILA 3.4; Verohallinnon ohje verotarkastuksesta 4.12.2025, sections 3.1 and 3.3)

### B) Chronological and systematic posting

BusDK MUST represent both chronological order (“aikajärjestys”) and systematic order (“asiajärjestys”) for postings, and it MUST treat the journal/daybook and the general ledger as minimum books in BusDK terms. Combining postings (yhdistelmäkirjaukset) from subledgers is permitted, but BusDK MUST maintain an explicit link from the combined posting to the underlying subledger records and vouchers. BusDK MUST provide deterministic ordering within each dataset, using date plus a stable sequence number (or equivalent) so that ordering is reproducible across machines and exports. (KPL 2:2 §; KPL 2:4 §; KPL 2:6 §; KILA 1.4.1; KILA 3.3)

### C) Voucher (tosite) requirements

Every posting MUST be based on a dated and systematically numbered (or otherwise uniquely identified) voucher. Voucher metadata MUST include at least a date, unique identifier, counterparty (when applicable), description, amounts, and VAT breakdown when relevant, and voucher numbering and references MUST be deterministic and MUST NOT be reused. Corrections MUST NOT overwrite prior voucher evidence; they MUST be represented as new vouchers and new entries that reference what they correct. (KPL 2:5 §; KPL 2:7 §; KILA 2.1; KILA 2.4; KILA 3.2; KILA 4.4.2; AVL 209 e–f §)

### D) Corrections and immutability expectations

Primary accounting datasets (journal, ledger, VAT returns, period close summaries) MUST be append-only by default, and corrections MUST be expressed as new entries that reference the original entries and vouchers (reversal, adjustment, or replacement entries) so that history is preserved. BusDK MUST prevent silent edits to posted data after a period is closed or after reporting or statutory declarations have been produced from the data. (KPL 2:7 §; KILA 2.4; KILA 4.4.2)

### E) Retention and accessibility

BusDK MUST support minimum retention periods of 10 years for financial statements, ledgers, chart of accounts, and the list of datasets/materials, and 6 years for vouchers and other accounting material unless longer periods apply in other law. BusDK MUST preserve a “methods description” and a list of accounting datasets and materials (luettelo kirjanpidoista ja aineistoista), including their relationships and storage locations, and this documentation MUST be versioned within the workspace. Accounting material MUST remain readable and printable in clear form for the full retention period. (KPL 2:7 §; KPL 2:7a §; KPL 2:10 §; KILA 4.1.1; KILA 4.4.1; KILA 4.5)

### F) Location and availability for inspection

Accounting material MUST be reviewable from Finland without undue delay, including for authorities and auditors. BusDK workspaces MUST be reconstructible on a standard offline machine using documented, open tooling, and the repository MUST include the necessary schemas, manifests, and method descriptions for review without proprietary dependencies. If material is stored electronically outside Finland, BusDK MUST still allow full access and readable output from Finland. (KPL 2:7 §; KPL 2:9 §; KILA 4.4.4; OVML 24 §)

### G) Tax-audit readiness and delivery

BusDK MUST support an exportable “tax audit pack” for a selected period, and the pack MUST include the journal/daybook, general ledger, subledgers (invoices, bank, reconciliation), vouchers, attachments metadata, VAT summaries, chart of accounts, schemas, and a methods description. The tax audit pack MUST be internally consistent so totals reconcile across datasets and the audit trail remains demonstrable from vouchers to postings to reports, and BusDK MUST allow tax-audit data to be delivered in electronic form with a demonstrable audit trail. (KPL 2:6 §; KILA 3.4; VML 14 §; OVML 24 §; Verohallinnon ohje verotarkastuksesta 4.12.2025, sections 2.1, 3.1 and 3.3)

### H) VAT and periodic reporting support

BusDK MUST store VAT codes, bases, rates, and tax amounts at posting and/or invoice-line level so that VAT returns can be produced and later verified. VAT reports MUST be derivable from journal and invoice data without manual rewriting of history, and corrections MUST remain audit-traceable. VAT return outputs MUST retain references to the underlying postings and vouchers that justify each reported amount. (KPL 2:6 §; KILA 3.4; KILA 3.7; OVML 26 §; AVL 209 e–f §; Verohallinnon ohje verotarkastuksesta 4.12.2025, section 3.3)

## Non-goals and accounting judgment

BusDK MUST provide deterministic primitives, validation, and traceability, but MUST NOT decide discretionary accounting treatment. Modules MAY propose classifications or allocations, but authoritative postings MUST be created or accepted explicitly by the user. When judgment is involved, BusDK MUST allow rationale to be recorded as linked notes or attachments without breaking the audit trail. (KPL 2:5 §; KPL 2:6 §; KILA 2.5; KILA 3.4)

## Compliance mapping (source linkage)

The audit trail requirements (A, D, H, G) are grounded in the statutory audit chain and immutability rules in Kirjanpitolaki (KPL 2:5–2:7 §) and KILA’s 2021 general guidance on audit trail and documentation (KILA 3.4, 4.4.2). Verohallinto’s tax audit guidance explicitly expects electronic accounting data to be produced with a demonstrable, continuous audit trail, which BusDK must support for export packs. (Verohallinnon ohje verotarkastuksesta 4.12.2025, sections 3.1 and 3.3)

Chronological and systematic posting requirements (B) derive from KPL 2:4 § and KILA’s operational guidance for implementing time and subject order, including subledgers and combined postings. (KPL 2:2 §; KPL 2:4 §; KILA 3.3)

Voucher requirements (C) are defined in KPL 2:5 § and expanded by KILA’s guidance on voucher content and verification. VAT invoice content obligations referenced here align with AVL 209 e–f §, with KILA referencing those VAT content requirements in practice. (KPL 2:5 §; KILA 2.1–2.4; AVL 209 e–f §)

Retention, accessibility, and location requirements (E, F) stem from KPL 2:9–2:10 § and KPL 2:7a §, with KILA detailing practical documentation, readability, and Finland-based accessibility. (KPL 2:7–2:10 §; KILA 4.1–4.5)

Tax-audit readiness (G) relies on VML 14 § and OVML 24 §, which define inspection rights and electronic data availability, and Verohallinto’s audit procedure guidance. (VML 14 §; OVML 24 §; Verohallinnon ohje verotarkastuksesta 4.12.2025)

Financial statement output requirements for reports reference Kirjanpitoasetus (KPA 1339/1997) and the small/micro entity regulation (PMA 1753/2015), which BusDK reports must be able to support as output formats when the user is in scope. (KPA 1339/1997; PMA 1753/2015)

## Maintenance process

Re-check Finlex and Verohallinto sources at least annually and whenever legislation changes, update citations and requirements when source sections move or are amended, and treat temporary exceptions as historical context only rather than as MUST-level requirements unless they are currently in force.

---

<!-- busdk-docs-nav start -->
**Prev:** [Plug-in modules via new datasets](../extensibility/plugin-modules-via-datasets) · **Index:** [BusDK Design Document](../../index) · **Next:** [BusDK Design Spec: References and external foundations](../references/)
<!-- busdk-docs-nav end -->

## Sources (authoritative)

Authoritative sources for this page are Kirjanpitolaki (KPL) at https://finlex.fi/fi/laki/ajantasa/1997/19971336, Kirjanpitoasetus (KPA) at https://finlex.fi/fi/laki/ajantasa/1997/19971339, KILA yleisohje 20.4.2021 (PDF) at https://kirjanpitolautakunta.fi/documents/8208007/11087193/final+2021-04-20+KILA-menetelmaohje+(1).pdf/d19100d1-1b6d-e652-3be0-a22a1a157291/final+2021-04-20+KILA-menetelmaohje+(1).pdf?t=1619681814561, Verohallinnon ohje verotarkastuksesta 4.12.2025 at https://www.vero.fi/syventavat-vero-ohjeet/ohje-hakusivu/359968/verohallinnon-ohje-verotarkastuksesta/, Arvonlisäverolaki (AVL) at https://finlex.fi/fi/laki/ajantasa/1993/19931501, Laki verotusmenettelystä (VML) at https://finlex.fi/fi/laki/ajantasa/1995/19951558, Laki oma-aloitteisten verojen verotusmenettelystä (OVML) at https://finlex.fi/fi/laki/ajantasa/2016/20160768, and pien- ja mikroyrityksen tilinpäätösvaatimukset (PMA 1753/2015) at https://finlex.fi/fi/laki/alkup/2015/20151753.
