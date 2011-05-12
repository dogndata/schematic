module Schematic
  module Generator
    class Names

      def initialize(klass)
        @klass = klass
      end

      def type
        @klass.name.demodulize
      end

      def element
        type.underscore.dasherize
      end

      def element_collection
        element.pluralize
      end

      def collection_type
        type.pluralize
      end

    end
  end
end
