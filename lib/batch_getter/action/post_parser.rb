require 'json'

module BatchGetter
  module Action
    # Parses a post request and returns a list of URLs
    class PostParser
      def initialize(base, data)
        @base = base
        @data = JSON.parse(data)
      end

      def call
        @data.map { |path| File.join(@base, path) }
      end
    end
  end
end
