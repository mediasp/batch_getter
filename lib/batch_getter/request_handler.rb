require 'batch_getter/action/post_parser'
require 'batch_getter/action/resource_getter'
require 'batch_getter/action/resources_getter'
require 'batch_getter/action/response_creator'

module BatchGetter
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
