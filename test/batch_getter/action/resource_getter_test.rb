require 'test_helper'
require 'batch_getter/action/resource_getter'
require 'webmock/minitest'
require 'mocha/mini_test'

describe BatchGetter::Action::ResourceGetter do
  let(:uri) { 'www.example.com' }
  let(:body) { %w({"foo": "bar", "bar": "baz"}) }
  let(:status) { 200 }
  let(:strict_error_codes) { [] }
  let(:cookie_jar) { mock }
  let(:headers) { {} }

  before do
    stub_request(:get, uri)
      .to_return(body: body, status: status, headers: headers)
  end

  subject do
    BatchGetter::Action::ResourceGetter.new(cookie_jar, "http://#{uri}/",
                                            strict_error_codes: strict_error_codes)
  end

  describe '#call' do
    describe 'URL returns JSON' do
      it 'returns the data as a JSON object' do
        response = subject.call
        assert_equal 'bar', response['foo']
        assert_equal 'baz', response['bar']
      end
    end

    describe 'URL error codes' do
      let(:status) { 401 }
      let(:body) { 'please log in' }

      it 'returns the error as a JSON string' do
        response = subject.call

        assert_equal 401, response['status']
        assert_equal 'please log in', response['message']
      end

      describe 'strict error codes' do
        let(:strict_error_codes) { [401] }

        it 'raises an error' do
          assert_raises(BatchGetter::Action::ResourceGetter::Error) do
            subject.call
          end
        end
      end
    end

    describe 'URL returns set-cookie' do
      let(:headers) { { 'Set-Cookie' => 'foo' } }

      it 'puts a cookie in the cookie jar' do
        # FIXME: Mocking things probably means these things are too tightly
        # coupled.
        cookie_jar.expects(:set_cookie).with(['foo'])

        subject.call
      end
    end
  end
end
