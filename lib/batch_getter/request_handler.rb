require 'batch_getter/action/post_parser'
require 'batch_getter/action/resource_getter'
require 'batch_getter/action/resources_getter'
require 'batch_getter/action/response_creator'
require 'batch_getter/action/cookie_parser'

module BatchGetter
  # request handler
  class RequestHandler
    def initialize(config, env)
      @request = Rack::Request.new(env)
      @config = config
      @headers = env.select { |key, _value| /^HTTP_/.match(key) }
      @rest_client = RestClient::Resource.new(@config.api_endpoint)
    end

    def call
      paths = Action::PostParser.new(@request.body.read).call
      resources_getter = Action::ResourcesGetter.new(resource_getter, paths)
      body, cookies = resources_getter.call
      cookies = Action::CookieParser.new(cookies).call
      Action::ResponseCreator.new(body, cookies).call
    end

    private

    def resource_getter
      @resource_getter ||= proc do |path|
        Action::ResourceGetter.new(
          path, @headers, @rest_client,
          strict_error_codes: @config.strict_fail_codes).call
      end
    end
  end
end
