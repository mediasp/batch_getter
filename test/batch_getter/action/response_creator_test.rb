require 'test_helper'
require 'batch_getter/action/response_creator'

describe BatchGetter::Action::ResponseCreator do
  describe '#call' do
    let(:cookie) { '' }
    let(:body) { [ { foo: 1 }, { bar: 2 } ] }

    subject do
      BatchGetter::Action::ResponseCreator.new(body, cookie).call
    end

    describe 'no cookie' do
      it 'has a 200 response code' do
        assert_equal 200, subject.first
      end

      it 'sends set-cookie header' do
        refute_includes subject[1], 'Set-Cookie'
      end

      it 'sends content-type header' do
        assert_equal 'application/json', subject[1]['Content-Type']
      end

      it 'sends back the body' do
        assert_equal [body.to_json], subject.last
      end
    end

    describe 'with set-cookie' do
      let(:cookie) { 'foo=1;bar=1' }

      it 'has a 200 response code' do
        assert_equal 200, subject.first
      end

      it 'sends set-cookie header' do
        assert_equal cookie, subject[1]['Set-Cookie']
      end

      it 'sends content-type header' do
        assert_equal 'application/json', subject[1]['Content-Type']
      end

      it 'sends back the body' do
        assert_equal [body.to_json], subject.last
      end
    end
  end
end
