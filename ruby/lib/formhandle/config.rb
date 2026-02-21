# frozen_string_literal: true

require "json"

module FormHandle
  module Config
    CONFIG_FILE = ".formhandle"

    def self.read
      path = File.join(Dir.pwd, CONFIG_FILE)
      return nil unless File.exist?(path)
      JSON.parse(File.read(path))
    rescue JSON::ParserError
      Output.warn("Could not parse #{CONFIG_FILE}. File may be corrupted.")
      nil
    end

    def self.write(config)
      path = File.join(Dir.pwd, CONFIG_FILE)
      File.write(path, JSON.pretty_generate(config) + "\n")
    end

    def self.resolve_endpoint(config, domain_flag = nil)
      domains = config.keys

      if domain_flag
        unless config.key?(domain_flag)
          Output.error("No endpoint found for domain '#{domain_flag}'.")
          Output.error("Available domains: #{domains.join(', ')}")
          exit 1
        end
        return { "domain" => domain_flag, "endpoint" => config[domain_flag] }
      end

      if domains.empty?
        Output.error('No endpoints configured. Run "formhandle init" first.')
        exit 1
      end

      if domains.length == 1
        d = domains.first
        return { "domain" => d, "endpoint" => config[d] }
      end

      Output.error("Multiple endpoints configured. Use --domain to select one:")
      domains.each { |d| Output.error("  #{d} → #{config[d]['handler_id'] || '?'}") }
      exit 1
    end

    def self.add_to_gitignore
      path = File.join(Dir.pwd, ".gitignore")
      if File.exist?(path)
        content = File.read(path)
        return if content.split("\n").any? { |l| l.strip == CONFIG_FILE }
        File.open(path, "a") { |f| f.write("\n#{CONFIG_FILE}\n") }
      else
        File.write(path, "#{CONFIG_FILE}\n")
      end
    end
  end
end
