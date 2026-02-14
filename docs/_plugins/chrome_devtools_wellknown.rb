# frozen_string_literal: true

require "securerandom"

# After the site is written: in development, write Chrome DevTools automatic-workspace
# JSON at /.well-known/appspecific/com.chrome.devtools.json so DevTools can discover
# the workspace when the site is served from localhost. In production, remove the file
# so it is never published. Root must be an absolute path; UUID must be stable across
# restarts (persisted in .jekyll-cache, which is gitignored). See:
# https://developer.chrome.com/docs/devtools/workspaces/
# https://developer.chrome.com/docs/devtools/automatic-workspaces/

module Jekyll
  class ChromeDevtoolsWellknownGenerator
    REL_PATH = ".well-known/appspecific/com.chrome.devtools.json"
    UUID_CACHE_BASENAME = "chrome-devtools-workspace-uuid"
    # SecureRandom.uuid in Ruby generates UUID v4 (RFC 4122).
    UUID_V4_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

    def self.uuid_cache_path(site)
      cache_dir = File.join(site.source, ".jekyll-cache")
      File.join(cache_dir, UUID_CACHE_BASENAME)
    end

    def self.read_or_create_uuid(site)
      path = uuid_cache_path(site)
      cache_dir = File.dirname(path)
      FileUtils.mkdir_p(cache_dir) unless Dir.exist?(cache_dir)
      if File.file?(path)
        uuid = File.read(path).strip
        uuid = SecureRandom.uuid unless uuid.match?(UUID_V4_REGEX)
        uuid
      else
        uuid = SecureRandom.uuid
        File.write(path, uuid)
        uuid
      end
    end

    def self.run(site)
      dest_path = File.join(site.dest, REL_PATH)
      dest_dir = File.dirname(dest_path)

      if Jekyll.env == "development"
        raw_root = ENV["CHROME_DEVTOOLS_WORKSPACE_ROOT"] || site.source
        root = File.expand_path(raw_root)
        uuid = read_or_create_uuid(site)
        payload = { "workspace" => { "root" => root, "uuid" => uuid } }
        FileUtils.mkdir_p(dest_dir)
        File.write(dest_path, JSON.pretty_generate(payload))
      else
        FileUtils.rm_f(dest_path)
      end
    end
  end
end

Jekyll::Hooks.register(:site, :post_write) do |site|
  Jekyll::ChromeDevtoolsWellknownGenerator.run(site)
end
