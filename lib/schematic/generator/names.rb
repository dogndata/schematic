module Schematic
  module Generator
    class Names
      attr_accessor :root, :klass

      def initialize(klass)
        @klass = klass
      end

      def type
        @klass.name.gsub(/::/,'')
      end

      def element
        element_name
      end

      def element_collection
        element_name.pluralize
      end

      def collection_type
        type.pluralize
      end

      def nested_attribute_name
        "#{element_collection}-attributes"
      end

      private

      def element_name
        (@root || type.underscore).dasherize
      end
    end
  end
end
