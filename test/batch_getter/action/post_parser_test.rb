require 'test_helper'

require 'batch_getter/action/post_parser'

describe BatchGetter::Action::PostParser do
  let(:base_url) { 'www.example.com' }

  describe '#call' do
    describe 'given a JSON array' do
      let(:json_array) { %q([ "foo", "bar" ]) }

      subject { BatchGetter::Action::PostParser.new(base_url, json_array) }

      it 'should return an array of URLs' do
        assert_equal %w(www.example.com/foo www.example.com/bar), subject.call
      end
    end

    describe 'given JSON hash' do
      it 'should raise an error'
    end

    describe 'given non-JSON data' do
      it 'should raise an error'
    end
  end
end
