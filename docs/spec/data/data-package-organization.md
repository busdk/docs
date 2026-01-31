## Data Package organization

BusDK may optionally adopt a Frictionless Data Package (typically a `datapackage.json`) to provide a repository-wide manifest of resources and their schemas. A Data Package descriptor lists resources, their paths, and their schema references, enabling whole-repository validation and standardized publication or interchange patterns. See [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/). Even without a descriptor, the directory structure is designed to be discoverable and navigable, but the Data Package option improves automation and interoperability.

For Finnish compliance, a Data Package descriptor SHOULD be used as the manifest inside tax-audit export packs to make datasets and schemas self-describing. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
**Prev:** [CSV conventions](./csv-conventions) · **Index:** [BusDK Design Spec: Data format and storage](../data/) · **Next:** [Scaling over decades](./scaling-over-decades)
<!-- busdk-docs-nav end -->
