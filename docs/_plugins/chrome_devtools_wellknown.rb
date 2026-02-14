# frozen_string_literal: true

require "securerandom"

# After the site is written: in development, write Chrome DevTools workspace
# JSON with local root and stable UUID; in production, remove it so it is never published.
# See: https://developer.chrome.com/docs/devtools/workspaces/

module Jekyll
  class ChromeDevtoolsWellknownGenerator
    REL_PATH = ".well-known/appspecific/com.chrome.devtools.json"
    UUID_CACHE_BASENAME = "chrome-devtools-workspace-uuid"

    def self.uuid_cache_path(site)
      cache_dir = File.join(site.source, ".jekyll-cache")
      File.join(cache_dir, UUID_CACHE_BASENAME)
    end

    def self.read_or_create_uuid(site)
      path = uuid_cache_path(site)
      cache_dir = File.dirname(path)
      FileUtils.mkdir_p(cache_dir) unless Dir.exist?(cache_dir)
      if File.file?(path)
        File.read(path).strip
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
        root = ENV["CHROME_DEVTOOLS_WORKSPACE_ROOT"] || File.expand_path(site.source)
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
