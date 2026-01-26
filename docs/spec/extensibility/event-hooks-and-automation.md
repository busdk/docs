# Event hooks and automation

Although BuSDK is CLI-driven rather than event-driven by default, the architecture supports automation via Git hooks or file watchers managed outside BuSDK. Post-commit hooks can trigger secondary actions such as generating PDFs when invoices are created, emailing invoices, or notifying the owner for review when large transactions are recorded. BuSDK intends to document patterns for such automation and may later provide a lightweight plugin system where modules can subscribe to repository events such as “new invoice” or “new journal entry.”

