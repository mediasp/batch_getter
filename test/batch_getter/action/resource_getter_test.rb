require 'test_helper'

require 'batch_getter/action/resource_getter'

require 'webmock/minitest'

describe BatchGetter::Action::ResourceGetter do
  let(:uri) { 'www.example.com' }
  let(:body) { %w({"foo": "bar", "bar": "baz"}) }
  let(:status) { 200 }
  let(:strict_error_codes) { [] }

  before do
    stub_request(:get, uri).to_return(body: body, status: status)
  end

  subject do
    BatchGetter::Action::ResourceGetter.new("http://#{uri}/",
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
  end
end
