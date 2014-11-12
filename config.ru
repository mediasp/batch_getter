# coding: utf-8

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'batch_getter'

require 'rack/cookie_rewrite'

use Rack::CookieRewrite, 'MSP'
run BatchGetter
