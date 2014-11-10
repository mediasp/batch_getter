# coding: utf-8

require 'json'
require 'confuse'

require 'action/post_parser'
require 'action/resource_getter'
require 'action/resources_getter'
require 'action/response_creator'

CONFIG_FILE = if ENV['RACK_ENV'] == 'production'
                '/etc/batch_getter/config.ini'
              else
                ENV['BG_CONFIG_LOCATION']
              end

# Batch getter
module BatchGetter
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

  class << self
    def call(env)
      handle_request(env)
    rescue => error
      [500, { 'Content-Type' => 'application/json' },
       Array({ error: 500, message: error }.to_json)]
    end

    private

    def post_parser
      proc { |data| Action::PostParser.new(config.api_endpoint, data).call }
    end

    def resource_getter(headers)
      proc do |uri|
        Action::ResourceGetter.new(headers, cookie_jar, uri,
                                   strict_error_codes: config.strict_fail_codes)
          .call
      end
    end

    def resources_getter(headers, uris)
      Action::ResourcesGetter.new(resource_getter(headers), uris)
    end

    def resonse_creator(body)
      Action::ResponseCreator.new(cookie_jar, body)
    end

    def handle_request(env)
      request = Rack::Request.new(env)
      uris = post_parser.call(request.body.read)
      resources_getter = resource_getter(request.headers, uris)
      body = resources_getter.call
      response_creator(body).call
    end
  end
end
