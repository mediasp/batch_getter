module BatchGetter
  module Action
    # Gets multiple resources.
    class ResourcesGetter
      def initialize(resource_getter, uris)
        @resource_getter = resource_getter
        @uris = uris
      end

      def call
        @uris.map { |uri| @resource_getter.call(uri) }
      end
    end
  end
end
