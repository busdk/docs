---
title: bus operator deploy
description: bus operator deploy coordinates Bus deployment bootstrap, apply, render, and verification workflows.
---

## Deployment Orchestration

`bus operator deploy` is the operator-facing controller for installing and
updating a Bus deployment. It coordinates focused operator families for cloud,
database, node, inference, billing, Stripe, service rendering, and verification.
Provider-specific work stays behind provider-neutral modules such as
`bus operator cloud`, `bus operator database`, `bus operator node`, and
`bus operator inference`.

Use `doctor` before a bootstrap or apply run to check that required inputs and
credentials are present. Use `plan` to inspect the deployment phases before
changing infrastructure. `bootstrap` prepares a new deployment from local
operator inputs, while `apply` reconciles the deployment through the same
provider-neutral contracts used by a running Bus system. `render systemd` and
`render nginx` produce service-manager and reverse-proxy configuration. `verify`
checks the deployed service routes and runtime readiness.

Create `./deploy/bus.env` as an operator-owned local file with mode `0600`.
The minimal shared keys are `BUS_DEPLOYMENT_ID`, `BUS_CLOUD_PROVIDER`,
`BUS_DATABASE_PROVIDER`, `BUS_INFERENCE_PROVIDER`, and the credential-file
references required by the focused modules, such as an UpCloud token file,
PostgreSQL admin DSN file, Stripe API key file, internal Bus key file, and SSH
key file. The focused module pages document the exact provider-specific
variables. `doctor` succeeds with `ok: true` and named validation phases.
`plan` succeeds with cloud, database, node, inference, and service phases.
Run mutating `bootstrap` or `apply` only after reviewing the plan.

```sh
umask 077
install -m 700 -d ./deploy ./local
# Populate these files from your secret manager before running doctor:
# ./local/upcloud-token contains the UpCloud API token.
# ./local/postgres-admin-dsn contains the PostgreSQL admin DSN.
# ./local/id_ed25519 contains the SSH private key.
# ./local/stripe-secret-key contains the Stripe secret key.
# ./local/bus-internal-key contains the Bus internal shared key.
cat > ./deploy/bus.env <<'EOF'
BUS_DEPLOYMENT_ID=example-dev
BUS_CLOUD_PROVIDER=upcloud
BUS_UPCLOUD_TOKEN_FILE=./local/upcloud-token
BUS_DATABASE_PROVIDER=postgres
BUS_POSTGRES_ADMIN_DSN_FILE=./local/postgres-admin-dsn
BUS_INFERENCE_PROVIDER=ollama
BUS_SSH_PRIVATE_KEY_FILE=./local/id_ed25519
BUS_STRIPE_API_KEY_FILE=./local/stripe-secret-key
BUS_INTERNAL_KEY_FILE=./local/bus-internal-key
EOF
bus operator deploy doctor --env-file ./deploy/bus.env
bus operator deploy plan --env-file ./deploy/bus.env
```

Stop after `plan` and review the printed cloud, database, node, inference, and
service phases. For a first install, run bootstrap once before apply:

```sh
bus operator deploy bootstrap --env-file ./deploy/bus.env
bus operator deploy apply --env-file ./deploy/bus.env
```

For an existing deployment update, skip bootstrap and run only:

```sh
bus operator deploy apply --env-file ./deploy/bus.env
```

Render service configuration as a separate step. Review the generated output,
install it with your host configuration process, then reload systemd or nginx
before running `verify`. The install example below assumes a Linux host with
systemd and Debian-style nginx `sites-available` and `sites-enabled`
directories.

```sh
bus operator deploy render systemd --env-file ./deploy/bus.env > ./deploy/bus-systemd.generated
bus operator deploy render nginx --env-file ./deploy/bus.env > ./deploy/bus-nginx.generated
sudo install -m 0644 ./deploy/bus-systemd.generated /etc/systemd/system/bus-api.service
sudo install -m 0644 ./deploy/bus-nginx.generated /etc/nginx/sites-available/bus
sudo ln -sf /etc/nginx/sites-available/bus /etc/nginx/sites-enabled/bus
sudo systemctl daemon-reload
sudo systemctl restart bus-api.service
sudo nginx -t
sudo systemctl reload nginx
bus operator deploy verify --env-file ./deploy/bus.env
```

The command reads env-style input files with `KEY=VALUE` or
`export KEY=VALUE` lines. Keep real credentials in local untracked files or a
secret manager and pass only file references where supported by the focused
operator family. Render commands write their generated plan to stdout unless a
focused renderer adds an explicit output flag; they do not modify
`/etc/systemd/system` or nginx live configuration by themselves. A successful
`verify` returns `ok: true` with service, route, billing, and inference phases.
If verification fails, run the matching focused command first, for example
`bus operator cloud status`, `bus operator database verify`,
`bus operator node verify`, or `bus operator inference verify`.

### Sources

- [bus operator cloud](./bus-operator-cloud)
- [bus operator database](./bus-operator-database)
- [bus operator node](./bus-operator-node)
- [bus operator inference](./bus-operator-inference)
- [bus operator](./bus-operator)
