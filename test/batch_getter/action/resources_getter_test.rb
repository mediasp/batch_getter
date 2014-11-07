require 'test_helper'
require 'batch_getter/action/resources_getter'
require 'mocha/mini_test'

describe BatchGetter::Action::ResourcesGetter do
  let(:resource_getter) { mock }
  let(:cookie_jar) do
    mock.tap do |cookie_jar|
      cookie_jar.stubs(:cookies).returns([])
    end
  end

  subject do
    BatchGetter::Action::ResourcesGetter.new(cookie_jar, resource_getter, uris)
  end

  describe '#call' do
    let(:uris) { ['foo', 'bar'] }
    let(:foo) { { 'foo' => 1 } }
    let(:bar) { { 'bar' => 2 } }

    it 'returns the json from each uri in an array' do
      resource_getter.expects(:call).with('foo', []).returns(foo)
      resource_getter.expects(:call).with('bar', []).returns(bar)
      response = subject.call

      assert_same foo, response.first
      assert_same bar, response.last
    end

    describe 'first response returns set-cookie header' do
      let(:cookie_jar) do
        mock.tap do |cookie_jar|
          cookie_jar.stubs(:cookies).returns([], ['foo'])
        end
      end

      it 'sends cookie from previous request to next request' do
        resource_getter.expects(:call).with('foo', []).returns(foo)
        resource_getter.expects(:call).with('bar', ['foo']).returns(bar)

        subject.call
      end
    end
  end
end
