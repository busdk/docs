## Plug-in modules via new datasets

BusDK supports adding modules by defining new datasets and schemas and implementing tooling that reads and writes them. A payroll module is a canonical example: a `payroll/` directory could contain `employees.csv` and `payruns.csv` plus schemas, and a CLI command such as `busdk payroll run --month July-2026` could generate salary-related ledger entries by appending to the journal dataset. This extension does not require modifications to existing modules so long as it adheres to established schemas and references valid accounts.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./one-developer-ecosystem">One-developer contributions and ecosystem</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../compliance/fi-bookkeeping-and-tax-audit">Finnish Bookkeeping and Tax-Audit Compliance (BusDK)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
