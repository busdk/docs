## Configure the chart of accounts

Alice configures the chart of accounts early, because most other workflows depend on stable account references. The chart of accounts is stored as schema-validated repository data, so later postings can refer to accounts deterministically.

1. Alice initializes the accounts datasets if they are not already present:

```bash
cd 2026-bookkeeping
bus accounts init
```

2. Alice lists the current chart of accounts so she can see what exists and what still needs to be added:

```bash
bus accounts list
```

3. Alice appends the baseline set of accounts she needs for her day-to-day workflow:

```bash
bus accounts add --help

bus accounts add \
  --code 1910 --name "Bank" --type asset

bus accounts add \
  --code 1700 --name "Accounts Receivable" --type asset

bus accounts add \
  --code 3000 --name "Consulting Revenue" --type income

bus accounts add \
  --code 2930 --name "VAT Payable" --type liability
```

Each addition updates `accounts.csv` and validates invariants such as uniqueness and allowed account types. If the command is incorrect, it fails with a non-zero exit code and leaves the workspace datasets unchanged.

4. Alice validates the resulting dataset:

```bash
bus accounts validate
```

5. Alice records the change as a new revision using her version control tooling.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./budgeting-and-budget-vs-actual">Budgeting and budget-vs-actual reporting</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./create-sales-invoice">Add a sales invoice (interactive workflow)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
