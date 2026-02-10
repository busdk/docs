## Data Package organization

BusDK uses a Frictionless Data Package descriptor (typically `datapackage.json`) at the workspace root to provide a whole-workspace manifest of resources and their schemas. A Data Package descriptor lists resources, their paths, and their schema references, enabling whole-workspace validation and standardized publication or interchange patterns. See [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/).

The descriptor is also the home for workspace-level BusDK metadata that is not naturally represented as a row-level field in operational datasets. For example, accounting entity configuration lives under the top-level `busdk.accounting_entity` object in `datapackage.json` (see [Workspace configuration (`datapackage.json` extension)](./workspace-configuration)). This relies on Frictionless descriptor extensibility: additional properties are compatible with standard tooling and can be ignored safely by tools that do not understand BusDK.

For Finnish compliance, a Data Package descriptor SHOULD be used as the manifest inside tax-audit export packs to make datasets and schemas self-describing. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./csv-conventions">CSV conventions</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../data/index">BusDK Design Spec: Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./scaling-over-decades">Scaling over decades</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
