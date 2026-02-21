# frozen_string_literal: true

module FormHandle
  module Prompt
    def self.ask(question)
      print question
      $stdout.flush
      answer = $stdin.gets
      exit 1 if answer.nil?
      answer.strip
    end

    def self.confirm(question)
      answer = ask("#{question} (y/N) ")
      %w[y yes].include?(answer.downcase)
    end
  end
end
