# bus-artifacts

`bus artifacts` manages local binary artifact catalog records. The catalog is
generic: it records artifact ids, local handles, source URLs, expected digests,
and optional checksum manifests without knowing what a given artifact means.
Modules such as Bus Engine decide how to use those artifacts.

Use `catalog set` instead of editing `.bus/artifacts/catalog.json` manually:

```sh
bus artifacts catalog set bus-engine-kernel-amd64 \
  --handle /path/to/linux-image-7.1.0_6_amd64.deb \
  --digest sha256:<expected-digest>
```

The command creates the catalog directory and file when needed, updates an
existing record when the id already exists, and keeps the JSON shape stable for
the artifact integration service.
