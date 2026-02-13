---
title: Invoice markings for VAT treatments
description: Invoices are the primary evidence for VAT handling.
---

## Invoice markings for VAT treatments

Invoices are the primary evidence for VAT handling. A VAT percentage alone is not enough to keep evidence reviewable because the same rate, especially 0%, can correspond to different treatments with different reporting consequences.

BusDK treats `vat_treatment` as the deterministic hook for invoice marking rules. When a module generates an invoice representation (such as a PDF), it should be able to choose the required invoice text and decide which identifiers must be present without re-interpreting free-text descriptions.

The phrases below are written in English as canonical examples. Workspaces may use local-language equivalents, but the meaning must remain explicit and unambiguous in the rendered invoice.

| `vat_treatment` | VAT charged by seller | Buyer VAT ID on invoice | Seller VAT ID on invoice | Required invoice phrase (canonical example) | Required/optional identifiers (besides VAT IDs) |
| --- | --- | --- | --- | --- | --- |
| `domestic_standard` | Yes | Optional | Required when VAT-relevant | *(none beyond normal VAT lines)* | None beyond normal invoice identifiers. Use this for domestic taxable sales at `vat_rate`/`vat_percent` `25.5`, `13.5`, or `10`. |
| `reverse_charge` | No | Required | Required when VAT-relevant | `Reverse charge` | None beyond normal invoice identifiers. The invoice must not present VAT payable by the seller, and the buyer VAT ID must be present so the basis remains reviewable from evidence. |
| `intra_eu_supply` | No | Required | Required when VAT-relevant | `Intra-Community supply` | Buyer country code is optional but often useful for validation. The buyer VAT ID must be present so EU vs domestic handling is deterministic. |
| `export` | No | Optional | Required when VAT-relevant | `Export` | A customs/export evidence reference is optional but often useful for review. The invoice must make the export treatment explicit so 0% is not ambiguous later. |
| `exempt` | No | Optional | Required when VAT-relevant | `VAT exempt` | The invoice must make the exemption explicit so it is not confused with export or intra-EU treatments. |

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./define">Define VAT treatment codes</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">VAT treatment</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./validate">Validate VAT mappings</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [VAT treatment](./index)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)

