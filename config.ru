# coding: utf-8

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'batch_getter'

api = Conf::API_ENDPOINT

if api && !api.empty?
  run BatchGetter.new api
else
  puts "Please define #{Conf::API_ENDPOINT_ENV_VAR}"
  exit
end
