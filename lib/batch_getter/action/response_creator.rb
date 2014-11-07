require 'json'

module BatchGetter
  module Action
    # Create a response
    class ResponseCreator
      def initialize(cookie_jar, body)
        @cookie_jar = cookie_jar
        @body = body
      end

      def call
        headers = {
          'Cookies' => @cookie_jar.cookie_string,
          'Content-Type' => 'application/json'
        }

        [200, headers, [@body.to_json]]
      end
    end
  end
end
