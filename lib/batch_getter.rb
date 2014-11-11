# coding: utf-8

require 'json'
require 'confuse'

require 'batch_getter/action/post_parser'
require 'batch_getter/action/resource_getter'
require 'batch_getter/action/resources_getter'
require 'batch_getter/action/response_creator'

CONFIG_FILE = if ENV['RACK_ENV'] == 'production'
                '/etc/batch_getter/config.ini'
              else
                ENV['BG_CONFIG_LOCATION']
              end

# Batch getter
module BatchGetter
  class << self
    def call(env)
      RequestHandler.new(config.api_endpoint, env).call
      # rescue => error
      #   [500, { 'Content-Type' => 'application/json' },
      #    Array({ error: 500, message: error }.to_json)]
    end

    private

    def config(location: CONFIG_FILE)
      @config ||= Confuse.config path: location do |conf|
        conf.add_item :api_endpoint, description: 'API to batch requests to.',
                                     type: String

        conf.add_item :strict_fail_codes,
                      default: [], type: Array,
                      description: 'Fail the whole request if one of these '\
                      'error codes is received (otherwise, the '\
                      'error message is included in the JSON data)'
      end
    end
  end

  # request handler
  class RequestHandler
    def initialize(api, env)
      @request = Rack::Request.new(env)
      @headers = env.select { |key, _value| /^HTTP_/.match(key) }
      @rest_client = RestClient::Resource.new(api)
    end

    def call
      paths = Action::PostParser.new(@request.body.read).call
      resources_getter = Action::ResourcesGetter.new(resource_getter, paths)
      body, cookies = resources_getter.call
      cookies = parse_cookies(cookies)
      Action::ResponseCreator.new(body, cookies).call
    end

    private

    def resource_getter
      @resource_getter ||= proc do |path|
        Action::ResourceGetter.new(path, @headers, @rest_client).call
      end
    end

    def parse_cookies(cookies)
      cookies.map { |cookie| cookie.join('=') }
    end
  end
end
