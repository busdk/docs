---
title: bus billing — billing setup and status
description: bus billing helps end users set up and manage provider-neutral Bus billing.
---

## `bus billing` — billing setup and status

`bus billing` is the end-user command for paid Bus services. It shows whether
the current account has billing enabled, opens the hosted payment setup flow,
and opens the hosted billing portal for payment method and invoice management.

The command is provider-neutral. A deployment may use Stripe, another payment
provider, or a local provider behind the Billing API. End users do not need to
know which provider is used; they interact with Bus account, billing, and API
tokens.

### Commands

`bus billing status` shows billing state, enabled paid features, current usage
quota state, and any setup or upgrade guidance returned by the server. If
billing is missing, it prints the next command to run. If a quota is exhausted,
it preserves the JSON quota details and prints upgrade guidance with the
recommended plan when one is available.

`bus billing setup` creates a hosted billing setup URL and prints it. The URL
may point to Stripe Checkout or another provider-hosted setup page depending on
deployment configuration. Open the URL in a browser, complete the provider
flow, and then rerun `bus billing status`.

`bus billing portal` creates a hosted billing portal URL for managing payment
methods, invoices, and subscriptions. The exact portal UI is controlled by the
payment provider configured by the deployment.

The end-user CLI intentionally does not expose catalog, admin, Stripe, or
product configuration commands. Operator workflows use modules such as
`bus operator billing` and `bus operator stripe`.

### Common Flow

Start with the normal Bus account flow:

```sh
bus auth register --email user@example.com
bus auth login --email user@example.com
bus auth verify --email user@example.com --otp 123456
bus auth status
```

After the account is approved, request a billing setup token and open the
hosted setup page:

```sh
bus auth token --scope "billing:read billing:setup"
bus billing status
bus billing setup
```

After payment setup completes, request the feature token you need. For LLM API
access this is normally:

```sh
bus auth token --scope "llm:proxy billing:read"
```

Containers use container scopes and billing checks configured by the
deployment, for example:

```sh
bus auth token --scope "container:read container:run container:delete billing:read"
```

The exact scopes available to an end user are controlled by the auth provider
and account approval policy. Registration and email verification alone do not
grant paid API access.

### Options

`--help` and `--version` print command help or version information.

`--api-url <url>` selects the Billing API base URL. `--token-file <path>` reads
the bearer token from a file. `--timeout <duration>` sets the HTTP timeout.
`--output <file>` writes command output to a file and `--quiet` suppresses
normal output.

`setup --return-url <url>` and `portal --return-url <url>` pass the post-flow
return URL to the Billing API when creating hosted provider sessions.

### Credentials

By default, `bus billing` reads the normal Bus API token saved by `bus auth`
under the user config root, normally `~/.config/bus/auth/api-token`. If no
token exists, request a narrow billing setup token first:

```sh
bus auth token --scope "billing:read billing:setup"
```

If the token is expired or missing required billing scopes, `bus billing`
prints the same token command. If a paid feature such as LLM access returns
`billing_required`, the CLI prints the server-provided next command, normally
`bus billing setup`.

### Quotas And Upgrades

Paid plans can define multiple quota windows at the same time. A plan may have
minute, hour, day, week, month, and total limits for the same feature. The
server denies new billable work when any matching quota is exhausted and
returns `quota_exceeded` with the exhausted window and optional upgrade plan.

LLM and container providers check billing before starting expensive work. LLM
calls are denied before runtime wake-up or backend proxying. Container run
requests are denied before runner delegation. Usage that is accepted by the
providers is recorded for billing and quota counting through the usage and
billing integrations.

### Local Compose

The BusDK superproject `compose.yaml` exposes the local Billing API through
nginx at `http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}/api/v1/billing`.
The default local billing worker uses a deterministic local provider backend,
so `bus billing status`, `bus billing setup`, and `bus billing portal` exercise
the Bus billing API without contacting Stripe. Set
`BUS_LOCAL_BILLING_PROVIDER_BACKEND=events` when the local stack should route
provider calls through `bus-integration-stripe`.

### Security Notes

Do not pass bearer tokens on the command line. Use the default `bus auth`
session, `--token-file`, or deployment-managed environment variables. Command
arguments can be visible through shell history and process listings.

`bus billing` is caller-owned. It can only read or create hosted billing flows
for the account in the bearer token. Operator actions such as catalog updates,
cross-account status checks, and Stripe synchronization require internal
operator tools and internal-audience JWTs.

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
