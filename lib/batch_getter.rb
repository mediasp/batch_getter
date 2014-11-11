# coding: utf-8

require 'json'
require 'confuse'

require 'batch_getter/request_handler'

CONFIG_FILE = if ENV['RACK_ENV'] == 'production'
                '/etc/batch_getter/config.ini'
              else
                ENV['BG_CONFIG_LOCATION']
              end

# Batch getter
module BatchGetter
  class << self
    def call(env)
      RequestHandler.new(config, env).call
    rescue Action::ResourceGetter::Error => error
      [error.status, { 'Content-Type' => 'application/json' }, %w()]
    rescue => error
      [500, { 'Content-Type' => 'application/json' },
       Array({ error: 500, message: error }.to_json)]
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
end
