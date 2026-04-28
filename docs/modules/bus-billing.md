---
title: bus billing — billing setup and status
description: bus billing helps end users set up and manage provider-neutral Bus billing.
---

## `bus billing` — billing setup and status

`bus-billing` owns the end-user `bus billing ...` command namespace. It helps
approved users set up billing before paid Bus features, such as LLM API access,
are enabled. The command is provider-neutral; deployments may use Stripe or a
different payment provider behind the Billing API.

### Commands

`bus billing status` shows billing state and enabled paid features. If billing
is missing, the command prints the next command to run.

`bus billing setup` creates a hosted billing setup URL and prints it. The URL
may point to Stripe Checkout or another provider-hosted setup page depending on
deployment configuration.

`bus billing portal` creates a hosted billing portal URL for payment method and
invoice management.

The end-user CLI intentionally does not expose catalog, admin, Stripe, or
product configuration commands. Operator workflows use modules such as
`bus operator billing` and `bus operator stripe`.

### Credentials

By default, `bus billing` reads the normal Bus API token saved by `bus auth`
under the user config root. If no token exists, request a narrow billing setup
token first:

```sh
bus auth token --scope "billing:read billing:setup"
```

If the token is expired or missing required billing scopes, `bus billing`
prints the same token command. If a paid feature such as LLM access returns
`billing_required`, the CLI prints the server-provided next command, normally
`bus billing setup`.

### First LLM Billing Flow

Register and verify email with `bus auth`, wait for admin approval, request a
narrow billing setup token, run `bus billing setup`, complete the hosted
payment setup, and then request the paid LLM API token. LLM API providers can
check billing entitlement before runtime or backend work starts, so users are
guided back to `bus billing setup` when payment setup is missing.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-auth">bus auth</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-api-provider-billing">bus api provider billing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-api-provider-billing](./bus-api-provider-billing)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
