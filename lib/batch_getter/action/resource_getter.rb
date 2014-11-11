require 'restclient'

module BatchGetter
  module Action
    # Get a resource from a given URL
    class ResourceGetter
      # resource getter error
      class Error < StandardError
        def initialize(status)
          @status = status
        end

        attr_reader :status
      end

      def initialize(path, headers, rest_client, strict_error_codes: [])
        @rest_client = rest_client
        @headers = headers
        @path = path
        @strict_error_codes = strict_error_codes
      end

      def call
        response = @rest_client[@path].get @headers
        cookies = response.cookies
        [parse_json(response), cookies]
      rescue RestClient::Exception => error
        [error_response(error), '']
      end

      private

      def error_response(error)
        status = error.http_code
        if @strict_error_codes.map(&:to_i).include? status
          fail Error, status
        else
          { 'status' => status,
            'message' => error.http_body }
        end
      end

      def parse_json(data)
        case data
        when /^[\[\{]/
          JSON.parse(data)
        else
          JSON.parse("[#{data}]").first
        end
      end
    end
  end
end
