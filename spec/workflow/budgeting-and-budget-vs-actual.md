# Budgeting and budget-vs-actual reporting

For budgeting, Alice defines budgets for categories such as office supplies and travel by entering rows into `budget/budgets.csv` via CLI. Later she runs `busdk budget report --year 2026`, which aggregates actual expenses from the ledger and compares them to the budget:

```text
Expense Category     Budget Q1   Actual Q1   Variance
Office Supplies      €500.00     €300.00     €+200.00
Travel               €800.00     €950.00     €-150.00
```

This demonstrates that budgeting is fundamentally a controlled computation over structured CSV, and can be implemented as a small module while remaining integrated and repeatable.

