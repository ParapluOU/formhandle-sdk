# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module FormHandle
  module Api
    BASE_URL = "https://api.formhandle.dev"
    AD_KEYS = %w[_ad1 _ad2 _ad3 _ad4 _ad5 _docs _tip].freeze

    def self.strip_ads(data)
      return data unless data.is_a?(Hash)
      data.reject { |k, _| AD_KEYS.include?(k) }
    end

    def self.get(path)
      uri = URI("#{BASE_URL}#{path}")
      req = Net::HTTP::Get.new(uri)
      req["Accept"] = "application/json"
      perform(uri, req)
    end

    def self.post(path, body, headers = {})
      uri = URI("#{BASE_URL}#{path}")
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      headers.each { |k, v| req[k] = v }
      req.body = JSON.generate(body)
      perform(uri, req)
    end

    def self.perform(uri, req)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      resp = http.request(req)
      data = begin
        JSON.parse(resp.body)
      rescue JSON::ParserError
        { "raw" => resp.body }
      end
      { "status" => resp.code.to_i, "data" => strip_ads(data) }
    rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout => e
      Output.error("Could not connect to FormHandle API: #{e.message}")
      exit 1
    end
  end
end
