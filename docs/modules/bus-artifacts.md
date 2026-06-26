# bus-artifacts

`bus artifacts` manages local binary artifact catalog records. The catalog is
generic: it records artifact ids, local handles, source URLs, expected digests,
and optional checksum manifests without knowing what a given artifact means.
Modules such as Bus Engine decide how to use those artifacts.

Choose an artifact id that is stable within the workspace, point `--handle` at
the local file, and pass the expected digest in `sha256:<hex>` form. For a local
file, compute the SHA-256 digest before writing the catalog record. `--handle`
records the local path rather than copying the artifact, so the file must remain
accessible to later consumers.

```sh
KERNEL=/path/to/bus-engine-os/build/lanes/bootstrap/images/Image
KERNEL_DIGEST="sha256:$(openssl dgst -sha256 -r "$KERNEL" | awk '{print $1}')"

bus artifacts catalog set bus-engine-os-kernel-aarch64 \
  --handle "$KERNEL" \
  --digest "$KERNEL_DIGEST"
```

The command creates the catalog directory and file when needed, updates an
existing record when the id already exists, and keeps the JSON shape stable for
the artifact integration service.

Confirm the record with:

```sh
bus artifacts catalog inspect bus-engine-os-kernel-aarch64
```
