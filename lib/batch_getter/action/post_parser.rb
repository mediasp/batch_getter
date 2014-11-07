require 'json'

module BatchGetter
  module Action
    # Parses a post request and returns a list of URLs
    class PostParser
      class Error < StandardError
      end

      def initialize(base, data)
        @base = base
        @data = JSON.parse(data)
      rescue
        raise Error
      end

      def call
        fail Error if @data.respond_to? :keys
        @data.map { |path| File.join(@base, path) }
      end
    end
  end
end
