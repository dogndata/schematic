module Schematic
  module Generator
    class Sandbox
      attr_accessor :ignored_elements, :added_elements, :required_elements

      def initialize(klass)
        @klass = klass
        @ignored_elements ||= Hash.new([])
        @added_elements ||= {}
        @required_elements ||= []
      end

      def run(&block)
        instance_eval &block
      end

      def xsd_generator
        @xsd_generator ||= Schematic::Generator::Xsd.new(@klass)
      end

      def to_xsd(options = {})
        output = ""
        builder = Builder::XmlMarkup.new(:target => output, :indent => 2)
        xsd_generator.options = options
        xsd_generator.header(builder)
        xsd_generator.schema(builder)
        output
      end

      def generate_xsd(builder, klass, include_collection, options, exclude)
        xsd_generator.options = options
        xsd_generator.generate(builder, klass, include_collection, exclude)
      end

      def ignore(*fields)
        if fields[0].is_a?(Hash)
          fields[0].each do |key, value|
            ignored_elements[key.to_sym] = value
          end
        else
          fields.each { |field| ignored_elements[field] = nil }
        end
      end

      def add(*args)
        name = args.shift
        if name.is_a? Hash
          added_elements[name.keys.first] = name.values.first
        else
          added_elements[name] = nil
        end
      end

      def required(*fields)
        fields.each { |field| required_elements << field }
      end
    end
  end
end
