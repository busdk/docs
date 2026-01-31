## Year-end close (closing entries)

At year end, Alice closes the books. BusDK may provide a command such as `bus ledger close-year 2026` to generate closing entries that zero income and expense accounts into retained earnings and roll forward balances. If a built-in command does not exist, the open, schema-defined data allows Alice or her accountant to write a script to perform the close and add it as a custom command, reinforcing extensibility. Closing entries are committed via external Git tooling so that the derivation of opening balances for 2027 remains traceable.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./workflow-takeaways">Workflow takeaways (transparency, control, automation)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../modules/index">Modules</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
