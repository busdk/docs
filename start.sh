#!/usr/bin/env bash
# Start the Jekyll docs site locally. Ensures rbenv is active so the right Ruby
# (see .ruby-version) and gems are used. Run from the repo root or any subdir.

set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$ROOT"

# Enable rbenv so .ruby-version is respected.
if [[ -d "${RBENV_ROOT:-$HOME/.rbenv}/bin" ]]; then
  export PATH="${RBENV_ROOT:-$HOME/.rbenv}/bin:$PATH"
fi
if command -v rbenv >/dev/null 2>&1; then
  # rbenv init can return non-zero in restricted shells when rehash fails.
  # Keep startup resilient and continue with the current Ruby in PATH.
  set +e
  eval "$(rbenv init -)"
  rbenv_init_status=$?
  set -e
  if [[ $rbenv_init_status -ne 0 ]]; then
    echo "Warning: rbenv init failed; continuing with current Ruby environment." >&2
  fi
fi

# Keep gem installs inside the repository to avoid mutating shared rbenv gems.
export BUNDLE_PATH="${BUNDLE_PATH:-vendor/bundle}"
export BUNDLE_BIN="${BUNDLE_BIN:-vendor/bundle/bin}"
export BUNDLE_DISABLE_SHARED_GEMS=true

# Install gems only when required by the current Bundler environment.
if ! bundle check >/dev/null 2>&1; then
  echo "Installing gems..."
  bundle install
fi

# Development env: Chrome DevTools workspace .well-known is written with local root
# and stable UUID (not published in production), and Sass emits source maps so
# DevTools can map compiled CSS back to .scss sources.
export JEKYLL_ENV=development

exec bundle exec jekyll serve -s docs "$@"
