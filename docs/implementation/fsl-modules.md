---
title: BusDK module pricing
description: Pricing for BusDK modules offered under source-available licenses, including dependency-inclusive totals and how to request source access.
---

## Overview

This page defines how BusDK module source access is licensed and priced.

### Licenses

Sellable modules are offered under source-available terms using the [Functional Source License (FSL)](https://fsl.software/). Under FSL, each released version converts to Apache 2.0 or MIT after two years. Alternative commercial license terms are also available by contract.

{% assign pricing = site.data["prices-data"] %}

{% if pricing and pricing.modules %}
{% assign total_price_eur = pricing.total_price_eur | plus: 0 %}
{% assign discounted_total_eur = total_price_eur | times: 0.8 | round: 2 %}

### Package pricing summary

All-inclusive total price is `{{ total_price_eur | eur_rounded }} EUR`. Full package price with 20% discount is `{{ discounted_total_eur | eur_rounded }} EUR`.

### Pricing model

Each module has a base price and a dependency-inclusive price. Dependency-inclusive price includes the module’s own base price plus prices of its dependencies. The table lists dependencies as a unique transitive set for each module.

{% assign category_core = "bus-init,bus-config,bus-data,bus-preferences" | split: "," %}
{% assign category_ui = "bus-sheets,bus-books" | split: "," %}
{% assign category_automation = "bus-api,bus-run,bus-agent,bus-secrets,bus-dev" | split: "," %}
{% assign category_ledger = "bus-bfl,bus-accounts,bus-entities,bus-period,bus-balances" | split: "," %}
{% assign category_journal = "bus-journal,bus-invoices,bus-bank,bus-reconcile,bus-attachments" | split: "," %}
{% assign category_assets = "bus-assets,bus-loans,bus-inventory,bus-payroll,bus-budget" | split: "," %}
{% assign category_validation = "bus-reports,bus-replay,bus-validate,bus-vat,bus-pdf,bus-filing" | split: "," %}
{% assign category_filing_targets = "bus-filing-prh,bus-filing-vero" | split: "," %}
{% assign all_frontpage_categories = "bus-init,bus-config,bus-data,bus-preferences,bus-sheets,bus-books,bus-api,bus-run,bus-agent,bus-secrets,bus-dev,bus-bfl,bus-accounts,bus-entities,bus-period,bus-balances,bus-journal,bus-invoices,bus-bank,bus-reconcile,bus-attachments,bus-assets,bus-loans,bus-inventory,bus-payroll,bus-budget,bus-reports,bus-replay,bus-validate,bus-vat,bus-pdf,bus-filing,bus-filing-prh,bus-filing-vero" | split: "," %}

### Core commands
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_core contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### User interfaces
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_ui contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### Automation and integration
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_automation contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### Ledger foundation
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_ledger contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### Journal flow
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_journal contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### Assets and resources
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_assets contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### Validation and reports
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_validation contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### Filing targets
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% if category_filing_targets contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endif %}{% endfor %}
  </tbody>
</table>

### Other modules
<table>
  <thead>
    <tr><th>Module</th><th>Dependency-inclusive price (EUR)</th><th>Base price (EUR)</th><th>Dependencies</th></tr>
  </thead>
  <tbody>
    {% for module in pricing.modules %}{% unless all_frontpage_categories contains module.name %}
    <tr>
      <td><a href="../modules/{{ module.name }}">{{ module.name }}</a></td>
      <td>{{ module.price_eur | eur_rounded }}</td>
      <td>{{ module.base_price_eur | eur_rounded }}</td>
      <td>{% if module.dependencies and module.dependencies.size > 0 %}{% for dep in module.dependencies %}<a href="../modules/{{ dep }}">{{ dep }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}{% else %}none{% endif %}</td>
    </tr>
    {% endunless %}{% endfor %}
  </tbody>
</table>
{% else %}
Pricing data is not available. Run `scripts/update-prices-data.sh` in the repository root to generate `docs/docs/_data/prices-data.json`, then rebuild the docs site.
{% endif %}

To buy source access for one or more modules, email [sales@hg.fi](mailto:sales@hg.fi) and include the module names you are interested in.

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
