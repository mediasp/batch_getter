require 'test_helper'
require 'batch_getter/action/resources_getter'
require 'mocha/mini_test'

describe BatchGetter::Action::ResourcesGetter do
  let(:resource_getter) { mock }
  subject { BatchGetter::Action::ResourcesGetter.new(resource_getter, uris) }

  describe '#call' do
    let(:uris) { ['foo', 'bar'] }
    let(:foo) { { 'foo' => 1 } }
    let(:bar) { { 'bar' => 2 } }

    it 'returns the json from each uri in an array' do
      resource_getter.expects(:call).with('foo').returns(foo)
      resource_getter.expects(:call).with('bar').returns(bar)
      response = subject.call

      assert_same foo, response.first
      assert_same bar, response.last
    end
  end
end
