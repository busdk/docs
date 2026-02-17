#!/usr/bin/env python3
"""Generate a machine-readable docs content index using git timestamps."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


DEFAULT_OUTPUT = "docs/assets/data/content-index.json"


def run_git(args: list[str]) -> str:
    proc = subprocess.run(
        ["git", *args],
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or "git command failed")
    return proc.stdout


def list_content_files() -> list[str]:
    tracked = run_git(["ls-files", "docs"]).splitlines()
    files: list[str] = []
    for path in tracked:
        if path == "docs/_config.yml":
            continue
        if path.startswith("docs/_"):
            continue
        files.append(path)
    return sorted(files)


def git_last_edits(paths: list[str]) -> dict[str, str]:
    if not paths:
        return {}

    output = run_git(["log", "--format=__TS__%cI", "--name-only", "--", *paths])
    remaining = set(paths)
    result: dict[str, str] = {}
    current_time = ""

    for raw_line in output.splitlines():
        line = raw_line.strip()
        if not line:
            continue

        if line.startswith("__TS__"):
            current_time = line.removeprefix("__TS__")
            continue

        if line in remaining:
            result[line] = current_time
            remaining.remove(line)
            if not remaining:
                break

    return result


def index_key(path: str) -> str:
    key = path.removeprefix("docs")
    if not key.startswith("/"):
        key = f"/{key.lstrip('/')}"
    if key.endswith(".md"):
        key = key[:-3]
    elif key.endswith(".html"):
        key = key[:-5]
    if key == "/index":
        return "/"
    if key.endswith("/index"):
        key = key[: -len("/index")]
    return key


def newer_timestamp(a: str, b: str) -> str:
    if not a:
        return b
    if not b:
        return a
    dt_a = datetime.fromisoformat(a)
    dt_b = datetime.fromisoformat(b)
    return a if dt_a >= dt_b else b


def build_payload(files: list[str], last_edits: dict[str, str]) -> dict[str, str]:
    payload: dict[str, str] = {
        "@generated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }
    for path in files:
        key = index_key(path)
        ts = last_edits.get(path, "")
        if key in payload:
            payload[key] = newer_timestamp(payload[key], ts)
        else:
            payload[key] = ts
    return payload


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate JSON index of docs content files from git history."
    )
    parser.add_argument(
        "--output",
        default=DEFAULT_OUTPUT,
        help=f"Output path (default: {DEFAULT_OUTPUT})",
    )
    args = parser.parse_args()

    try:
        files = list_content_files()
        last_edits = git_last_edits(files)
        payload = build_payload(files, last_edits)
    except RuntimeError as err:
        print(f"error: {err}", file=sys.stderr)
        return 1

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote index for {len(files)} files to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
