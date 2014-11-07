module BatchGetter
  module Action
    # Gets multiple resources.
    class ResourcesGetter
      def initialize(cookie_jar, resource_getter, uris)
        @cookie_jar = cookie_jar
        @resource_getter = resource_getter
        @uris = uris
      end

      def call
        @uris.map do |uri|
          cookies = @cookie_jar.cookies
          @resource_getter.call(uri, cookies)
        end
      end
    end
  end
end
