require 'test_helper'

require 'batch_getter/action/post_parser'

describe BatchGetter::Action::PostParser do
  let(:base_url) { 'www.example.com' }

  subject { BatchGetter::Action::PostParser.new(base_url, json_array) }

  describe '#call' do
    describe 'given a JSON array' do
      let(:json_array) { %q([ "foo", "bar" ]) }

      it 'should return an array of URLs' do
        assert_equal %w(www.example.com/foo www.example.com/bar), subject.call
      end
    end

    describe 'given JSON hash' do
      let(:json_array) { %q({ "foo": "foo", "bar": "bar" }) }

      it 'should raise an error' do
        assert_raises(BatchGetter::Action::PostParser::Error) { subject.call }
      end
    end

    describe 'given non-JSON data' do
      let(:json_array) { %q(not really a json string) }

      it 'should raise an error' do
        assert_raises(BatchGetter::Action::PostParser::Error) { subject.call }
      end
    end
  end
end
