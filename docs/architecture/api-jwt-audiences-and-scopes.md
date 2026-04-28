---
title: Bus API JWT audiences and scopes
description: Bus API JWT audiences separate end-user access from internal service and admin access.
---

## Overview

Bus APIs use short-lived JWTs with explicit audiences and space-separated scopes. The audience says which class of service may accept the token. The scope says which action family the token may perform inside that audience. A token is valid only when both match the receiving API.

The current Bus AI Platform audience values are `ai.hg.fi/api`, `ai.hg.fi/internal`, and `ai.hg.fi/auth`. If a deployment later renames these values, the same separation still applies: end-user API tokens must not become service or admin tokens by adding more scopes.

An end-user token for `ai.hg.fi/api` represents one approved account. The JWT `sub` is the stable `account_id`, not an email address. API providers derive ownership from `sub`; callers must not be able to choose another account by sending `account_id`, email, or tenant metadata in the request body. Any billable end-user action must record usage for the same `account_id`.

Service and admin operations use `ai.hg.fi/internal` or `ai.hg.fi/auth`, not normal end-user API tokens. Internal tokens are for trusted services, collectors, integrations, and operator automation. Auth-service tokens are for login status, token issuance, and waitlist administration inside the auth service.

## Audience `ai.hg.fi/api`

`ai.hg.fi/api` is the public end-user API audience. A token with this audience may be accepted only by APIs that an approved end user is allowed to call. It must not authorize reading other accounts, operating shared infrastructure outside an account boundary, collecting platform-wide billing data, or performing administrator maintenance.

The auth provider issues this audience only after email verification and admin approval. Registration and OTP verification alone do not issue API access. The default approved-user API scope set is configurable, but it should remain limited to end-user features such as AI model access, user-visible VM status, and user-owned container operations.

### Scope `llm:proxy`

`llm:proxy` allows an approved account to use the OpenAI-compatible `/v1/*` LLM proxy. The LLM provider validates the API audience, requires this scope, and requires `sub` to be the stable account UUID. Model execution requests record usage under that account.

`/v1/models` should normally be served from a configured catalog and should not wake GPU runtimes. Chat, completion, response, and embedding requests may wake the configured runtime before proxying and must record usage, missing-usage, failure, or abort events for billing.

### Scope `container:read`

`container:read` allows an approved account to read status for containers or runs that belong to that same account. The container provider passes the account identity from JWT `sub` to the backend and filters returned status items by owner before responding.

This scope must not expose global runner status or another customer's run output.

### Scope `container:run`

`container:run` allows an approved account to create a user-owned container run through the public containers API. The request must be stamped with the caller's `account_id`, and the provider must record requested, finished, or failed usage events for billing.

The integration that actually executes the run must preserve the owner account in its response. If the response says the run belongs to another account, the public provider must reject it.

### Scope `container:delete`

`container:delete` allows an approved account to delete or cancel a container run only when that run belongs to the same account. It does not authorize deleting the shared runner VM, runner storage, or another account's run.

Shared runner lifecycle operations use internal tokens and the `container:admin` scope.

### Scope `vm:read`

`vm:read` allows an approved account to read a user-visible VM or runtime status endpoint. This is appropriate for status that is safe to expose to end users and does not reveal another account's data, infrastructure secrets, or platform-wide capacity details.

### Scope `vm:write`

`vm:write` may be an end-user API scope only for an end-user-owned VM/runtime product where the action is billed to and isolated for the caller. It must not be granted to ordinary AI Platform users for shared GPU runtime orchestration.

When VM start/stop is used as internal AI runtime wake-up or platform maintenance, it belongs behind `ai.hg.fi/internal` service authorization or protected service-owned events. A deployment should not hand out `vm:write` in normal end-user API tokens unless the VM being controlled is owned by that end user.

### Scope `events:send`

`events:send` is a generic public Events API scope for unprotected application event names. It is not enough to publish protected Bus platform events such as VM, container, usage, or SSH events unless the Events API is explicitly configured for broad admin compatibility.

Production deployments should prefer domain scopes for protected events and should keep broad event publishing disabled for normal users.

### Scope `events:listen`

`events:listen` is a generic public Events API scope for unprotected event streams. It is not enough to subscribe to protected Bus platform event names, and wildcard streams are disabled by default because one token cannot safely prove access to every future event.

Event streams are account-filtered from JWT `sub`. A user listener must not receive events for another account.

### Scopes `work:send`, `work:read`, `work:reply`, and `work:claim`

These scopes apply to the generic `bus.work.*` event namespace. They are end-user or application scopes only when the work queue itself is account-scoped and safe for the caller. They do not imply platform administrator access.

`work:send` creates work items, `work:read` observes work events, `work:reply` publishes worker responses, and `work:claim` claims work. Deployments that use cross-account or operator work queues should protect those queues with internal tokens instead.

