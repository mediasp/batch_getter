require 'json'

module BatchGetter
  module Action
    # Parses a post request and returns a list of URLs
    class PostParser
      # Post parser error
      class Error < StandardError
      end

      def initialize(data)
        @data = JSON.parse(data)
      rescue
        raise Error
      end

      def call
        fail Error if @data.respond_to? :keys
        @data
      end
    end
  end
end
