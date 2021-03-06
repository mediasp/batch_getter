require 'test_helper'
require 'batch_getter/action/resource_getter'
require 'webmock/minitest'
require 'mocha/minitest'

describe BatchGetter::Action::ResourceGetter do
  let(:base) { 'www.example.com' }
  let(:path) { 'foo' }
  let(:rest_client) { RestClient::Resource.new(base) }
  let(:body) { %q({"foo": "bar", "bar": "baz"}) }
  let(:status) { 200 }
  let(:strict_error_codes) { [] }
  let(:response_headers) { {} }
  let(:headers) { {} }

  subject do
    BatchGetter::Action::ResourceGetter.new(path, headers, rest_client,
                                            strict_error_codes: strict_error_codes)
  end

  describe '#call' do
    describe 'URL returns JSON' do
      it 'returns the data as a JSON object' do
        stub_request(:get, base + '/' + path)
          .to_return(body: body, status: status, headers: response_headers)
        body, cookies = subject.call
        assert_equal 'bar', body['foo']
        assert_equal 'baz', body['bar']
        assert_equal({}, cookies)
      end
    end

    describe 'URL sets a cookie' do
      let(:response_headers) { { set_cookie: %w(foo=foo) } }

      it 'returns the set-cookie header' do
        stub_request(:get, base + '/' + path)
          .to_return(body: body, status: status, headers: response_headers)

        body, cookies = subject.call
        assert_equal 'bar', body['foo']
        assert_equal 'baz', body['bar']
        assert_equal({ 'foo' => 'foo' }, cookies)
      end
    end

    describe 'with headers' do
      let(:headers) { { 'X-Foo' => 'Foo' } }

      it 'should pass headers on to request' do
        stub_request(:get, base + '/' + path)
          .with(headers: headers)
          .to_return(body: body, status: status, headers: response_headers)

        subject.call
      end
    end

    describe 'URL error codes' do
      let(:status) { 401 }
      let(:body) { 'please log in' }
      before do
        stub_request(:get, base + '/' + path)
          .to_return(body: body, status: status, headers: response_headers)
      end

      it 'returns the error as a JSON string' do
        body, _cookies = subject.call

        assert_equal 401, body['status']
        assert_equal 'please log in', body['message']
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
  end
end
