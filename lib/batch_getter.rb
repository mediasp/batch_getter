# coding: utf-8

require 'json'
require 'rest_client'
require 'confuse'

CONFIG_FILE = if ENV['RACK_ENV'] == 'production'
                '/etc/batch_getter/config.ini'
              else
                ENV['BG_CONFIG_LOCATION']
              end

# Batch getter
class BatchGetter
  def initialize(site: config.api_endpoint)
    @site = RestClient::Resource.new site
  end

  def config(location: CONFIG_FILE)
    @config ||= Confuse.config path: location do |conf|
      conf.add_item :api_endpoint, description: 'API to batch requests to.',
                                   type: String

      conf.add_item :strict_fail_codes,
                    type: Array,
                    description: 'Fail the whole request if one of these '\
                                 'error codes is received (otherwise, the '\
                                 'error message is included in the JSON data).',
                    default: []
    end
  end

  def response(code, body)
    [code, { 'Content-Type' => 'application/json' }, Array(body)]
  end

  def error(code = 400, message = '')
    response(code, { error: code, message: message }.to_json)
  end

  def get(path)
    @site[path].get @headers.merge(accepts: 'application/json')
  rescue RestClient::Exception => e
    raise e if  config.strict_fail_codes.include?(e.http_code)
    # Expects that the server returns JSON error messages.
    e.http_body
  end

  def headers(env)
    env.reduce({}) do |m, (k, v)|
      md = /HTTP_(.*)/.match k
      md ? m.merge(md[1].downcase.to_sym => v) : m
    end
  end

  def parse_body(body)
    case body
    when /^[\[\{]/
      JSON.parse(body)
    else
      JSON.parse("[#{body}]").first
    end
  end

  def post(env)
    body = @request.body.read
    json = JSON.parse(body)
    body = json.map { |path| (response = get path) && parse_body(response) }
    .to_json
    response(200, body)
  rescue RestClient::Exception => e
    response(e.http_code, e.http_body)
  end

  def call(env)
    @request = Rack::Request.new(env)
    @response = Rack::Response.new(env)
    @headers = headers(env)
    if @request.post?
      post(env)
    else
      error(405, 'expects POST')
    end
  rescue => e
    error(500, e)
  end
end
