# Product Taxonomy Guidance

Keep `PRODUCTS.md` as a product taxonomy, not a module inventory or agent
process note. It should describe product lines, supporting platform products,
and excluded or not-yet-marketable surfaces in user-facing terms.

Use these rules when editing product taxonomy or public product pages:

- Keep BusDK as the bundle, installer, and shared product-family identity.
- Give primary product pages to user-facing products that buyers, operators,
  developers, or finance users can understand as a complete product.
- Order end-user product lines by strategic public importance, not by command
  or module order. Bus Agentic Development, Bus AI Platform, and Bus Books
  should appear before smaller command-oriented products such as Bus Top and
  Bus Services.
- Present Bus Services as generally useful process-level service stack
  software, not only as BusDK project support. Its public message may compare
  it to Docker Compose for packaging multiple services, especially during
  development, while emphasizing that it does not require containers or
  virtualization and can run inside containers or systemd-managed environments.
  Do not describe Bus Services as a security, sandboxing, or service isolation
  layer; it does not limit access between services.
- Present Bus GX/UI Library as a main product line even though it also supports
  other BusDK products. Teams may want Go-native UI components with TSX-like
  authoring directly, so `bus-gx` and `bus-ui` should be public product
  surfaces for compiled Go render roots, reusable component families, runtime
  bridges, deterministic tests, and policy-free frontend surfaces. Do not
  position it as "React cloned in Go"; React and TSX are useful reference
  points, but the product contract is Go-first and keeps routes,
  authorization, provider semantics, secrets, and business policy in owning
  product modules.
- Group supporting infrastructure under a separate supporting-platform category
  when it exists mainly to build, host, connect, or operate BusDK components.
- Treat dispatcher and host modules such as `bus`, `bus-api`,
  `bus-integration`, `bus-portal`, and `bus-operator` as host products. Their
  child modules belong under the concrete product line they serve.
- Do not duplicate a module across multiple marketed product pages. Cross-link
  when a module participates in more than one workflow.
- Do not market unfinished, research-only, or unclear surfaces as public
  products yet. Document them as research, technical preview, or internal
  modules until their user-facing value is ready.
- Keep the explicit exclusion list in this guidance, not in `PRODUCTS.md`.
  Current exclusions:
  - Bus Filing Finland is a real direction, but not ready for marketing yet.
    This covers `bus-filing`, `bus-filing-prh`, and `bus-filing-vero`.
  - `aiz` is a research project for now.
  - `bus-work` should not be marketed until its status is fully reconciled with
    Bus Agentic Development.
  - Individual `bus-api-provider-*`, `bus-integration-*`, and
    `bus-operator-*` modules should be assigned to the product line they serve
    instead of published as separate product pages.
- Keep Bus Books as the single public accounting and financial-workflow
  product for humans and agentic AI. The deterministic accounting engine, data
  workbench surfaces, Bus Formula Language, and `bus-portal-accounting` are
  proof and feature depth inside Bus Books unless they later become
  independently sellable. The Bus Books product page may explain that human
  apps, agent-facing tools, the UI, CLI, and API operate over the same
  deterministic workspace data for accounting, invoices, and financial
  workflows. Modules under Bus Books include `bus-accounts`, `bus-assets`,
  `bus-attachments`, `bus-balances`, `bus-bank`, `bus-bfl`, `bus-budget`,
  `bus-customers`, `bus-data`, `bus-debts`, `bus-entities`, `bus-files`,
  `bus-inventory`, `bus-invoices`, `bus-journal`, `bus-ledger`, `bus-loans`,
  `bus-memo`, `bus-payroll`, `bus-pdf`, `bus-period`, `bus-reconcile`,
  `bus-replay`, `bus-reports`, `bus-sheets`, `bus-validate`, `bus-vat`, and
  `bus-vendors`. `bus-portal-accounting` is the customer-facing portal
  experience for workspace summaries, attachment uploads, evidence packages,
  and artifact preview/download workflows. `bus-pdf` is document-rendering
  infrastructure for Bus Books workflows such as invoices, reports, and
  evidence packs, not a standalone end-user product.
- Keep Bus Auth, Bus Auth Portal, and Bus Billing under Bus AI Platform.
  `bus-auth`, `bus-portal-auth`, `bus-billing`, auth/session providers, usage
  hooks, Stripe integration, and auth/billing operators are platform services
  for login, approval, entitlements, metering, and paid AI hosting. They should
  not be a separate public product page unless the auth/billing experience
  later becomes independently understandable and sellable.
- Keep Bus Notes under Bus Agentic Development. `bus-notes`,
  `bus-portal-notes`, `bus-api-provider-notes`, `bus-integration-notes`, and
  `bus-faq` provide durable project memory, review notes, publishing, search,
  and FAQ-style answer storage for agentic development workflows; they should
  not be a separate public product page unless the notes experience later
  becomes independently understandable and sellable.
- Use Bus AI Platform, not Bus AI API, as the public product line for AI
  hosting services. This product may include OpenAI-compatible model access,
  inference/runtime control, deployment automation, user-owned VMs,
  containers, terminal sessions, node/cloud/database readiness, lifecycle
  events, usage hooks, auth, billing, and future UIs. Bus Deploy, Bus Runtime,
  Bus Auth, and Bus Billing modules belong under Bus AI Platform unless a
  separate deployment, runtime, or auth/billing product becomes independently
  understandable and sellable.
- Keep Bus Agentic Development as the product line for semi-autonomous
  software development. The selling point is integrating autonomous AI worker
  and supervisor agents into a software project so they can operate as
  autonomously as normal human workers, not merely human-supervised AI
  assistance. The market focus should be BusDK's own AI-native development
  workflow: BusDK software, BusDK tools, Go-heavy systems, and adjacent
  projects where the same semi-automatic development loop works seamlessly.
  This is not a strict language boundary, but generic "any kind of software
  development" should not be the first public promise. Human review and
  approval should be presented as an available governance/control layer, while
  the product should also support AI supervisor agents that can define work,
  launch workers, monitor evidence, review output, and keep the board moving.
  Multi-environment execution is a core product point: Bus agents can work
  across local and remote development environments, and teams should be able to
  add multiple SSH-accessible environments as work capacity for autonomous
  agents. Do not split tasks, workers, agent runtime, prompts, chat, AI portal,
  notes, MCP, repository workspace contracts, or developer factory UI into
  separate public product pages unless those surfaces later become
  independently understandable and sellable. MCP and repository modules are
  supporting capabilities under Bus Agentic Development. That product page
  should explain the full loop: task threads, worker creation and control, the
  lightweight Bus-owned agent runtime, local and remote execution,
  SSH-configured development environments, prompt/script/pipeline workflows,
  chat, durable project notes, approvals, terminal state, repository
  workspaces, MCP capability exposure, quality review, supervisor-agent
  automation, and developer workflow UI.
