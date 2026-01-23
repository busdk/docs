# BuSDK Design Spec: Integration and future interfaces

Although CLI is the initial interface, the architecture is designed for future APIs, dashboards, or external integrations. Because modules already parse inputs, validate, and produce outputs, they can be wrapped by a RESTful server or web interface without moving business logic into a monolith. The Git repository and CSV resources are treated as a contract that any interface can operate on, including static reporting sites and BI tools that read CSV directly.

External systems can integrate by exchanging CSV resources or by operating on the Git repository itself. Examples include a web store exporting daily sales as CSV for invoice import, or a CRM integration that triggers creation of customer records via a commit or webhook-driven automation. The design aims to prevent vendor lock-in by relying on open, widely supported formats.

