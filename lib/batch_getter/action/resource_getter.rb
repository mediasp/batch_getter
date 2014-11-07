require 'restclient'

module BatchGetter
  module Action
    # Get a resource from a given URL
    class ResourceGetter
      # resource getter error
      class Error < StandardError
      end

      def initialize(uri, strict_error_codes: [])
        @uri = uri
        @strict_error_codes = strict_error_codes
      end

      def call
        JSON.parse(RestClient.get(@uri).join)
      rescue => error
        status = error.http_code
        if @strict_error_codes.include? status
          raise Error
        else
          { 'status' => status,
            'message' => error.http_body }
        end
      end
    end
  end
end
