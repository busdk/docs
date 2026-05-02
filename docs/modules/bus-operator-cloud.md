---
title: bus operator cloud
description: bus operator cloud provides provider-neutral cloud lifecycle commands for Bus deployments.
---

## Cloud Operations

`bus operator cloud` manages cloud infrastructure through Bus cloud contracts.
It is provider-neutral: operators select a provider with `--provider`, an
environment file, or `BUS_CLOUD_PROVIDER`; provider-specific behavior is
implemented by integration modules such as `bus-integration-upcloud`.

Use `doctor` to check the cloud command surface, `plan` to compute a cloud
change plan, `apply` to reconcile cloud resources, and `status` to inspect the
current deployment. Before running a provider-backed plan, install the matching
cloud integration and verify it with `bus-integration-upcloud --events`. Put
the selected provider in `BUS_CLOUD_PROVIDER`, and keep provider credentials in
an operator-owned secret file referenced from the env file. For UpCloud
deployments, the provider is `upcloud` and the credential scope must allow the
intended network, VM, address, and DNS/PTR operations.

```sh
cd /path/to/deployment-repository
umask 077
: "${UPCLOUD_TOKEN:?export UPCLOUD_TOKEN with a token allowed to manage the target UpCloud resources}"
install -m 700 -d ./deploy ./local
printf '%s\n' "$UPCLOUD_TOKEN" > ./local/upcloud-token
git check-ignore -q ./local/upcloud-token || printf '%s\n' '/local/' >> .git/info/exclude
git check-ignore -q ./local/upcloud-token
cat > ./deploy/cloud.env <<'EOF'
BUS_DEPLOYMENT_ID=example-dev
BUS_CLOUD_PROVIDER=upcloud
BUS_UPCLOUD_TOKEN_FILE=./local/upcloud-token
BUS_CLOUD_ZONE=fi-hel2
BUS_CLOUD_NETWORK_NAME=example-dev-private
BUS_CLOUD_PROXY_NODE=proxy
BUS_CLOUD_INFERENCE_NODE=gpu
EOF
bus operator cloud doctor --provider upcloud
bus-integration-upcloud --events
bus operator cloud plan --env-file ./deploy/cloud.env
bus operator cloud status --env-file ./deploy/cloud.env
```

`doctor` succeeds with `ok: true` and a provider-neutral availability note.
`plan` returns `discover-provider`, `load-desired-cloud-state`, and
`compute-cloud-plan` actions; review this output before `apply`. `apply`
returns `apply-cloud-plan` after provider discovery and planning. `status`
returns a provider-neutral cloud status read.

```sh
bus operator cloud apply --env-file ./deploy/cloud.env
bus operator cloud status --env-file ./deploy/cloud.env
```

Run `apply` only after reviewing the `plan` output and confirming the target
deployment id and resource names. The follow-up `status` command must exit 0
and print JSON with `"ok": true`, `"provider": "upcloud"`, and
`"read-cloud-status"` in the action list before the deployment flow moves on to
node bootstrap.

Decommissioning is separate:
`bus operator cloud destroy --env-file ./deploy/cloud.env --confirm <deployment-id>`
deletes resources for the exact deployment id from the reviewed plan or status
output.

The command is intended for bootstrap and operator troubleshooting. In a
running Bus deployment, the matching service surface is
`bus-api-provider-cloud`, which exposes cloud operations through Bus API and
Events paths.

### Sources

- [bus-api-provider-cloud](./bus-api-provider-cloud)
- [bus-integration-cloud](./bus-integration-cloud)
- [bus-integration-upcloud](./bus-integration-upcloud)
- [bus operator deploy](./bus-operator-deploy)
