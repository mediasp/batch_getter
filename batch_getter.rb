# coding: utf-8

require 'json'
require 'rest_client'

# module for storing configuration
module Conf
  API_ENDPOINT_ENV_VAR = 'BG_API_ENDPOINT'
  API_ENDPOINT = ENV[API_ENDPOINT_ENV_VAR]

  # If we get one of these error codes, we will fail the whole request,
  # otherwise we get the error as part of the JSON data.
  STRICT_FAIL_CODES = (ENV['STRICT_FAIL_CODES'] || '').split(',').map(&:to_i)
end

# Batch getter
class BatchGetter
  def initialize(site)
    @site = RestClient::Resource.new site
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
    raise e if  Conf::STRICT_FAIL_CODES.include?(e.http_code)
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
