# coding: utf-8

require 'json'
require 'rest_client'

# module for storing configuration
module Conf
  API_ENDPOINT_ENV_VAR = 'BG_API_ENDPOINT'
  API_ENDPOINT = ENV[API_ENDPOINT_ENV_VAR]

  COOKIE_REWRITE_PREFIX = ENV['COOKIE_REWRITE_PREFIX']
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
    @site[path].get @headers
  rescue RestClient::Exception => e
    # Expects that the server returns JSON error messages.
    e.http_body
  end

  def headers(env)
    env.reduce({}) do |m, (k, v)|
      md = /HTTP_(.*)/.match k
      md ? m.merge(md[1].downcase.to_sym => v) : m
    end
  end

  def post(env)
    body = @request.body.read
    json = JSON.parse(body)
    body = json.map { |path| (response = get path) && JSON.parse(response) }
    .to_json
    response(200, body)
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
