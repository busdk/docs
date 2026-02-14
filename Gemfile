# BusDK docs: Jekyll 4 + Ruby 3.3.
# Use: bundle install && bundle exec jekyll serve -s docs

source "https://rubygems.org"

ruby "~> 3.3.0"

gem "jekyll", "~> 4.4"
gem "jekyll-theme-primer", "~> 0.6"
gem "faraday-retry" # used by jekyll-github-metadata (Faraday v2+)
gem "kramdown"
gem "nokogiri" # required by docs/_plugins/busdk_chapters.rb
# Required for `jekyll serve` on Ruby 3.x (webrick removed from stdlib).
gem "webrick"
