---
title: Library form fields
description: BusDK UI library field labeling and validation message contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [UI controls](../v0.2.2/controls)

## Contract

[`Field`](./field) wraps a visible label, optional help text,
optional validation error, and one control body. Form controls should always be
labeled. Field-level errors are public-safe strings projected by the product
view model: they may name the field and required user action, but must not
include raw provider payloads, stack traces, SQL, tokens, credential values, or
private customer data. Provider/API modules return structured errors; the
product controller maps those errors into field text before rendering.

Fields do not own input type, form submission, provider validation, or resource
payloads. They provide accessible structure around controls supplied through
their body slot.

## Consequence

Product modules can use consistent labels and errors without duplicating
control-specific markup.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Field](./field)
- Input controls
