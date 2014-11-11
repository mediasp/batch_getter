require 'test_helper'
require 'batch_getter/action/resources_getter'
require 'mocha/mini_test'

describe BatchGetter::Action::ResourcesGetter do
  let(:resource_getter) { mock }

  subject do
    BatchGetter::Action::ResourcesGetter.new(resource_getter, uris)
  end

  describe '#call' do
    let(:uris) { ['foo', 'bar'] }
    let(:foo) { { 'foo' => 1 } }
    let(:bar) { { 'bar' => 2 } }

    it 'returns the json from each uri in an array' do
      resource_getter.expects(:call).with('foo').returns([foo, {}])
      resource_getter.expects(:call).with('bar').returns([bar, {}])
      body, _cookies = subject.call

      assert_same foo, body.first
      assert_same bar, body.last
    end

    it 'sends back cookies from the last request' do
      resource_getter.expects(:call).with('foo').returns([foo, {}])
      resource_getter.expects(:call).with('bar')
        .returns([bar, { 'foo' => 'foo' }])
      body, cookies = subject.call

      assert_same foo, body.first
      assert_same bar, body.last

      assert_equal({ 'foo' => 'foo' }, cookies)
    end

    it 'combines cookies from all requests' do
      resource_getter.expects(:call).with('foo')
        .returns([foo, { 'foo' => 'foo' }])

      resource_getter.expects(:call).with('bar')
        .returns([bar, { 'bar' => 'bar' }])
      body, cookies = subject.call

      assert_same foo, body.first
      assert_same bar, body.last

      assert_equal({ 'foo' => 'foo', 'bar' => 'bar' }, cookies)
    end

    it 'last response over-rides previously set cookies' do
      resource_getter.expects(:call).with('foo')
        .returns([foo, { 'foo' => 'foo' }])

      resource_getter.expects(:call).with('bar')
        .returns([bar, { 'foo' => 'bar' }])
      body, cookies = subject.call

      assert_same foo, body.first
      assert_same bar, body.last

      assert_equal({ 'foo' => 'bar' }, cookies)
    end
  end
end
