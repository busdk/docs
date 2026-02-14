---
title: Account types in double-entry bookkeeping
description: In double-entry bookkeeping, every ledger account has an account type.
---

## Account types in double-entry bookkeeping

In double-entry bookkeeping, every ledger account has an account type. The type expresses the economic meaning of the account and determines its normal balance (debit-side or credit-side). In practice, this matters because the same posting direction has different effects depending on the account type: a debit increases an asset account but decreases a liability account.

### The five core account types

#### Assets

Assets are resources the business controls that are expected to provide future economic benefit. Typical assets include cash, bank accounts, accounts receivable, inventory, equipment, and prepaid expenses.

#### Liabilities

Liabilities are obligations the business owes to others. Typical liabilities include accounts payable, accrued expenses, loans, and VAT or payroll taxes payable.

#### Equity

Equity is the owners’ residual interest in the business after liabilities. Typical equity accounts include share capital, invested capital, retained earnings, and the current-period result (profit or loss).

#### Income (Revenue)

Income accounts track value earned from providing goods or services, such as sales, service revenue, and interest income. Income increases profit.

#### Expenses

Expenses track costs incurred to earn income, such as rent, wages, software subscriptions, and utilities. Expenses decrease profit.

### Normal balance and how debits/credits affect each type

“Normal balance” is the posting side where increases usually go for that type.

| Account type | Normal balance | Increases with | Decreases with |
| ------------ | -------------: | -------------- | -------------- |
| Assets       |          Debit | Debit          | Credit         |
| Expenses     |          Debit | Debit          | Credit         |
| Liabilities  |         Credit | Credit         | Debit          |
| Equity       |         Credit | Credit         | Debit          |
| Income       |         Credit | Credit         | Debit          |

A practical mental model is that assets and expenses grow on the debit side, while liabilities, equity, and income grow on the credit side.

In BusDK, account type metadata is typically used as part of chart-of-accounts structure and for deterministic reporting. It is a compact way to express how balances should be interpreted in balance sheet and profit and loss views, without changing the underlying posting rule that total debits must equal total credits.

### Common subcategories (same posting rules, more specific meaning)

Many account lists use subcategories to improve reporting without changing posting behavior. Assets are commonly split into current (short-term) and non-current (long-term), and liabilities are split the same way.

Typical asset subcategories include current assets (cash and bank, accounts receivable, inventory, prepaid expenses) and non-current assets (equipment, vehicles, intangible assets, long-term investments).

Typical liability subcategories include current liabilities (accounts payable, accrued liabilities, VAT payable, short-term loan portions) and non-current liabilities (long-term loans).

Income and expense accounts are often split by business meaning (operating versus other) and by presentation (for example, separating cost of goods sold from other operating expenses).

### Contra accounts (important exception)

A contra account offsets another account while using the opposite normal balance of the main account it relates to. This preserves the “gross” amount in the main account while recording reductions separately.

Common contra examples:

* **Accumulated depreciation** (contra-asset): offsets equipment; normal balance is **credit**
* **Allowance for doubtful accounts** (contra-asset): offsets receivables; normal balance is **credit**
* **Sales returns/allowances** (contra-income): offsets revenue; normal balance is **debit**

Contra accounts don’t break double-entry rules — they keep the economic meaning visible while reversing the “usual” side for increases.

### Temporary vs permanent accounts

This distinction is mostly about period reporting and closing, not about debit and credit mechanics. Income and expense accounts are temporary in the sense that they are closed into equity when producing a period result, while assets, liabilities, and equity carry forward across periods.

### Choosing the right type

Choose the type based on the economic meaning of what the account represents. An account is an asset when it represents something the business controls, a liability when it represents an obligation, and equity when it represents the owners’ stake or accumulated result. Income represents earned value, and expenses represent the costs of operating or earning that value.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../data/index">BusDK Design Spec: Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../data/index">BusDK Design Spec: Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./append-only-and-soft-deletion">Append-only updates and soft deletion</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
