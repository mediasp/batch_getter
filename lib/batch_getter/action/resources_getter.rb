module BatchGetter
  module Action
    # Gets multiple resources.
    class ResourcesGetter
      def initialize(resource_getter, uris)
        @resource_getter = resource_getter
        @uris = uris
      end

      def call
        @uris.each_with_object([[], {}]) do |uri, (bodies, cookies)|
          body, cookie = @resource_getter.call(uri)
          cookies.merge!(cookie)
          bodies << body
        end
      end
    end
  end
end
