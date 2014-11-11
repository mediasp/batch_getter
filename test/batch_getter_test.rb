require 'test_helper'
require 'rack/test'
require 'webmock/minitest'
require 'mocha/mini_test'
require 'batch_getter'

describe BatchGetter do
  include Rack::Test::Methods

  def app
    BatchGetter
  end

  let(:config) do
    mock.tap do |conf|
      conf.stubs(:api_endpoint).returns('www.example.com')
    end
  end

  before do
    app.stubs(:config).returns(config)
  end

  it 'should return array of JSON' do
    stub_request(:get, 'www.example.com/foo')
      .to_return(body: { foo: :foo }.to_json)
    stub_request(:get, 'www.example.com/bar')
      .to_return(body: { bar: :bar }.to_json)

    post('/', ['foo', 'bar'].to_json)

    assert_equal([{'foo' => 'foo'}, {'bar' => 'bar'}].to_json,
                 last_response.body)
  end

  # it 'should return nil if any response isnt JSON' do
  #   stub_request(:get, 'www.example.com/foo')
  #     .to_return(body: { foo: :foo }.to_json)
  #   stub_request(:get, 'www.example.com/bar')
  #     .to_return(body: 'bar')

  #   post('/', ['foo', 'bar'].to_json)

  #   assert_equal([{'foo' => 'foo'}, nil].to_json,
  #                last_response.body)
  # end

  it 'should pass back a set-cookie from the last request' do
    stub_request(:get, 'www.example.com/foo')
      .to_return(body: { foo: :foo }.to_json)
    stub_request(:get, 'www.example.com/bar')
      .to_return(body: { bar: :bar }.to_json,
                 headers: { set_cookie: %w(foo=foo) })

    post('/', ['foo', 'bar'].to_json)

    assert_equal([{'foo' => 'foo'}, {'bar' => 'bar'}].to_json,
                 last_response.body)
    assert_equal 'foo', rack_mock_session.cookie_jar['foo']
  end

  it 'should pass back a set-cookie from any request' do
    stub_request(:get, 'www.example.com/foo')
      .to_return(body: { foo: :foo }.to_json,
                 headers: { set_cookie: %w(foo=foo) })
    stub_request(:get, 'www.example.com/bar')
      .to_return(body: { bar: :bar }.to_json,
                 headers: { set_cookie: %w(bar=bar) })

    post('/', ['foo', 'bar'].to_json)

    assert_equal 'foo', rack_mock_session.cookie_jar['foo']
    assert_equal 'bar', rack_mock_session.cookie_jar['bar']
  end

  it 'should use the last set-cookie if there are conflicts' do
    stub_request(:get, 'www.example.com/foo')
      .to_return(body: { foo: :foo }.to_json,
                 headers: { set_cookie: %w(foo=foo) })
    stub_request(:get, 'www.example.com/bar')
      .to_return(body: { bar: :bar }.to_json,
                 headers: { set_cookie: %w(foo=bar) })

    post('/', ['foo', 'bar'].to_json)

    assert_equal 'bar', rack_mock_session.cookie_jar['foo']
  end
end
