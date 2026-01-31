## AI-readiness

AI-readiness is a design objective, not a dependency. BusDK must remain fully functional without AI. At the same time, BusDK is intentionally designed so that AI agents can use it as a safe, deterministic toolkit: agents should be able to read structured workspace datasets, run the same CLI workflows as humans, and represent proposed changes as reviewable updates to the repository data before acceptance. When Git is used as the canonical history, those changes naturally take the form of reviewable commits, consistent with [Git as the canonical, append-only source of truth](./git-as-source-of-truth).

This is why BusDK emphasizes modular CLI tools, machine-readable outputs, schema-validated datasets, and append-only audit trails: the system should make it easy for an agent to propose changes, and easy for a human (or another automated check) to validate, review, and accept them with confidence.

Claims that “AI reduces manual effort” should be treated as optional augmentation and not as a promise of correctness. The safety property BusDK guarantees is that any automation — AI-driven or rule-driven — operates through deterministic interfaces and produces reviewable, auditable outcomes.

---

<!-- busdk-docs-nav start -->
**Prev:** [BusDK Design Spec: Design goals and requirements](./) · **Index:** [BusDK Design Spec: Design goals and requirements](./) · **Next:** [Auditability through append-only changes](./append-only-auditability)
<!-- busdk-docs-nav end -->
