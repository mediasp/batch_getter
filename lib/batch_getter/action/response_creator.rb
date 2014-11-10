require 'json'

module BatchGetter
  module Action
    # Create a response
    class ResponseCreator
      def initialize(body, cookie)
        @body = body
        @cookie = cookie
      end

      def call
        headers = { 'Content-Type' => 'application/json' }
        headers.merge!('Set-Cookie' => @cookie) if @cookie && @cookie != ''

        [200, headers, [@body.to_json]]
      end
    end
  end
end
