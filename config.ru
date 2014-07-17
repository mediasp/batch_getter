# coding: utf-8

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'batch_getter'

if (prefix = Conf::COOKIE_REWRITE_PREFIX)
  require 'rack/cookie_rewrite'
  use Rack::CookieRewrite, prefix
end

api = Conf::API_ENDPOINT

if api && !api.empty?
  run BatchGetter.new api
else
  puts "Please define #{Conf::API_ENDPOINT_ENV_VAR}"
  exit
end
