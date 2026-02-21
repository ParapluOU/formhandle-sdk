# frozen_string_literal: true

require "json"

module FormHandle
  module Output
    NO_COLOR = ENV.key?("NO_COLOR")

    RESET  = NO_COLOR ? "" : "\033[0m"
    BOLD   = NO_COLOR ? "" : "\033[1m"
    RED    = NO_COLOR ? "" : "\033[31m"
    GREEN  = NO_COLOR ? "" : "\033[32m"
    YELLOW = NO_COLOR ? "" : "\033[33m"
    BLUE   = NO_COLOR ? "" : "\033[34m"
    CYAN   = NO_COLOR ? "" : "\033[36m"
    GRAY   = NO_COLOR ? "" : "\033[90m"

    def self.success(msg)
      puts "#{GREEN}\u2714#{RESET} #{msg}"
    end

    def self.error(msg)
      $stderr.puts "#{RED}\u2716#{RESET} #{msg}"
    end

    def self.info(msg)
      puts "#{BLUE}\u2139#{RESET} #{msg}"
    end

    def self.warn(msg)
      puts "#{YELLOW}\u26a0#{RESET} #{msg}"
    end

    def self.dim(msg)
      "#{GRAY}#{msg}#{RESET}"
    end

    def self.bold(msg)
      "#{BOLD}#{msg}#{RESET}"
    end

    def self.heading(msg)
      puts "\n#{BOLD}#{CYAN}#{msg}#{RESET}\n\n"
    end

    def self.json(data)
      puts JSON.pretty_generate(data)
    end

    def self.table(rows)
      return if rows.empty?
      max_key = rows.map { |k, _| k.length }.max
      rows.each do |key, val|
        puts "  #{bold(key.ljust(max_key))}  #{val}"
      end
    end
  end
end
