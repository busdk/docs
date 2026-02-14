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
  eval "$(rbenv init -)"
fi

# Install gems if needed.
if [[ ! -f Gemfile.lock ]] || [[ ! -d vendor/bundle ]]; then
  echo "Installing gems..."
  bundle install
fi

# Development env: Chrome DevTools workspace .well-known is written with local root
# and stable UUID (not published in production), and Sass emits source maps so
# DevTools can map compiled CSS back to .scss sources.
export JEKYLL_ENV=development

exec bundle exec jekyll serve -s docs "$@"
