---
title: BusDK source package pricing
description: Initial source-package prices for BusDK modules, including dependency-inclusive module prices and customer-specific offer guidance.
---

## Overview

This page shows initial offered prices for access to BusDK source code releases.
Customer-specific offers, deployment scope, support, data-processing terms, and
alternative licensing can be discussed separately with sales.

**All BusDK modules are currently available to test for free as binary releases.** Source code release access is sold separately, and every generated module below is a sellable source package. Binary releases are free for now, and are planned to move to a subscription model later.

### Licenses

Source code packages use the source-available [Functional Source License (FSL)](https://fsl.software/). After two years, each release converts to Apache 2.0 or MIT. Alternative commercial licensing is available by contract.

To buy source access for one or more modules, email [sales@hg.fi](mailto:sales@hg.fi) and include the module names you are interested in.

{% assign pricing = site.data["prices-data"] %}

{% if pricing and pricing.modules %}
{% assign total_price_eur = pricing.total_price_eur | plus: 0 %}

Initial source-package price for all `{{ pricing.module_count }}` listed source packages is `{{ total_price_eur | eur_rounded }} EUR`.
Use this page as the pricing surface for purchasable Bus module source
packages, including UI, portal, API provider, integration, operator, and domain
modules. For customer-specific offers, contract scope, support, deployment
model, and licensing terms, contact [sales@hg.fi](mailto:sales@hg.fi).

### Pricing model

Each module has a base price and a dependency-inclusive price. The base price
covers only that module’s source release. Dependency-inclusive price covers
that module plus its dependencies, calculated as a unique transitive set.

The dependency-inclusive price is useful when a buyer wants source access
for one module but also needs the source releases required to build, modify, or
audit that module in context. Customer-specific commercial terms can combine
source access with managed hosting, self-hosted deployment support,
data-processing terms, or alternative licensing.

### All source packages

Every module emitted by the current pricing data is listed here. That includes
foundation modules, application modules, GX/UI modules, portal modules, API
providers, integrations, operator modules, and support modules.

<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endfor %}
  </tbody>
</table>
{% else %}
Pricing data is not available. Run `scripts/update-prices-data.sh` in the repository root to generate `docs/docs/_data/prices-data.json`, then rebuild the docs site.
{% endif %}

{% if pricing and pricing.modules %}
### Pricing data timestamp

Pricing dataset timestamp (UTC): `{{ pricing.prices_utc_time }}`.
{% endif %}

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./cost-summary">Bus project cost summary</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Generated pricing data (`docs/docs/_data/prices-data.json`)](https://github.com/busdk/busdk/blob/main/docs/docs/_data/prices-data.json)
- [Price generation script (`scripts/get-prices-data.sh`)](https://github.com/busdk/busdk/blob/main/scripts/get-prices-data.sh)
- [Price update script (`scripts/update-prices-data.sh`)](https://github.com/busdk/busdk/blob/main/scripts/update-prices-data.sh)
- [Functional Source License (FSL)](https://fsl.software/)
