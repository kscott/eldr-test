module Oat
  module Adapters
    class ChurchCommunityBuilder < Oat::Adapter

      def property(key, value)
        data[key] = value
      end

      def link(key, href:, authorized:false, **opts)
        key = :profile if key == :self
        data[:_links][key] = {url: href, authorized: authorized}
      end

      def properties(&block)
        data.merge! yield_props(&block)
      end

      def entity(name, obj, serializer_class = nil, context_options = {}, &block)
        entity_serializer = serializer_from_block_or_class(obj, serializer_class, context_options, &block)
        data[name] = entity_serializer ? entity_serializer.to_hash : nil
      end

      def entities(name, collection, serializer_class = nil, context_options = {}, &block)
        data[name] = collection.map do |obj|
          entity_serializer = serializer_from_block_or_class(obj, serializer_class, context_options, &block)
          entity_serializer ? entity_serializer.to_hash : nil
        end
      end

      alias_method :meta, :property
      alias_method :collection, :entities

    end
  end
end
