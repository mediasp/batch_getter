require 'test_helper'
require 'batch_getter/action/response_creator'
require 'mocha/mini_test'

describe BatchGetter::Action::ResponseCreator do
  describe '#call' do
    let(:cookie_jar) do
      mock.tap do |cookie_jar|
        cookie_jar.expects(:cookie_string).returns('foo=1')
      end
    end

    let(:body) do
      [ { foo: 1 }, { bar: 2 } ]
    end

    subject do
      BatchGetter::Action::ResponseCreator.new(cookie_jar, body)
    end

    it 'returns a rack compatible response' do
      response = subject.call

      assert_equal 200, response.first
      assert_equal [body.to_json], response.last
    end
  end
end
