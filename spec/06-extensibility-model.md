# BuSDK Design Spec: Extensibility model

## Plug-in modules via new datasets

BuSDK supports adding modules by defining new datasets and schemas and implementing tooling that reads and writes them. A payroll module is a canonical example: a `payroll/` directory could contain `employees.csv` and `payruns.csv` plus schemas, and a CLI command such as `busdk payroll run --month July-2026` could generate salary-related ledger entries by appending to the journal dataset. This extension does not require modifications to existing modules so long as it adheres to established schemas and references valid accounts.

## Event hooks and automation

Although BuSDK is CLI-driven rather than event-driven by default, the architecture supports automation via Git hooks or file watchers. Post-commit hooks can trigger secondary actions such as generating PDFs when invoices are created, emailing invoices, or notifying the owner for review when large transactions are recorded. BuSDK intends to document patterns for such automation and may later provide a lightweight plugin system where modules can subscribe to repository events such as “new invoice” or “new journal entry.”

## AI and external service integration

AI integration is treated as an optional module layer. An AI assistant can read repository data to identify anomalies and can propose changes as commits or branches for human review. This creates a reviewable workflow where the user remains in control and AI suggestions become auditable artifacts. Industry narratives emphasize that AI can accelerate bookkeeping by classifying and reconciling transactions quickly; BuSDK’s structured data and Git-based review model is designed to enable this safely rather than implicitly trusting black-box automation. ([Uplinq](https://www.uplinq.com/post/how-ai-bookkeeping-is-revolutionizing-small-business-accounting?utm_source=chatgpt.com))

## One-developer contributions and ecosystem

BuSDK lowers the barrier for user-written extensions. A user can write small scripts or commands to produce specialized reports such as accounts receivable aging, using only the CSV files and schemas. This encourages an ecosystem of shareable custom modules and report scripts, similar in spirit to communities around CLI-based accounting tools.

## Governance of core schemas

As modularity increases, schema divergence becomes a risk. BuSDK treats core schemas—particularly accounts and journal—as public APIs that require lightweight governance. Schema changes are expected to preserve backward compatibility or provide explicit migrations. New modules should reuse existing keys and fields where appropriate and should integrate financial value changes through the ledger to preserve a comprehensive financial picture. Cross-links such as invoice IDs referencing journal transaction IDs are encouraged for traceability.

