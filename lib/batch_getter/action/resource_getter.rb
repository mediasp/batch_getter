require 'restclient'

module BatchGetter
  module Action
    # Get a resource from a given URL
    class ResourceGetter
      def initialize(uri)
        @uri = uri
      end

      def call
        JSON.parse(RestClient.get(@uri).join)
      rescue => error
        { 'status' => error.http_code,
          'message' => error.http_body }
      end
    end
  end
end
