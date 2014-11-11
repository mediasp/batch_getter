module BatchGetter
  module Action
    # Converts cookies from the hash style we get back from RestClient
    # to an array of strings we can send back in the Rack headers
    class CookieParser
      def initialize(cookies)
        @cookies = cookies
      end

      def call
        @cookies.map { |cookie| cookie.join('=') }.join('; ')
      end
    end
  end
end
