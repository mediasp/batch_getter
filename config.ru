# coding: utf-8

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'batch_getter'

api = Conf::API_ENDPOINT

if api && !api.empty?
  run BatchGetter.new api
else
  raise "Please define #{Conf::API_ENDPOINT_ENV_VAR}"
end