### Scopes `dev:task:send`, `dev:task:read`, `dev:task:reply`, and `dev:task:claim`

These scopes apply to the development task event namespace `bus.dev.task.*`. They follow the same account-isolation rules as work events. They are not AI Platform customer scopes unless a deployment intentionally exposes a development task feature to that customer.

## Audience `ai.hg.fi/internal`

`ai.hg.fi/internal` is the trusted service and operator audience. Tokens with this audience are not for normal end users. They should be issued only to backend jobs, internal API providers, integrations, collectors, and operator automation that run in trusted environments.

Internal APIs must still require scopes. The internal audience does not mean unrestricted access.

### Scope `usage:read`

`usage:read` allows an internal collector or billing job to list usage events. It can expose cross-account billing data and therefore belongs to `ai.hg.fi/internal`, not normal end-user API tokens.

### Scope `usage:delete`

`usage:delete` allows an internal collector or billing job to delete usage events after collection. It is a destructive maintenance permission and belongs only to internal tokens.

### Scope `usage:write`

`usage:write` allows a trusted provider or integration to record usage through the event system when that deployment uses event-based usage ingestion. End-user APIs should normally record their own usage through provider storage or send usage events with a service credential, not with the caller's token.

### Scope `container:admin`

`container:admin` controls shared container-runner lifecycle operations such as runner status, start, delete, and storage cleanup. It must use the internal audience. It is different from `container:run` and `container:delete`, which apply to user-owned runs.

### Scope `ssh:run`

`ssh:run` allows the SSH runner integration to execute scripts on configured hosts. This is service-level execution power and must not be granted to normal end users. Public container APIs may trigger a container run, but the SSH execution step must be performed by trusted integrations using service authorization.

### Internal `vm:write`

`vm:write` belongs to internal tokens when it controls shared AI runtime wake-up, provider-owned GPU servers, or operational VM lifecycle. The same literal scope can appear in a public end-user design only when the VM is an isolated end-user resource.

## Audience `ai.hg.fi/auth`

`ai.hg.fi/auth` is the auth-service audience. These tokens are accepted by the auth provider for login status, API token issuance, waitlist administration, and auth-service checks. They are not accepted by the LLM, VM, containers, usage, or Events APIs unless a deployment explicitly configures otherwise, which should be avoided.

### Scope `status:read`

`status:read` allows a verified user to check their auth-service registration and approval status. It does not authorize AI, VM, container, usage, or event access.

### Scope `token:issue`

`token:issue` allows a verified auth-service user to request an API token after the account has been approved. The auth provider must still enforce verified email, approved status, and the configured allow-list of end-user API scopes.

### Scope `waitlist:read`

`waitlist:read` allows an admin or operator to list waitlisted users. It exposes registration data and must not be part of normal user tokens.

### Scope `waitlist:approve`

`waitlist:approve` allows an admin or operator to approve or reject waitlisted users. Approval activates the stable `account_id` that later appears as `sub` in API tokens.

### Scope `admin:manage`

`admin:manage` is a broad auth-service administration scope. It must be kept out of normal user sessions and should be issued only to operator tooling or trusted admin workflows.

## Events API deployment rule

The Events API can serve both user-facing events and service integration events, but those are different trust zones. Public user-facing event routes may use `ai.hg.fi/api` with account filtering and domain scopes. Service integration routes that carry `usage:*`, `ssh:run`, `container:admin`, or shared runtime control should require `ai.hg.fi/internal` or be reachable only from trusted service networks with internal tokens.

Do not rely on caller-supplied event metadata for ownership. The Events API must stamp `account_id` from JWT `sub` and filter streams by that same value. Domain event scopes control which names a token may publish or receive; account filtering controls whose events the token may see.

## Billing rule

Every billable end-user action must create usage evidence tied to the caller's `account_id`. This includes LLM proxy requests, container runs, and end-user-owned VM lifecycle actions when enabled. If a provider cannot record required usage, it should fail safely instead of completing billable work without accounting.

Internal collectors read and delete usage with `ai.hg.fi/internal` tokens. End users should not receive `usage:read`, `usage:delete`, or platform-wide usage event streams.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./append-only-and-security">Append-only discipline and security model</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./architectural-overview">Architectural overview</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-api-provider-auth module documentation](../modules/bus-api-provider-auth)
- [bus-api-provider-containers module documentation](../modules/bus-api-provider-containers)
- [bus-api-provider-events module documentation](../modules/bus-api-provider-events)
- [bus-api-provider-llm module documentation](../modules/bus-api-provider-llm)
- [bus-api-provider-usage module documentation](../modules/bus-api-provider-usage)
- [bus-api-provider-vm module documentation](../modules/bus-api-provider-vm)
