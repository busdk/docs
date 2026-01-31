## Data Package organization

BusDK may optionally adopt a Frictionless Data Package (typically a `datapackage.json`) to provide a repository-wide manifest of resources and their schemas. A Data Package descriptor lists resources, their paths, and their schema references, enabling whole-repository validation and standardized publication or interchange patterns. See [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/). Even without a descriptor, the directory structure is designed to be discoverable and navigable, but the Data Package option improves automation and interoperability.

For Finnish compliance, a Data Package descriptor SHOULD be used as the manifest inside tax-audit export packs to make datasets and schemas self-describing. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./csv-conventions">CSV conventions</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../data/index">BusDK Design Spec: Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./scaling-over-decades">Scaling over decades</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
