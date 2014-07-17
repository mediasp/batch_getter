# coding: utf-8

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'batch_getter'

Conf::MSP_API.tap do |msp_api|
  puts msp_api
  run BatchGetter.new msp_api unless msp_api.empty?
end
