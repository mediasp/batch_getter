require 'restclient'

module BatchGetter
  module Action
    # Get a resource from a given URL
    class ResourceGetter
      # resource getter error
      class Error < StandardError
      end

      def initialize(path, headers, rest_client, strict_error_codes: [])
        # FIXME: can we do this without the shared state of cookie_jar?
        # perhaps call returns the headers as well as the body?
        @rest_client = rest_client
        @headers = headers
        @path = path
        @strict_error_codes = strict_error_codes
      end

      def call
        response = @rest_client[@path].get @headers
        JSON.parse(response.join)
      rescue RestClient::Exception => error
        error_response(error)
      end

      private

      # FIXME: Does this break single-responsibility principle?
      # Maybe should be in its own action.
      def parse_headers(headers)
        (cookie = headers[:set_cookie]) && @cookie_jar.cookie = cookie
      end

      def error_response(error)
        status = error.http_code
        if @strict_error_codes.include? status
          fail Error
        else
          { 'status' => status,
            'message' => error.http_body }
        end
      end
    end
  end
end
