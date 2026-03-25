---
title: aiz — AI-assisted lossless compression with offline restore
description: aiz compresses one regular file into a .aiz archive with bounded AI-assisted planning, while unaiz restores the original bytes deterministically and offline.
---

## `aiz` and `unaiz` — single-file compression and offline restore

`aiz` is a standalone lossless compression toolchain that sits alongside the
BusDK module set. `aiz` writes `.aiz` archives, and `unaiz` restores the
original file bytes without requiring network access, AI access, or restore-time
heuristics.

Compression can use bounded local analysis and optional Codex-backed planning
hints, but restore stays deterministic and self-contained. In practice the tool
behaves like a familiar `gzip` and `gunzip` split for one regular file at a
time.

### Common tasks

```bash
make build
aiz note.txt
aiz --explain note.txt
aiz --no-ai --explain note.txt
aiz -o note.archive.aiz note.txt
unaiz note.txt.aiz
unaiz -C ./restore note.txt.aiz
```

### Synopsis

`aiz [flags] <input-file>`
`unaiz [flags] <archive.aiz>`

`aiz` accepts exactly one regular file and writes `<input>.aiz` beside that
file unless `-o` or `--output` is provided. `unaiz` accepts exactly one
archive, restores into the current working directory by default, and fails if
the target path already exists. Use `-C` or `--directory` when you want the
restored file written into a specific directory.

### Important flags

`aiz -o <file>` or `aiz --output <file>` writes the archive to an explicit
target path instead of `<input>.aiz`.

`aiz --family <name>` restricts candidate evaluation to named built-in codec or
rule families. The README positions this mainly as a debugging, measurement,
and development surface rather than the normal end-user path.

`aiz --search-budget {default|tight|generous}` selects how much bounded local
search the compressor will spend before it falls back to the best exact winner
it has found.

`aiz --no-ai` disables Codex-backed planning hints and keeps compression on the
deterministic local planning path only.

`aiz --explain` prints one stable summary line after a successful archive write,
and `aiz --explain-json` emits the same decision data as one JSON object. Use
those flags when you want to see which strategy, codec, and search-budget
profile won.

`unaiz -C <dir>` or `unaiz --directory <dir>` sets the restore directory.

### Command behavior

Successful normal runs are quiet. Help and version text go to standard output.
Usage errors exit `2`, and runtime failures such as invalid input type, invalid
archive metadata, or restore-target conflicts exit `1`.

The current archive format is `AIZ5`. The repository README documents backward
compatibility with earlier `.aiz` archive generations, and the restore path
remains offline because the archive stores the metadata `unaiz` needs to decode
it.

### Build and verification

Use `make build` to compile `./bin/aiz` and `./bin/unaiz`. The repository
README documents `make check`, `make test`, `make test-fuzz`, `make e2e`, and
`make e2e-examples` as the normal verification surfaces, together with corpus,
analysis, advice, and benchmark targets for deeper measurement work.

The current implementation is still described as experimental. The working CLI,
archive format, deterministic restore path, and measured corpus workflow are in
place, but the README still treats runtime search cost and general usefulness as
active areas of improvement.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus">bus</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIZ repository README](https://github.com/busdk/aiz/blob/main/README.md)
- [AIZ repository](https://github.com/busdk/aiz)
