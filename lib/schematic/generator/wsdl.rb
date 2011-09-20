module Schematic
  module Generator
    class Wsdl
      include XmlHelper
      attr_accessor :location

      def initialize(options = {})
        @location = options[:location] || "http://example.org/your.wsdl"
      end

      def to_wsdl(options = {})
        output = ""
        builder = Builder::XmlMarkup.new(:target => output, :indent => 2)
        header(builder)
        description(builder)
        output
      end

      def description(builder)
        attributes = {}
        attributes.merge!(ns("wsdl", :w3, :wsdl))
        attributes.merge!(ns("xs", :w3, :schema))
        attributes.merge!(ns("xsi", :w3, :schema_instance))
        attributes.merge!({"targetNamespace" => location})
        builder.wsdl :description, attributes do |description|
          types(description)
          interface(description)
        end
      end

      def types(builder)
        builder.wsdl :types do |types|
        end
      end

      def interface(builder)
        attributes = { "name" => "foo" }
        builder.wsdl :interface, attributes do |interface|
        end
      end
    end
  end
end

